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
| `/main` | 내 노트 선반 (로그인 필요). 새 노트 만들기, 내 정보, 정보수정, 회원탈퇴, 로그아웃 |
| `/notes/<id>` | 노트 열기. 굵게/기울임/밑줄/목록/글자색/형광펜, 입력하면 자동 저장, 표지 색 바꾸기, 삭제 |

정적 파일은 `static/` 아래(`css/app.css` 공통 스타일, `css/note3d.css` 3D 노트, `js/shelf.js` 선반 정렬)에 있습니다.

## 기존 서버와 달라진 점

- DB: Oracle(192.168.0.67) 대신 로컬 SQLite 파일을 씁니다. 노트는 `notes` 테이블에 저장됩니다.
- 비밀번호는 평문 대신 해시로 저장합니다.
- 로그인은 아이디 → 비밀번호 두 단계 AJAX 대신 한 번에 제출하는 폼입니다. 틀리면 화면에 안내가 뜹니다.
- 메인의 노트는 고정된 6권 대신 내가 만든 노트가 꽂히고, 누르면 실제 노트 화면이 열립니다.
- jQuery/Bootstrap CDN 없이 동작합니다.
- 운영에 띄울 때는 `SECRET_KEY` 환경변수를 꼭 설정하세요.
