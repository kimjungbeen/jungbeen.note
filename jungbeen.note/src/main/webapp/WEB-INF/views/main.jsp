<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
<script src="<c:url value="js/insertTag.js"/>"></script>
<script>
window.onload = function() {
	var notes = document.getElementsByClassName("note");
	var shelf = document.getElementsByClassName("shelf")[0];
	
	function getCssVar(variable) {
		return document.querySelector(":root").style.getPropertyValue("--" + variable);
	}
	
	function setCssVar(name, value) {
		document.querySelector(":root").style.setProperty("--" + name, value);
	}
	
	function alignNotes() {
		var stanSize = Number(getCssVar("note-standard-size").split("px")[0]);
		var shelfWidth = shelf.offsetWidth;
		var properNum = shelfWidth / (stanSize + stanSize * 0.4 + 5);

		//한 줄에 존재할 수 있는 적절한 노트의 갯수
		properNum = Math.floor(properNum);
		
		//선반의 너비 조정
		if(notes.length > properNum)
			setCssVar("shelf-support-width", properNum * (stanSize + stanSize * 0.4 + 5) + "px");
		else
			setCssVar("shelf-support-width", shelf.offsetWidth + "px");
		
		//받침의 적절한 갯수
		var supportNum = Math.ceil(notes.length / properNum);
		
		var supports = document.getElementsByClassName("support");
		for(var i = supports.length - 1; i >= 0; i--) {
			shelf.removeChild(supports[i]);
		}
		
		for(var i = 0; i < supportNum; i++) {
			var newSupport = document.createElement("div");
			newSupport.setAttribute("class", "support");

			if(supportNum - 1 == i) {
				shelf.appendChild(newSupport);
			} else {
				shelf.insertBefore(newSupport, notes[properNum * (i+1)].parentElement);
			}
		}
	}
	
	for(var i = 0; i < notes.length; i++) {
		notes[i].onmouseenter = function() {
			this.setAttribute("class", "note show-right");
		}
		notes[i].onmouseleave = function() {
			this.setAttribute("class", "note show-front");
		}
		notes[i].oncontextmenu = function(e) {
			e.stopPropagation();
			e.preventDefault();
			
			this.setAttribute("class", "note show-back");
		}
		notes[i].getElementsByClassName("right")[0].onclick = function() {
			window.location.href = "PAGES/01.html";
		}
	}
	
	if(window.innerWidth < 768) {
		setCssVar("note-standard-size", "50px");
	} else {
		setCssVar("note-standard-size", "100px");
	}
	
	alignNotes();
	
	window.onresize = function() {
		if(window.innerWidth < 768) {
			document.querySelector(":root").style.setProperty("--note-standard-size", "50px");
		} else {
			setCssVar("note-standard-size", "100px");
		}
		
		alignNotes();
	}
	
}
$(function() {
	$("#modal2").bind("click", function(){
		$('#myModal2').modal('hide');
	});
});
</script>
<style>
	:root {
		--note-color:black;
		--note-line-color:gray;
		--note-page-color:var(--부드러운-살색);
		--note-name-color:black;
		
		/*이 값이 note의 각 면을 구성하는 요소들의 길이 비율의 기준이 된다.*/
		--note-standard-size:100px;
		
		--shelf-support-width:;
		--shelf-support-shadow-color:#D8D8D8;
		
		--background-color:#D8D8D8;
		
		--부드러운-살색:#F8ECE0;
		--연한-회색:#D8D8D8;
	}
	.scene {
		display:inline-block;
		
		width:var(--note-standard-size);
		height:calc(var(--note-standard-size) * 1.5);
		
		margin:0px
			calc(var(--note-standard-size) * 0.2)
			0px
			calc(var(--note-standard-size) * 0.2);
		
		perspective:calc(var(--note-standard-size) * 10);
		transition-duration:0.5s;
	}
	.scene .note {
		position:relative;
		
		width:100%;
		height:100%;
		
		transition-duration:0.5s;
		transform-style:preserve-3d;
	}
	.scene .note .side {position:absolute; transition-duration:0.5s;}
	.scene .note .front {
		width:var(--note-standard-size);
		height:calc(var(--note-standard-size) * 1.5);
		border-radius:
			0px 
			calc(var(--note-standard-size) * 0.05) 
			calc(var(--note-standard-size) * 0.05) 
			0px;
		background-color:var(--note-color, red);
	}
	.scene .note .front .name {
		position:absolute;
		display:inline;
		
		width:calc(var(--note-standard-size) * 0.8 - (var(--note-standard-size) * 0.1));
		height:calc(var(--note-standard-size) * 1.5 - (var(--note-standard-size) * 0.1));
		
		padding:calc(var(--note-standard-size) * 0.05);
		
		font-size:calc(var(--note-standard-size) * 0.2);
		color:var(--note-name-color);
		
		overflow:hidden;
		
		transition-duration:0.5s;
	}
	.scene .note .line,
	.scene .note .line-up,
	.scene .note .line-down {
		position:absolute;
		background-color:var(--note-line-color);
		transition-duration:0.5s;
	}
	.scene .note .front .line {
		left:calc(var(--note-standard-size) * 0.8);
		width:calc(var(--note-standard-size) * 0.1);
		height:calc(var(--note-standard-size) * 1.5);
	}
	.scene .note .back {
		width:var(--note-standard-size);
		height:calc(var(--note-standard-size) * 1.5);
		border-radius:
			calc(var(--note-standard-size) * 0.05)
			0px
			0px
			calc(var(--note-standard-size) * 0.05);
		background-color:var(--note-color, orange);				
	}
	.scene .note .back .line-up,
	.scene .note .back .line-down {
		left:calc(var(--note-standard-size) * 0.1);
		width:calc(var(--note-standard-size) * 0.1);
		height:calc(var(--note-standard-size) * 0.2);
	}
	.scene .note .back .line-up {}
	.scene .note .back .line-down {top:calc(var(--note-standard-size) * 1.5 - var(--note-standard-size) * 0.2);}
	.scene .note .right {
		left:calc(var(--note-standard-size) * 0.5
			- var(--note-standard-size) * 0.2 * 0.5);
		width:calc(var(--note-standard-size) * 0.2);
		height:calc(var(--note-standard-size) * 1.5);
		
		cursor:pointer;
	}
	.scene .note .cover {
		position:absolute;
		background-color:var(--note-color, yellow);	
		
		transition-duration:0.5s;		
	}
	.scene .note .page {
		position:absolute;
		background-color:var(--note-page-color);
		
		transition-duration:0.5s;
	}
	.scene .note .right .cover {
		top:calc(var(--note-standard-size) * 0.05);
		width:calc(var(--note-standard-size) * 0.025);
		height:calc(var(--note-standard-size) * 1.4);
	}
	.scene .note .right .cover:first-child {}
	.scene .note .right .cover:last-child {left:calc(var(--note-standard-size) * 0.175);}
	.scene .note .right .page {
		top:calc(var(--note-standard-size) * 0.05);
		left:calc(var(--note-standard-size) * 0.025);
		width:calc(var(--note-standard-size) * 0.15);
		height:calc(var(--note-standard-size) * 1.4);
	}
	.scene .note .left {
		left:calc(var(--note-standard-size) / 2
			- var(--note-standard-size) * 0.2 / 2);
		width:calc(var(--note-standard-size) * 0.2);
		height:calc(var(--note-standard-size) * 1.5);
		background-color:var(--note-color, green);
	}
	.scene .note .up {
		top:calc(var(--note-standard-size) *1.5 / 2
			- var(--note-standard-size) * 0.2 / 2);
		width:var(--note-standard-size);
		height:calc(var(--note-standard-size) * 0.2);
	}
	.scene .note .cover-side {
		position:absolute;
		transition-duration:0.5s;
	}
	.scene .note .up .cover-side {
		width:calc(var(--note-standard-size) 0.025);
		height:calc(var(--note-standard-size) * 0.2);
	}
	.scene .note .up .cover {
		left:calc(var(--note-standard-size) * 0.025);
		width:calc(var(--note-standard-size) * 0.925);
		height:calc(var(--note-standard-size) * 0.025);
	}
	.scene .note .up .cover:first-child {}
	.scene .note .up .cover:last-child {top:calc(var(--note-standard-size) * 0.175);}
	.scene .note .up .page {
		left:calc(var(--note-standard-size) * 0.025);
		top:calc(var(--note-standard-size) * 0.025);
		width:calc(var(--note-standard-size) * 0.925);
		height:calc(var(--note-standard-size) * 0.15);
	}
	.scene .note .up .line {
		left:calc(var(--note-standard-size) * 0.8);
		width:calc(var(--note-standard-size) * 0.1);
		height:calc(var(--note-standard-size) * 0.2);
	}
	.scene .note .down {
		top:calc(var(--note-standard-size) * 1.5 / 2
			- var(--note-standard-size) * 0.2 / 2);
		width:var(--note-standard-size);
		height:calc(var(--note-standard-size) * 0.2);
	}
	.scene .note .down .cover-side {
		width:calc(var(--note-standard-size) * 0.025);
		height:calc(var(--note-standard-size) * 0.2);
	}
	.scene .note .down .cover {
		left:calc(var(--note-standard-size) * 0.025);
		width:calc(var(--note-standard-size) * 0.925);
		height:calc(var(--note-standard-size) * 0.025);
	}
	.scene .note .down .cover:first-child {}
	.scene .note .down .cover:last-child {top:calc(var(--note-standard-size) * 0.175);}
	.scene .note .down .page {
		left:calc(var(--note-standard-size) * 0.025);
		top:calc(var(--note-standard-size) * 0.025);
		width:calc(var(--note-standard-size) * 0.925);
		height:calc(var(--note-standard-size) * 0.15);
	}
	.scene .note .down .line {
		left:calc(var(--note-standard-size) * 0.8);
		width:calc(var(--note-standard-size) * 0.1);
		height:calc(var(--note-standard-size) * 0.2);
	}
	.scene .note .edge-up, 
	.scene .note .edge-down {
		width:calc(var(--note-standard-size) * 0.2);
		height:calc(var(--note-standard-size) * 0.07071067811865475244008443621048);
	}
	.scene .note .edge-up .cover, 
	.scene .note .edge-down .cover {
		width:calc(var(--note-standard-size) * 0.025);
		height:calc(var(--note-standard-size) * 0.07071067811865475244008443621048);
		background-color:var(--note-color, blue);
	}
	.scene .note .edge-up .cover:first-child, 
	.scene .note .edge-down .cover:first-child {}
	.scene .note .edge-up .cover:first-child, 
	.scene .note .edge-down .cover:first-child {
		left:calc(var(--note-standard-size) * 0.175);
	}
	.scene .note .edge-up .page,
	.scene .note .edge-down .page {
		left:calc(var(--note-standard-size) * 0.025);
		width:calc(var(--note-standard-size) * 0.15);
		height:calc(var(--note-standard-size) * 0.07071067811865475244008443621048);
	}
	.scene .note .front {transform:rotateY(0deg) translateZ(calc(var(--note-standard-size) * 0.2 / 2));}
	.scene .note .back {transform:rotateY(180deg) translateZ(calc(var(--note-standard-size) * 0.2 / 2));}
	.scene .note .right {transform:rotateY(90deg) translateZ(calc(var(--note-standard-size) / 2));}
	.scene .note .left {transform:rotateY(-90deg) translateZ(calc(var(--note-standard-size) / 2));}
	.scene .note .up {transform:rotateX(90deg) translateZ(calc(var(--note-standard-size) * 1.5 / 2));}
	.scene .note .down {transform:rotateX(-90deg) translateZ(calc(var(--note-standard-size) * 1.5 / 2));}
	.scene .note .edge-up {
		left:calc(var(--note-standard-size) - var(--note-standard-size) * 0.2 / 2 - var(--note-standard-size) * 0.05 / 2);
		top:calc(var(--note-standard-size) * 0.07071067811865475244008443621048 / -2 + var(--note-standard-size) * 0.05 / 2);
		transform:rotateY(90deg) rotateX(45deg);
	}
	.scene .note .edge-down {
		left:calc(var(--note-standard-size) - var(--note-standard-size) * 0.2 / 2 - var(--note-standard-size) * 0.05 / 2);
		top:calc(var(--note-standard-size) * 1.5 - var(--note-standard-size) * 0.07071067811865475244008443621048 / 2 - var(--note-standard-size) * 0.05 / 2);
		transform:rotateY(90deg) rotateX(-45deg);
	}
	
	.show-front {transform:rotateY(0deg);}
	.show-back {transform:rotateY(180deg);}
	.show-right {transform:rotateY(-90deg);}
	.show-left {transform:rotateY(90deg);}
	.show-up {transform:rotateX(-90deg);}
	.show-down {transform:rotateX(90deg);}
	.show-edge-up {transform:otateY(-90deg) rotateZ(45deg);}
	.show-edge-down {transform:rotateY(-90deg) rotateZ(-45deg);}
	.show-custom  {transform:rotate(45deg, 45deg)}
	
	.shelf {
		margin:calc(var(--note-standard-size) * 0.25);
	}
	.shelf .support {
		width:var(--shelf-support-width);
		height:calc(var(--note-standard-size) / 10);
		
		margin-bottom:calc(var(--note-standard-size) * 0.25);
		
		box-shadow:0px 0px 5px 1px var(--shelf-support-shadow-color);
		transition-duration:0.5s;
	}
	h2 {
		float:left;
	}
	.userinf{
		position:fixed;
		left:calc(99.5% - 45px);
		top:0.5%;
		height: 45px;
		width: 45px;
		border-radius: 100px;
		/*box-shadow: 0px 0px 50px 1px rgba(0,0,0,0.4);*/
	}
	#myModal {
		 overflow: auto;
	}		
	#myModal12 {
 		 overflow: auto;
	}
