"""jungbeen.note 서버.

2018-09 원본의 Spring 컨트롤러(UserController, NoteController, PageController,
UserNoteController)를 Flask로 옮겼다. 원본은 /note 컨텍스트에 배포됐고 화면의 JS가
"/note/..." 주소를 그대로 쓰므로, 모든 라우트를 /note 아래에 둔다.
"""
import functools
import os
import secrets
import smtplib
from email.mime.text import MIMEText

from flask import (Blueprint, Flask, abort, g, jsonify, redirect, render_template, request,
                   send_from_directory, session)
from werkzeug.security import check_password_hash, generate_password_hash

import db

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

app = Flask(__name__, static_folder=None)
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "dev-only-change-me")
app.config["DATABASE"] = os.environ.get("DATABASE", os.path.join(BASE_DIR, "note.db"))
app.config["UPLOAD_DIR"] = os.environ.get("UPLOAD_DIR", os.path.join(BASE_DIR, "upload"))
app.teardown_appcontext(db.close_db)
db.init_db(app.config["DATABASE"])
os.makedirs(app.config["UPLOAD_DIR"], exist_ok=True)

bp = Blueprint("note", __name__, url_prefix="/note")


@app.get("/")
def root():
    return redirect("/note/")


# 원본의 <mvc:resources> 매핑: /note/css, /note/js, /note/img, /note/upload
@bp.get("/<any(css, js, img):kind>/<path:filename>")
def resources(kind, filename):
    return send_from_directory(os.path.join(BASE_DIR, "static", kind), filename)


@bp.get("/upload/<path:filename>")
def uploaded(filename):
    return send_from_directory(app.config["UPLOAD_DIR"], filename)


@app.before_request
def load_user():
    user_id = session.get("loginUser")
    g.user = db.get_user(user_id) if user_id else None


def login_required(view):
    @functools.wraps(view)
    def wrapped(*args, **kwargs):
        if g.user is None:
            if request.method == "GET" and not request.path.startswith("/note/userNote"):
                return redirect("/note/")
            abort(401)
        return view(*args, **kwargs)
    return wrapped


def form(name, default=None):
    return request.values.get(name, default)


def form_int(name, default=0):
    value = (request.values.get(name) or "").strip()
    return int(value) if value.lstrip("-").isdigit() else default


def public_user(user):
    return {k: user[k] for k in ("userId", "userName", "userEmail")} if user else None


##################### UserController #####################

######## logIn.html에서 사용 ########
@bp.get("/")
def login():
    return render_template("user/logIn.html")


# 1단계: 아이디 확인
@bp.post("/")
def login_id():
    user_id = form("userId", "")
    user = db.get_user(user_id) if user_id else None
    if user is None:
        return jsonify(False)
    session["corUser"] = user_id
    return jsonify(True)


# 2단계: 비밀번호 확인. 맞으면 로그인 상태가 된다.
@bp.post("/passCheck")
def check_pw():
    user_pw = form("userPw", "")
    user = db.get_user(session.get("corUser") or "")
    if not user_pw or user is None or not check_password_hash(user["userPw"], user_pw):
        return jsonify(False)
    session["loginUser"] = user["userId"]
    return jsonify(True)


######## addUser.html에서 사용 ########
@bp.get("/addUser")
def add_user_form():
    return render_template("user/addUser.html")


@bp.post("/addUser")
def add_user():
    user_name, user_id = form("userName", ""), form("userId", "")
    user_pw, user_email = form("userPw", ""), form("userEmail", "")
    if not (user_name and user_id and user_pw and user_email):
        return jsonify(False)
    if not db.add_user(user_id, generate_password_hash(user_pw), user_name, user_email):
        return jsonify(False)
    session.clear()
    session["corUser"] = session["loginUser"] = user_id
    return jsonify(True)


@bp.post("/idCheck")
def check_id():
    return jsonify(db.get_user(form("userId", "")) is None)


