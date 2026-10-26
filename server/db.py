import os
import sqlite3

from flask import current_app, g

SCHEMA_PATH = os.path.join(os.path.dirname(__file__), "schema.sql")


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(current_app.config["DATABASE"])
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA foreign_keys = ON")
    return g.db


def close_db(e=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def init_db(path, default_colors):
    with sqlite3.connect(path) as conn, open(SCHEMA_PATH, encoding="utf-8") as f:
        had_notes = conn.execute(
            "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'notes'").fetchone()
        conn.executescript(f.read())
        # notes 테이블이 처음 생길 때, 이미 있던 사용자에게도 기본 노트를 꽂아 준다.
        if not had_notes:
            for (user_id,) in conn.execute("SELECT user_id FROM users").fetchall():
                _insert_default_notes(conn, user_id, default_colors)


# 기존 메인 화면에 있던 6권의 노트를 사용자의 기본 노트로 만든다.
def _insert_default_notes(conn, user_id, colors):
    conn.executemany(
        "INSERT INTO notes (user_id, title, color) VALUES (?, '', ?)",
        [(user_id, c) for c in colors],
    )


def add_default_notes(user_id, colors):
    db = get_db()
    _insert_default_notes(db, user_id, colors)
    db.commit()


# 사용자 한명의 정보를 조회한다. (UserMapper.getUser)
def get_user(user_id):
    row = get_db().execute(
        "SELECT user_id, user_pw, user_name, user_email FROM users WHERE user_id = ?",
        (user_id,),
    ).fetchone()
    return dict(row) if row else None


# 이메일로 가입한 아이디들을 찾는다.
def find_user_ids(email):
    rows = get_db().execute(
        "SELECT user_id FROM users WHERE lower(user_email) = lower(?) ORDER BY user_id", (email,)
    ).fetchall()
    return [r["user_id"] for r in rows]


# 사용자 정보를 추가한다. return: 추가한 사용자 정보 수 (UserMapper.addUser)
def add_user(user_id, user_pw, user_name, user_email):
    db = get_db()
    try:
        cur = db.execute(
            "INSERT INTO users (user_id, user_pw, user_name, user_email) VALUES (?, ?, ?, ?)",
            (user_id, user_pw, user_name, user_email),
        )
        db.commit()
        return cur.rowcount
    except sqlite3.IntegrityError:
        return 0


def update_user(user_id, user_name, user_email, user_pw=None):
    db = get_db()
    if user_pw:
        db.execute(
            "UPDATE users SET user_name = ?, user_email = ?, user_pw = ? WHERE user_id = ?",
            (user_name, user_email, user_pw, user_id),
        )
    else:
        db.execute(
            "UPDATE users SET user_name = ?, user_email = ? WHERE user_id = ?",
            (user_name, user_email, user_id),
        )
    db.commit()


def delete_user(user_id):
    db = get_db()
    db.execute("DELETE FROM users WHERE user_id = ?", (user_id,))
    db.commit()


def list_notes(user_id):
    return get_db().execute(
        "SELECT id, title, color FROM notes WHERE user_id = ? ORDER BY id", (user_id,)
    ).fetchall()


def get_note(note_id, user_id):
    row = get_db().execute(
        "SELECT * FROM notes WHERE id = ? AND user_id = ?", (note_id, user_id)
    ).fetchone()
    return dict(row) if row else None


def update_note(note_id, user_id, **fields):
    cols = ", ".join(f"{k} = ?" for k in fields)
    db = get_db()
    cur = db.execute(
        f"UPDATE notes SET {cols}, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?",
        (*fields.values(), note_id, user_id),
    )
    db.commit()
    return cur.rowcount
