"""jungbeen.note 서버 (Spring UserController를 Flask로 옮기고 노트 기능을 연결한 버전)."""
import functools
import os

from flask import (Flask, abort, flash, g, jsonify, redirect, render_template, request,
                   session, url_for)
from werkzeug.security import check_password_hash, generate_password_hash

import db

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# 메인 선반에 있던 파스텔 노트 색
NOTE_COLORS = ["#F5A9A9", "#CEECF5", "#E6E6E6", "#F6CEE3", "#F5F6CE", "#D8F6CE"]

app = Flask(__name__)
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "dev-only-change-me")
app.config["DATABASE"] = os.environ.get("DATABASE", os.path.join(BASE_DIR, "note.db"))
app.teardown_appcontext(db.close_db)
db.init_db(app.config["DATABASE"], NOTE_COLORS)


@app.before_request
def load_user():
    user_id = session.get("loginUser")
    g.user = db.get_user(user_id) if user_id else None
    if user_id and g.user is None:
        session.clear()


def login_required(view):
    @functools.wraps(view)
    def wrapped(*args, **kwargs):
        if g.user is None:
            return redirect(url_for("login"))
        return view(*args, **kwargs)
    return wrapped


def log_in(user_id):
    session.clear()
    session["loginUser"] = user_id


# 로그인: 아이디와 비밀번호를 한 화면에서 받는다.
@app.route("/", methods=["GET", "POST"])
def login():
    if g.user is not None:
        return redirect(url_for("main"))
    user_id = request.form.get("userId", "").strip()
    if request.method == "POST":
        user = db.get_user(user_id) if user_id else None
        if user and check_password_hash(user["user_pw"], request.form.get("userPw", "")):
            log_in(user_id)
            return redirect(url_for("main"))
        flash("아이디 또는 비밀번호가 맞지 않아요.")
    return render_template("user/login.html", user_id=user_id)


@app.route("/logout", methods=["GET", "POST"])
def logout():
    session.clear()
    return redirect(url_for("login"))


def mask_id(user_id):
    shown = 2 if len(user_id) > 4 else 1
    return user_id[:shown] + "*" * max(len(user_id) - shown, 3)


@app.route("/findId", methods=["GET", "POST"])
def find_id():
    email = request.form.get("userEmail", "").strip()
    found = None
    if request.method == "POST" and email:
        # 남의 아이디를 통째로 알려주지 않도록 앞 한두 글자만 보여준다.
        found = [mask_id(i) for i in db.find_user_ids(email)]
    return render_template("user/findId.html", email=email, found=found)


# 예전 주소 호환
@app.get("/findPw")
def find_pw():
    return redirect(url_for("find_id"))


@app.route("/addUser", methods=["GET", "POST"])
def add_user():
    f = request.form
    if request.method == "POST":
        user_id, user_pw = f.get("userId", "").strip(), f.get("userPw", "")
        if not user_id or not user_pw:
            flash("아이디와 비밀번호를 입력하세요.")
        elif len(user_pw) < 4:
            flash("비밀번호는 4자 이상이어야 해요.")
        elif user_pw != f.get("checkPw", ""):
            flash("비밀번호 확인이 일치하지 않아요.")
        elif not db.add_user(user_id, generate_password_hash(user_pw),
                             f.get("userName", "").strip(), f.get("userEmail", "").strip()):
            flash("이미 사용 중인 아이디예요.")
        else:
            db.add_default_notes(user_id, NOTE_COLORS)
            log_in(user_id)
            return redirect(url_for("main"))
    return render_template("user/addUser.html", form=f)


@app.post("/user/edit")
@login_required
def edit_user():
    f = request.form
    if not check_password_hash(g.user["user_pw"], f.get("userPw", "")):
        flash("현재 비밀번호가 맞지 않아 수정하지 못했어요.")
    else:
        db.update_user(g.user["user_id"], f.get("userName", "").strip(),
                       f.get("userEmail", "").strip())
        flash("회원정보를 수정했어요.")
    return redirect(url_for("main"))


# 회원정보 수정 창의 '비밀번호 확인' 버튼
@app.post("/passCheck")
@login_required
def pass_check():
    return jsonify(check_password_hash(g.user["user_pw"], request.form.get("userPw", "")))


@app.post("/user/delete")
@login_required
def delete_user():
    db.delete_user(g.user["user_id"])
    session.clear()
    return redirect(url_for("login"))


@app.route("/main")
@login_required
def main():
    return render_template("main.html", user=g.user, notes=db.list_notes(g.user["user_id"]))


def own_note(note_id):
    note = db.get_note(note_id, g.user["user_id"])
    if note is None:
        abort(404)
    return note


@app.get("/notes/<int:note_id>")
@login_required
def note(note_id):
    return render_template("note.html", note=own_note(note_id))


# 편집 화면의 자동 저장
@app.post("/notes/<int:note_id>/save")
@login_required
def save_note(note_id):
    own_note(note_id)
    data = request.get_json(silent=True) or {}
    title = str(data.get("title", "")).strip()[:60]
    db.update_note(note_id, g.user["user_id"], title=title, content=str(data.get("content", "")))
    return jsonify(ok=True)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="127.0.0.1", port=port, debug=True)