</style>
</head>
<body>

		
<!-- 사용자정보 관리 목록 -->
<a data-toggle="modal" href="#myModal" class="userinf">
	<img src="<c:url value="/img/usericon.jpg"/>" class="userinf">
</a>
	
<!-- 노트 -->
<br>
<br>
<br>
<br>

<div class="shelf">
		<div class="scene" style="--note-color:#F5A9A9;">
			<div class="note">
				<div class="side front">
					<div class="name"></div>
					<div class="line"></div>
				</div>
				
				<div class="side back">
					<div class="line-up"></div>
					<div class="line-down"></div>
				</div>
				
				<div class="side right">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side left"></div>
				
				<div class="side up">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
			</div>
		</div>
		
		<div class="scene" style="--note-color:#CEECF5;">
			<div class="note">
				<div class="side front">
					<div class="name"></div>
					<div class="line"></div>
				</div>
				
				<div class="side back">
					<div class="line-up"></div>
					<div class="line-down"></div>
				</div>
				
				<div class="side right">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side left"></div>
				
				<div class="side up">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
			</div>
		</div>
		
		<div class="scene" style="--note-color:#E6E6E6;">
			<div class="note">
				<div class="side front">
					<div class="name"></div>
					<div class="line"></div>
				</div>
				
				<div class="side back">
					<div class="line-up"></div>
					<div class="line-down"></div>
				</div>
				
				<div class="side right">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side left"></div>
				
				<div class="side up">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
			</div>
		</div>
		
		<div class="scene" style="--note-color:#F6CEE3;">
			<div class="note">
				<div class="side front">
					<div class="name"></div>
					<div class="line"></div>
				</div>
				
				<div class="side back">
					<div class="line-up"></div>
					<div class="line-down"></div>
				</div>
				
				<div class="side right">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side left"></div>
				
				<div class="side up">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
			</div>
		</div>
		
		<div class="scene" style="--note-color:#F5F6CE;">
			<div class="note">
				<div class="side front">
					<div class="name"></div>
					<div class="line"></div>
				</div>
				
				<div class="side back">
					<div class="line-up"></div>
					<div class="line-down"></div>
				</div>
				
				<div class="side right">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side left"></div>
				
				<div class="side up">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
			</div>
		</div>
		
		<div class="scene" style="--note-color:#D8F6CE;">
			<div class="note">
				<div class="side front">
					<div class="name"></div>
					<div class="line"></div>
				</div>
				
				<div class="side back">
					<div class="line-up"></div>
					<div class="line-down"></div>
				</div>
				
				<div class="side right">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side left"></div>
				
				<div class="side up">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
			</div>
		</div>
		
		<div class="support"></div>
	</div>	

	<!-- user10 -->
	<div class="modal" id="myModal" aria-hidden="true" style="display: none; z-index: 1050;">
		<div class="modal-dialog modal-lg">
			<div class="modal-content">			
				<div class="modal-body">	
					<p>(이름)</p>
					<p>(아이디)</p>
					<p>(이메일 주소)</p>
				</div>
				<div class="modal-footer">
					<a data-toggle="modal" href="#myModal2" class="btn btn-primary">정보수정</a>
					<a href="USERS/00.html" class="btn btn-primary">로그아웃</a>
				</div>
			</div>
		</div>
	</div>

	<!-- user11 -->
	<div class="modal" id="myModal2" aria-hidden="true" style="display: none; z-index: 1060;">
		<div class="modal-dialog modal-lg">
			<div class="modal-content">
				<div class="modal-header">
					<h4 class="modal-title">회원정보 수정</h4>
				</div>
				<div class="container"></div>
				<div class="modal-body">
					<p>아이디      <input type="text" placeholder="(등록된 아이디)"/></p>
					<p>비밀번호    <input type="text" placeholder="(등록된 아이디)"/><button>비밀번호 확인</button></p>
					<p>이름        <input type="text" placeholder="(등록된 이름)"/></p>
					<p>이메일 주소 <input type="text" placeholder="(등록된 이메일)"/></p>
					<p><a href="#" class="btn btn-primary">수정</a></p>
				</div>
				<div class="modal-footer">
					<a href="#" data-dismiss="modal" class="btn">취소</a>
					<a data-toggle="modal" href="#myModal3" class="btn btn-primary" id="modal2">회원탈퇴</a>
				</div>
			</div>
		</div>
	</div>

	<!-- user12 -->
	<div class="modal" id="myModal3" aria-hidden="true" style="display: none; z-index: 1060;">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h4 class="modal-title">회원 탈퇴 이유를 선택해 주세요</h4>
				</div>
				<div class="modal-body">
					<ul>
						<label><input type="checkbox"/>컨텐츠 부족</label><br>
						<label><input type="checkbox"/>서비스 이용 불편</label><br> 
						<label><input type="checkbox"/>
							<textarea rows="1" cols="30" placeholder="기타 탈퇴 이유를 직접 입력"></textarea>
						</label>
					</ul>
	
					<p>회원 탈퇴 시 작성 한 노트는 모두 삭제되며, 복구가 불가능합니다.</p>
					<p>회원 정보 및 기타 개인정보는 탈퇴 즉시 삭제됩니다.</p>
					
					<p><label><input type="checkbox" required />위 내용을 확인하였으며, 탈퇴를 진행합니다.</label></p>

				</div>
				<div class="modal-footer">
					<a href="#" data-dismiss="modal" class="btn">취소</a>
					<a href="USERS/00.html" class="btn btn-primary">사용자 정보가 삭제됩니다</a>
				</div>
			</div>
		</div>
	</div>
	

</body>
</html>