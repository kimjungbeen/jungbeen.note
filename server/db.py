import os
import sqlite3

from flask import current_app, g

SCHEMA_PATH = os.path.join(os.path.dirname(__file__), "schema.sql")


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(current_app.config["DATABASE"])
        g.db.row_factory = sqlite3.Row
    return g.db


def close_db(e=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def init_db(path):
    with sqlite3.connect(path) as conn, open(SCHEMA_PATH, encoding="utf-8") as f:
        conn.executescript(f.read())


# 사용자 한명의 정보를 조회한다. (UserMapper.getUser)
def get_user(user_id):
    row = get_db().execute(
        "SELECT user_id, user_pw, user_name, user_email FROM users WHERE user_id = ?",
        (user_id,),
    ).fetchone()
    return dict(row) if row else None


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
