<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
<script>
$(function(){
	var $inputPw = $("input[name='userPw']"); //비밀번호 입력
	var $checkPw = $("input[name='checkPw']"); //비밀번호 확인
	
	$("#pwCheck").bind("click", function(){
		var inputPw = $("input[name='userPw']").val();
		var checkPw = $("input[name='checkPw']").val();
		
		if(inputPw == checkPw){
			$("#pwCheck").css('display','none');
			alert("비밀번호 확인완료")
		}else{
			alert("틀림")
		}
	});
	
	$("#next").bind("click", function(){
		$.ajax({
			method: "post",
			data:$("#userData").serialize(),
			success:function(result){
				if(result){
					window.location.href="http://localhost/solution/main";
				}else{
					alert("올바른 pw를 입력하세요.")
				}
			},
			error:function(){
				alert("서버 에러");
			}
		})
	})
	
})
</script>
<style>
div{
	position: absolute; 
  	left: 0; 
 	right: 0; 
 	top: 0;
 	bottom: 0;
  	margin: auto; /* margin 상 우 하 좌 (시계방향) 바깥쪽 여백  중앙에 위치하게 할라면 위에처럼 0으로 선언하고 auto*/
	width:500px;
	height:600px;
	border: none;
	padding: 5% 5% 5% 5%; /* 안쪽 여백 */
	
	box-shadow:0px 0px 10px 1px #D8D8D8; /* 그림자 */
}

input{
	width:150px;
	display:inline;
}

<!-- input창 변화 시작 -->
html,body {
  height: 100%;
}
body {
  display: grid;
  font-family: Avenir;
  -webkit-text-size-adjust: 100%;
	-webkit-font-smoothing: antialiased;
}

* {
  box-sizing: border-box;
}
.inp {
  position: relative;
  margin: auto;
  width: 100%;
  max-width: 280px;
}
.inp .label {
  position: absolute;
  top: 16px;
  left: 0;
  font-size: 16px;
  color: #9098a9;
  font-weight: 500;
  transform-origin: 0 0;
  transition: all 0.2s ease;
}
.inp .border {
  position: absolute;
  bottom: 0;
  left: 0;
  height: 2px;
  width: 100%;
  background: #0077FF;
  transform: scaleX(0);
  transform-origin: 0 0;
  transition: all 0.15s ease;
}

.inp input {
  -webkit-appearance: none;
  width: 100%;
  border: 0;
  font-family: inherit;
  padding: 12px 0;
  height: 48px;
  font-size: 16px;
  font-weight: 500;
  border-bottom: 2px solid #c8ccd4;
  background: none;
  border-radius: 0;
  color: #223254;
  transition: all 0.15s ease;
}
.inp input:hover {
  background: rgba(#223254,0.03);
}
.inp input:not(:placeholder-shown) + span {
  color: #5a667f;
  transform: translateY(-26px) scale(0.75);
}
.inp input:focus {
  background: none;
  outline: none;
}
.inp input:focus + span {
  color: #0077FF;
  transform: translateY(-26px) scale(0.75);
}
.inp input:focus + span + .border {
  transform: scaleX(1);
}
<!-- input창 변화 끝 -->

</style>
</head>
<body>
<form method="post" id="userData">
	<div>
		<h1>노트공유</h1>
		<h3>계정만들기</h3>
		<label for="inp" class="inp"><input type="text" name="userName" placeholder="&nbsp;"><span class="label">이름</span><span class="border"></span></label>
		<label for="inp" class="inp"><input type="text" name="userId" placeholder="&nbsp;"><span class="label">아이디</span><span class="border"></span></label>
		<label for="inp" class="inp"><input type="password" name="userPw" placeholder="&nbsp;"><span class="label">비밀번호</span><span class="border"></span></label>
		<label for="inp" class="inp"><input type="password" name="checkPw" placeholder="&nbsp;"><span class="label">비밀번호확인</span><span class="border"></span></label>
		<button type="button" id="pwCheck">중복확인</button>
		<label for="inp" class="inp"><input type="email" name="userEmail" placeholder="&nbsp;"><span class="label">이메일</span><span class="border"></span></label>
	
		<button type="button" formaction="/">있는 계정으로 로그인</button>
		<button type="button" id="next">다음</button>

	</div>
</form>
</body>
</html>