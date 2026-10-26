"""MyBatis 매퍼(UserMapper, NoteMapper, PageMapper, UserNoteMapper)를 옮긴 SQLite 접근 함수."""
import os
import sqlite3

from flask import current_app, g

SCHEMA_PATH = os.path.join(os.path.dirname(__file__), "schema.sql")
PAGE_COUNT = 50


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(current_app.config["DATABASE"])
        g.db.row_factory = sqlite3.Row
    return g.db


def close_db(e=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def _columns(conn, table):
    return {r[1] for r in conn.execute(f"PRAGMA table_info({table})")}


def init_db(path):
    conn = sqlite3.connect(path)
    with conn:
        # 이전 Python 버전에서 만든 notes 테이블(형식이 다름)은 지우지 않고 이름만 바꿔 둔다.
        legacy = None
        cols = _columns(conn, "notes")
        if cols and "share_cnt" not in cols:
            legacy = "notes_legacy"
            n = 1
            while _columns(conn, legacy):
                n += 1
                legacy = f"notes_legacy{n}"
            conn.execute(f"ALTER TABLE notes RENAME TO {legacy}")
            for (idx,) in conn.execute(
                    "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = ? "
                    "AND sql IS NOT NULL", (legacy,)).fetchall():
                conn.execute(f"DROP INDEX {idx}")
        with open(SCHEMA_PATH, encoding="utf-8") as f:
            conn.executescript(f.read())
        if legacy:
            _import_legacy_notes(conn, legacy)
    conn.close()


# 이전 버전의 노트(사용자별 제목, 색, 내용 1장)를 원본 구조의 노트 + 첫 페이지로 옮긴다.
def _import_legacy_notes(conn, legacy):
    if not {"user_id", "title", "color", "content"} <= _columns(conn, legacy):
        return
    rows = conn.execute(
        f"SELECT user_id, title, color, content FROM {legacy} "
        "WHERE title != '' OR content != '' ORDER BY id").fetchall()
    for user_id, title, color, content in rows:
        note_id = _insert_note(conn, title or "new Note", color)
        conn.execute("UPDATE pages SET page_content1 = ? WHERE note_id = ? AND page_index = 0",
                     (content, note_id))
        idx = conn.execute("SELECT COUNT(*) FROM usernote WHERE user_id = ?", (user_id,)).fetchone()[0]
        conn.execute("INSERT INTO usernote VALUES (?, ?, ?, 1)", (user_id, note_id, idx))


def _insert_note(conn, name, color):
    cur = conn.execute("INSERT INTO notes (note_name, note_color, share_cnt) VALUES (?, ?, 0)",
                       (name or "new Note", color))
    note_id = cur.lastrowid
    conn.executemany("INSERT INTO pages (note_id, page_index) VALUES (?, ?)",
                     [(note_id, i) for i in range(PAGE_COUNT)])
    return note_id


def _commit(cur):
    get_db().commit()
    return cur.rowcount


########## UserMapper ##########

USER_COLS = "user_id userId, user_pw userPw, user_name userName, user_email userEmail"


def get_user(user_id):
    row = get_db().execute(f"SELECT {USER_COLS} FROM users WHERE user_id = ?", (user_id,)).fetchone()
    return dict(row) if row else None


def get_ids(user_name):
    return [dict(r) for r in get_db().execute(
        f"SELECT {USER_COLS} FROM users WHERE user_name = ?", (user_name,))]


def add_user(user_id, user_pw, user_name, user_email):
    try:
        return _commit(get_db().execute(
            "INSERT INTO users (user_id, user_pw, user_name, user_email) VALUES (?, ?, ?, ?)",
            (user_id, user_pw, user_name, user_email)))
    except sqlite3.IntegrityError:
        return 0


def update_user(user_id, column, value):
    assert column in ("user_name", "user_pw", "user_email")
    return _commit(get_db().execute(f"UPDATE users SET {column} = ? WHERE user_id = ?", (value, user_id)))


def del_user(user_id):
    return _commit(get_db().execute("DELETE FROM users WHERE user_id = ?", (user_id,)))


########## NoteMapper ##########

NOTE_COLS = "note_id id, note_name name, note_color color, share_cnt shareCnt"


def select_notes(user_id):
    return [dict(r) for r in get_db().execute(
        f"SELECT {NOTE_COLS} FROM notes WHERE note_id IN "
        "(SELECT note_id FROM usernote WHERE user_id = ?)", (user_id,))]


def select_note(note_id):
    row = get_db().execute(f"SELECT {NOTE_COLS} FROM notes WHERE note_id = ?", (note_id,)).fetchone()
    return dict(row) if row else None


# 노트와 빈 페이지 50장을 만든다. (NoteController.addNote의 NEXTVAL + insertNote + insertPage)
def insert_note(name, color):
    note_id = _insert_note(get_db(), name, color)
    get_db().commit()
    return note_id


def update_note(note_id, name=None, color=None, share_cnt=None):
    sets, args = [], []
    if name:
        sets.append("note_name = ?"); args.append(name)
    if color is not None:
        sets.append("note_color = ?"); args.append(color)
    if share_cnt is not None:
        sets.append("share_cnt = ?"); args.append(share_cnt)
    if not sets:
        return 0
    return _commit(get_db().execute(
        f"UPDATE notes SET {', '.join(sets)} WHERE note_id = ?", (*args, note_id)))


def delete_note(note_id):
    return _commit(get_db().execute("DELETE FROM notes WHERE note_id = ?", (note_id,)))


########## PageMapper ##########

PAGE_COLS = ("note_id noteId, page_id id, page_index idx, page_content1 content1, "
             "page_content2 content2, page_content3 content3, page_content4 content4, "
             "page_content5 content5")


def select_pages(note_id):
    return [dict(r) for r in get_db().execute(
        f"SELECT {PAGE_COLS} FROM pages WHERE note_id = ? ORDER BY page_id", (note_id,))]


def select_page(note_id, idx):
    row = get_db().execute(
        f"SELECT {PAGE_COLS} FROM pages WHERE note_id = ? AND page_index = ?", (note_id, idx)).fetchone()
    return dict(row) if row else None


def update_page(page_id, contents):
    sets = [f"page_content{i} = ?" for i, c in enumerate(contents, 1) if c is not None]
    if not sets:
        return 0
    return _commit(get_db().execute(
        f"UPDATE pages SET {', '.join(sets)} WHERE page_id = ?",
        (*[c for c in contents if c is not None], page_id)))


def delete_pages(note_id):
    return _commit(get_db().execute("DELETE FROM pages WHERE note_id = ?", (note_id,)))


########## UserNoteMapper ##########

def _where(user_id, note_id):
    conds, args = [], []
    if user_id is not None:
        conds.append("user_id = ?"); args.append(user_id)
    if note_id:
        conds.append("note_id = ?"); args.append(note_id)
    return (" WHERE " + " AND ".join(conds) if conds else ""), args


def select_user_notes(user_id=None, note_id=0):
    where, args = _where(user_id, note_id)
    return [dict(r) for r in get_db().execute(
        "SELECT user_id userId, note_id noteId, note_index noteIdx, is_owner isOwner "
        f"FROM usernote{where} ORDER BY note_index DESC", args)]


def insert_user_note(user_id, note_id, note_idx, is_owner):
    return _commit(get_db().execute("INSERT INTO usernote VALUES (?, ?, ?, ?)",
                                    (user_id, note_id, note_idx, is_owner)))


def update_user_note(user_id=None, note_id=0, note_idx=-1, is_owner=-1):
    sets, args = [], []
    if note_idx != -1:
        sets.append("note_index = ?"); args.append(note_idx)
    if is_owner != -1:
        sets.append("is_owner = ?"); args.append(is_owner)
    if not sets:
        return 0
    where, wargs = _where(user_id, note_id)
    if not where:
        return 0
    return _commit(get_db().execute(f"UPDATE usernote SET {', '.join(sets)}{where}", (*args, *wargs)))


def delete_user_note(user_id=None, note_id=0):
    where, args = _where(user_id, note_id)
    if not where:
        return 0
    return _commit(get_db().execute(f"DELETE FROM usernote{where}", args))