######## findId.html에서 사용 ########
@bp.get("/findId")
def find_id_form():
    return render_template("user/findId.html")


# 이름으로 사용자들을 찾아 세션에 두고, 다음 단계에서 이메일로 한 명을 고른다.
@bp.post("/findId")
@bp.post("/findPw")
def find_by_name():
    users = db.get_ids(form("userName", ""))
    session["corUsers"] = [u["userId"] for u in users]
    return jsonify(bool(users))


def candidates():
    return [u for u in (db.get_user(i) for i in session.get("corUsers", [])) if u]


@bp.post("/emailCheck")
def check_email():
    email = form("userEmail", "")
    match = [u for u in candidates() if u["userEmail"] == email]
    return jsonify(public_user(match[-1]) if match else None)


@bp.route("/intoId", methods=["GET", "POST"])
@bp.route("/intoId/", methods=["GET", "POST"])
def into_id():
    session["corUser"] = form("userId")
    return redirect("/note/")


######## findPw.html에서 사용 ########
@bp.get("/findPw")
def find_pw_form():
    return render_template("user/findPw.html")


def send_mail(to, subject, txt):
    """MAIL_USERNAME/MAIL_PASSWORD 환경변수가 있으면 Gmail SMTP로 보내고, 없으면 서버 로그에 남긴다."""
    username, password = os.environ.get("MAIL_USERNAME"), os.environ.get("MAIL_PASSWORD")
    if not (username and password):
        app.logger.warning("메일 설정이 없어 보내지 않음 → 받는 사람: %s / %s / %s", to, subject, txt)
        return
    msg = MIMEText(txt, "html", "utf-8")
    msg["Subject"], msg["From"], msg["To"] = subject, username, to
    with smtplib.SMTP_SSL(os.environ.get("MAIL_SERVER", "smtp.gmail.com"),
                          int(os.environ.get("MAIL_PORT", 465))) as smtp:
        smtp.login(username, password)
        smtp.send_message(msg)


# 비밀번호는 해시로 저장하므로, 원래처럼 비밀번호를 그대로 보내는 대신 임시 비밀번호를 만들어 보낸다.
@bp.post("/emailSend")
def send_email():
    email = form("userEmail", "")
    for user in candidates():
        if user["userEmail"] == email:
            temp_pw = secrets.token_urlsafe(6)
            db.update_user(user["userId"], "user_pw", generate_password_hash(temp_pw))
            session["corUser"] = user["userId"]
            send_mail(email, "note 비밀번호입니다.",
                      f"{user['userId']}님의 임시 비밀번호는 {temp_pw} 입니다.")
            return jsonify(True)
    return jsonify(False)


@bp.route("/intoPw", methods=["GET", "POST"])
def into_pw():
    return redirect("/note/")


######## main.html에서 사용 ########
def change(column, param):
    db.update_user(g.user["userId"], column, param)
    return jsonify(public_user(db.get_user(g.user["userId"])))


@bp.post("/nameChange")
@login_required
def name_change():
    return change("user_name", form("userName", ""))


@bp.post("/pwChange")
@login_required
def pw_change():
    return change("user_pw", generate_password_hash(form("userPw", "")))


@bp.post("/emailChange")
@login_required
def email_change():
    return change("user_email", form("userEmail", ""))


@bp.get("/delUser")
@login_required
def del_user():
    user_id = g.user["userId"]
    # 내가 가진 노트는 지우고, 공유받은 노트에서는 빠진다.
    for un in db.select_user_notes(user_id=user_id):
        remove_note(user_id, un["noteId"], un["noteIdx"])
    db.del_user(user_id)
    session.clear()
    return redirect("/note/")


@bp.route("/logout", methods=["GET", "POST"])
def logout():
    session.clear()
    return redirect("/note/")


##################### NoteController #####################

