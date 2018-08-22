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
	var $inputText = $("input[type='text']"); //아이디 입력창
	var $inputPass = $("input[type='password']"); //비밀번호 입력창
	
	$("#next").bind("click", function(){
		
		if($("#id").css('display') == "block"){
			$.ajax({
				method: "post",
				data:{
					userId:$inputText.val()
				},
				success:function(result){
					var userId = $inputText.val()
					if(result){
						$("#id").css('display','none');
						$("#pw").css('display','block');
						$("p").append(userId);
					}else{
						alert("올바른 id를 입력하세요.")
					}
				},
				error:function(){
					alert("서버 오류");
				}
			});
		}else{
			$.ajax({
				method: "post",
				url:"passCheck",
				data:{
					userPw:$inputPass.val()
				},
				success:function(result){
					if(result){
						window.location.href="http://localhost/solution/main";
					}else{
						alert("올바른 pw를 입력하세요.")
					}
				},
				error:function(){
					alert("서버오류");
				}
			})
		}
	});
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

#id{
	display: block;
}

#pw{
	display: none;
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

<form method="post">
	<div>
		<h1>노트공유</h1>
		<h3>로그인</h3>
		<p></p>
		<label for="inp" class="inp" id="id"><input type="text" name="userId" placeholder="&nbsp;"><span class="label">아이디</span><span class="border"></span></label>
		<label for="inp" class="inp" id="pw"><input type="password" name="userPw" placeholder="&nbsp;"><span class="label">비밀번호</span><span class="border"></span></label>	
		<button type="button" onclick="location='findPw'">아이디를 잊으셨나요?</button>
		<button type="button" onclick="location='addUser'">계정만들기</button><br>
		<button type="button" id="next">다음</button>
	</div>
</form>
</body>
</html>