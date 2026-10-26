# jungbeen.note Python 서버

2018-09-14 버전의 Spring + MyBatis + Oracle 서버를 Flask + SQLite로 옮긴 버전입니다.
화면(JSP)과 JS/CSS/이미지는 원본을 그대로 쓰고, 서버 쪽만 바꿨습니다.

## 로컬 실행 (Mac)

```bash
cd server
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

브라우저에서 http://127.0.0.1:8080 을 열면 `/note/` 로그인 화면으로 갑니다. 포트를 바꾸려면 `PORT=5001 python app.py`.
DB는 처음 실행할 때 `server/note.db`(SQLite)로 자동 생성되고, 페이지에 끌어다 놓은 파일은 `server/upload/`에 저장됩니다.

비밀번호 찾기 메일을 실제로 보내려면 `MAIL_USERNAME`, `MAIL_PASSWORD`(Gmail 앱 비밀번호) 환경변수를 설정하세요.
설정하지 않으면 메일 내용(임시 비밀번호)이 서버 로그에 찍힙니다.

## 구조

| 원본 (Spring) | 이식 |
|---|---|
| `UserController`, `NoteController`, `PageController`, `UserNoteController` | `app.py` (원본처럼 모든 주소가 `/note/...` 아래) |
| MyBatis 매퍼 4개 | `db.py` |
| Oracle 테이블 `users`, `notes`, `pages`, `usernote` | `schema.sql` |
| `WEB-INF/views/*.jsp` | `templates/*.html` (스크립틀릿만 Jinja로) |
| `WEB-INF/resources/{css,js,img}` | `static/` |

## 원본과 달라진 점

- 템플릿: JSP 스크립틀릿(`<%= %>`, `${}`)을 Jinja 문법으로 바꾸고, `http://localhost/note/...`로 박혀 있던 주소를 `/note/...`로 바꿨습니다.
- 버그 수정
  - `utility.js`의 `ajax()`가 값을 URL 인코딩하지 않아 `&`, `+`가 들어간 페이지 내용이 잘리던 문제를 고쳤고, 이를 피하려고 `&...;`를 지우던 `page.jsp`의 우회 코드를 뺐습니다.
  - 페이지 내용 5조각을 이어 붙일 때 사이에 줄바꿈이 끼어들던 것을 없앴습니다.
  - 화면에 그대로 보이던 디버그 출력(노트 meta 정보, 노트 화면 좌상단의 노트 번호)을 숨겼습니다.
- 보안
  - 비밀번호는 해시로 저장합니다. 그래서 비밀번호 찾기는 원래 비밀번호 대신 임시 비밀번호를 만들어 메일로 보냅니다.
  - 아이디만 입력해도 `/note/main`에 들어갈 수 있던 문제를 막고, 비밀번호까지 맞아야 로그인됩니다.
  - 정보 변경·탈퇴는 쿠키의 `userId` 대신 로그인 세션의 사용자로 처리하고, 남의 노트/페이지는 열거나 고칠 수 없습니다.
  - 업로드 파일 이름에서 경로를 떼어 냅니다.
- 회원탈퇴 시 내 노트와 공유 정보도 함께 정리합니다.
- 운영에 띄울 때는 `SECRET_KEY` 환경변수를 꼭 설정하세요.
