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

## 엔드포인트 (기존 UserController와 동일)

| 메서드 | 경로 | 동작 |
|---|---|---|
| GET | `/` | 로그인 화면 |
| POST | `/` | `userId` 확인 후 세션에 저장, `true`/`false` |
| POST | `/passCheck` | 세션 사용자의 `userPw` 확인, `true`/`false` |
| GET | `/findPw` | 아이디 찾기 화면 (현재는 로그인 화면과 같은 내용) |
| GET | `/addUser` | 계정 만들기 화면 |
| POST | `/addUser` | `userName`, `userId`, `userPw`, `userEmail`로 가입, `true`/`false` |
| GET | `/main` | 메인(노트 선반) 화면 |

정적 파일은 `/static/img`, `/static/js` 아래에 있습니다.

## 기존 서버와 달라진 점

- DB: Oracle(192.168.0.67) 대신 로컬 SQLite 파일을 씁니다.
- 비밀번호는 평문 대신 해시로 저장합니다.
- 로그인/가입 후 이동 주소가 `http://localhost/solution/main`으로 고정돼 있던 것을 `/main`으로 바꿨습니다.
- 세션 없이 `/passCheck`를 호출하면 500 오류 대신 `false`를 돌려줍니다.
- 이미 있는 아이디로 가입하면 `false`를 돌려줍니다.
- 운영에 띄울 때는 `SECRET_KEY` 환경변수를 꼭 설정하세요.
