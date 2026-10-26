-- 2018-09 원본의 Oracle 테이블(users, notes, pages, usernote)을 SQLite로 옮긴 스키마
CREATE TABLE IF NOT EXISTS users (
    user_id    TEXT PRIMARY KEY,
    user_pw    TEXT NOT NULL,
    user_name  TEXT,
    user_email TEXT,
    user_img   TEXT
);

CREATE TABLE IF NOT EXISTS notes (
    note_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    note_name  TEXT,
    note_color TEXT,
    share_cnt  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS pages (
    note_id       INTEGER NOT NULL,
    page_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    page_index    INTEGER NOT NULL,
    page_content1 TEXT DEFAULT '',
    page_content2 TEXT DEFAULT '',
    page_content3 TEXT DEFAULT '',
    page_content4 TEXT DEFAULT '',
    page_content5 TEXT DEFAULT ''
);
CREATE INDEX IF NOT EXISTS pages_note ON pages(note_id, page_index);

CREATE TABLE IF NOT EXISTS usernote (
    user_id    TEXT NOT NULL,
    note_id    INTEGER NOT NULL,
    note_index INTEGER NOT NULL,
    is_owner   INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS usernote_user ON usernote(user_id);
CREATE INDEX IF NOT EXISTS usernote_note ON usernote(note_id);
