-- 기존 Oracle users 테이블을 SQLite로 옮긴 스키마
CREATE TABLE IF NOT EXISTS users (
    user_id    TEXT PRIMARY KEY,
    user_pw    TEXT NOT NULL,
    user_name  TEXT,
    user_email TEXT,
    user_img   TEXT
);

-- 선반에 꽂히는 노트
CREATE TABLE IF NOT EXISTS notes (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id    TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title      TEXT NOT NULL,
    color      TEXT NOT NULL,
    content    TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS notes_user ON notes(user_id);
