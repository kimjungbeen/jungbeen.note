"""jungbeen.note 서버 (Spring UserController를 Flask로 옮긴 버전)."""
import os

from flask import Flask, jsonify, render_template, request, session
from werkzeug.security import check_password_hash, generate_password_hash

import db

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

app = Flask(__name__)
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "dev-only-change-me")
app.config["DATABASE"] = os.environ.get("DATABASE", os.path.join(BASE_DIR, "note.db"))
app.teardown_appcontext(db.close_db)
db.init_db(app.config["DATABASE"])


@app.get("/")
def login():
    return render_template("user/logIn.html")


# 1단계: 아이디 확인. 맞으면 세션에 사용자를 기억해 둔다.
@app.post("/")
def find_id():
    user_id = request.form.get("userId", "")
    user = db.get_user(user_id) if user_id else None
    if user is None:
        return jsonify(False)
    session["corUser"] = user["user_id"]
    return jsonify(True)


# 2단계: 세션의 사용자와 비밀번호 비교
@app.post("/passCheck")
def pass_check():
    user_pw = request.form.get("userPw", "")
    user_id = session.get("corUser")
    if not user_pw or not user_id:
        return jsonify(False)
    user = db.get_user(user_id)
    ok = user is not None and check_password_hash(user["user_pw"], user_pw)
    if ok:
        session["loginUser"] = user_id
    return jsonify(ok)


@app.get("/findPw")
def find_pw():
    return render_template("user/findPw.html")


@app.get("/addUser")
def add_user_form():
    return render_template("user/addUser.html")


@app.post("/addUser")
def add_user():
    f = request.form
    user_id, user_pw = f.get("userId", ""), f.get("userPw", "")
    if not user_id or not user_pw:
        return jsonify(False)
    added = db.add_user(
        user_id, generate_password_hash(user_pw), f.get("userName"), f.get("userEmail")
    )
    if added:
        session["corUser"] = session["loginUser"] = user_id
    return jsonify(added > 0)


@app.route("/main")
def main():
    return render_template("main.html")


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="127.0.0.1", port=port, debug=True)