@bp.route("/main", methods=["GET", "POST"])
@login_required
def main():
    user_id = g.user["userId"]
    return render_template("main.html", userId=user_id, corUser=g.user,
                           notes=db.select_notes(user_id),
                           userNotes=db.select_user_notes(user_id=user_id))


@bp.route("/add", methods=["GET", "POST"])
@login_required
def add_note():
    note_id = db.insert_note("", "#000000")
    return jsonify(bool(db.insert_user_note(g.user["userId"], note_id, form_int("idx"), 1)))


def owns(user_id, note_id):
    return any(un["isOwner"] == 1 for un in db.select_user_notes(user_id=user_id, note_id=note_id))


def has_note(user_id, note_id):
    return bool(db.select_user_notes(user_id=user_id, note_id=note_id))


@bp.route("/edit", methods=["GET", "POST"])
@login_required
def rename():
    note_id = form_int("noteId")
    if not has_note(g.user["userId"], note_id):
        return jsonify(False)
    return jsonify(bool(db.update_note(note_id, name=form("noteName"), color=form("noteColor"))))


# 내 선반에서 노트 하나를 빼고, 소유주면 노트 자체를 지운다. (NoteController.delete)
def remove_note(user_id, note_id, note_idx):
    is_owner = owns(user_id, note_id)
    # 빠지는 노트보다 뒤에 있던 노트들의 인덱스를 당긴다. 소유주가 지우면 공유받은 사람들도 당긴다.
    holders = [un["userId"] for un in db.select_user_notes(note_id=note_id)] if is_owner else [user_id]
    for holder in holders:
        idx = note_idx if holder == user_id else next(
            (un["noteIdx"] for un in db.select_user_notes(user_id=holder, note_id=note_id)), note_idx)
        for un in db.select_user_notes(user_id=holder):
            if un["noteIdx"] > idx:
                db.update_user_note(holder, un["noteId"], un["noteIdx"] - 1)

    db.delete_user_note(user_id=None if is_owner else user_id, note_id=note_id)
    if is_owner or not db.select_user_notes(note_id=note_id):
        db.delete_pages(note_id)
        db.delete_note(note_id)
    else:
        note = db.select_note(note_id)
        db.update_note(note_id, share_cnt=note["shareCnt"] - 1)


@bp.route("/delete", methods=["GET", "POST"])
@login_required
def delete():
    remove_note(g.user["userId"], form_int("noteId"), form_int("noteIdx"))
    return jsonify(True)


@bp.route("/share", methods=["GET", "POST"])
@login_required
def share():
    friend_id, note_id = form("friendId", ""), form_int("noteId")
    if not has_note(g.user["userId"], note_id) or db.get_user(friend_id) is None:
        return jsonify(False)
    friend_notes = db.select_user_notes(user_id=friend_id)
    if any(un["noteId"] == note_id for un in friend_notes):
        return jsonify(False)
    note = db.select_note(note_id)
    db.update_note(note_id, share_cnt=note["shareCnt"] + 1)
    return jsonify(bool(db.insert_user_note(friend_id, note_id, len(friend_notes), 0)))


# 노트를 끌어서 옮기면 인덱스를 다시 매긴다. (NoteController.reAlign)
@bp.route("/reAlign", methods=["GET", "POST"])
@login_required
def re_align():
    origin_idx, change_idx = form_int("originIdx"), form_int("changeIdx")
    note_id, user_id = form_int("noteId"), g.user["userId"]
    is_last = form("isLast") == "true"

    db.update_user_note(user_id, note_id,
                        change_idx if origin_idx < change_idx or is_last else change_idx + 1)
    for un in db.select_user_notes(user_id=user_id):
        if un["noteId"] == note_id:
            continue
        idx = un["noteIdx"]
        if is_last:
            if change_idx <= idx <= origin_idx - 1:
                db.update_user_note(user_id, un["noteId"], idx + 1)
        elif origin_idx < change_idx:
            if origin_idx + 1 <= idx <= change_idx:
                db.update_user_note(user_id, un["noteId"], idx - 1)
        elif origin_idx > change_idx:
            if change_idx + 1 <= idx <= origin_idx - 1:
                db.update_user_note(user_id, un["noteId"], idx + 1)
    return jsonify(True)


