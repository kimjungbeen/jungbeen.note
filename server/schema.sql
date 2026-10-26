-- 기존 Oracle users 테이블을 SQLite로 옮긴 스키마
CREATE TABLE IF NOT EXISTS users (
    user_id    TEXT PRIMARY KEY,
    user_pw    TEXT NOT NULL,
    user_name  TEXT,
    user_email TEXT,
    user_img   TEXT
);
