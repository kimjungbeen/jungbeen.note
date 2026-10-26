# jungbeen.note Python 서버

기존 Spring + MyBatis + Oracle 서버(`jungbeen.note/`)를 Flask + SQLite로 옮긴 버전입니다.

## 로컬 실행 (Mac)

```bash
cd server
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

브라우저에서 http://127.0.0.1:8080 을 엽니다. 포트를 바꾸려면 `PORT=5001 python app.py`.
DB는 처음 실행할 때 `server/note.db`(SQLite)로 자동 생성됩니다.

## 화면과 주소

| 주소 | 내용 |
|---|---|
| `/` | 로그인 (아이디와 비밀번호를 한 화면에서 입력) |
| `/addUser` | 계정 만들기 (비밀번호 4자 이상, 확인란 일치, 아이디 중복 확인) |
| `/findId` | 이메일로 아이디 찾기 (앞 한두 글자만 보여줌) |
| `/main` | 기존 메인 화면 그대로. 노트 선반, 사용자 정보, 회원정보 수정, 회원탈퇴, 로그아웃 |
| `/notes/<id>` | 노트 쓰기 화면 (책등을 누르면 열림). 입력하면 자동 저장 |

## 기존 서버와 달라진 점

- 메인 화면(`templates/main.html`)은 기존 JSP의 디자인과 코드를 그대로 두고, 끊겨 있던 기능만 연결했습니다.
  - 고정돼 있던 노트 6권은 같은 마크업으로 DB의 노트를 그립니다. 가입하면 기존 6색 노트가 기본으로 꽂힙니다.
  - 책등을 누르면 없는 `PAGES/01.html` 대신 노트 쓰기 화면이 열립니다.
  - 사용자 정보 창에 실제 이름/아이디/이메일이 나오고, 로그아웃·회원정보 수정·회원탈퇴 버튼이 동작합니다.
- 로그인/가입/아이디 찾기 화면은 메인의 노트 색과 살색 종이에 맞춰 새로 만들었고, 아이디 → 비밀번호 두 단계 대신 한 번에 제출하는 폼입니다.
- DB: Oracle(192.168.0.67) 대신 로컬 SQLite 파일을 쓰고, 비밀번호는 해시로 저장합니다.
- 운영에 띄울 때는 `SECRET_KEY` 환경변수를 꼭 설정하세요.