@bp.route("/note", methods=["GET", "POST"])
@login_required
def note():
    note_id = form_int("noteId")
    if not has_note(g.user["userId"], note_id):
        abort(404)
    return render_template("note/note.html", noteId=note_id, noteIdx=form_int("noteIdx"),
                           pages=db.select_pages(note_id))


##################### PageController #####################

def page_of_mine(note_id, idx):
    page = db.select_page(note_id, idx)
    if page is None or not has_note(g.user["userId"], page["noteId"]):
        abort(404)
    return page


@bp.post("/page")
@login_required
def page():
    return render_template("page/page.html", page=page_of_mine(form_int("noteId"), form_int("pageIdx")))


@bp.route("/page/upContent", methods=["GET", "POST"])
@login_required
def up_content():
    row = db.get_db().execute("SELECT note_id FROM pages WHERE page_id = ?",
                              (form_int("id"),)).fetchone()
    if row is None or not has_note(g.user["userId"], row[0]):
        return jsonify(False)
    db.update_page(form_int("id"), [form(f"content{i}") for i in range(1, 6)])
    return jsonify(True)


@bp.route("/page/downContent", methods=["GET", "POST"])
@login_required
def down_content():
    note_id = form_int("noteId")
    if not has_note(g.user["userId"], note_id):
        return jsonify([])
    return jsonify(db.select_pages(note_id))


@bp.post("/page/upFile")
@login_required
def upload():
    f = request.files.get("uploadFile")
    name = os.path.basename((f.filename if f else "") or "").strip()
    if not name or name.startswith("."):
        return ""
    f.save(os.path.join(app.config["UPLOAD_DIR"], name))
    return name


##################### UserNoteController #####################

@bp.route("/userNote/get", methods=["GET", "POST"])
@login_required
def user_note_get():
    user_id, note_id = form("userId") or None, form_int("noteId")
    if note_id and not has_note(g.user["userId"], note_id):
        return jsonify([])
    if not note_id and user_id != g.user["userId"]:
        return jsonify([])
    return jsonify(db.select_user_notes(user_id=user_id, note_id=note_id))


# 공유 해제 (소유주가 친구를 빼거나, 내가 공유받은 노트에서 빠짐)
@bp.route("/userNote/delete", methods=["GET", "POST"])
@login_required
def user_note_delete():
    user_id, note_id = form("userId") or None, form_int("noteId")
    if not note_id or not (owns(g.user["userId"], note_id) or user_id == g.user["userId"]):
        return jsonify(False)
    db.delete_user_note(user_id=user_id, note_id=note_id)
    note = db.select_note(note_id)
    if note:
        db.update_note(note_id, share_cnt=note["shareCnt"] - 1)
    return jsonify(True)


# 소유권 넘기기 등 usernote 수정
@bp.route("/userNote/edit", methods=["GET", "POST"])
@login_required
def user_note_edit():
    note_id = form_int("noteId")
    me = g.user["userId"]
    # 소유권 넘기기는 "내 소유 해제 → 친구를 소유주로" 두 번에 나눠 오므로, 소유주가 없는 동안은 공유 멤버도 허용한다.
    orphan = has_note(me, note_id) and not any(
        un["isOwner"] == 1 for un in db.select_user_notes(note_id=note_id))
    if not note_id or not (owns(me, note_id) or orphan):
        return jsonify(False)
    db.update_user_note(form("userId") or None, note_id, form_int("noteIdx", -1),
                        form_int("isOwner", -1))
    return jsonify(True)


app.register_blueprint(bp)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="127.0.0.1", port=port, debug=True)
