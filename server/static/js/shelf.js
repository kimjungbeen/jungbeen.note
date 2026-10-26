// 선반 위 노트 정렬과 노트 회전 효과 (기존 main.jsp 스크립트)
window.addEventListener("load", function() {
	var notes = document.getElementsByClassName("note");
	var shelf = document.getElementsByClassName("shelf")[0];
	if(!shelf) return;

	function getCssVar(variable) {
		return document.querySelector(":root").style.getPropertyValue("--" + variable);
	}

	function setCssVar(name, value) {
		document.querySelector(":root").style.setProperty("--" + name, value);
	}

	function alignNotes() {
		var stanSize = Number(getCssVar("note-standard-size").split("px")[0]);
		var shelfWidth = shelf.offsetWidth;

		//한 줄에 존재할 수 있는 적절한 노트의 갯수
		var properNum = Math.max(1, Math.floor(shelfWidth / (stanSize + stanSize * 0.4 + 5)));

		//선반의 너비 조정
		if(notes.length > properNum)
			setCssVar("shelf-support-width", properNum * (stanSize + stanSize * 0.4 + 5) + "px");
		else
			setCssVar("shelf-support-width", shelf.offsetWidth + "px");

		//받침의 적절한 갯수
		var supportNum = Math.max(1, Math.ceil(notes.length / properNum));

		var supports = shelf.getElementsByClassName("support");
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

	function resize() {
		setCssVar("note-standard-size", window.innerWidth < 768 ? "60px" : "100px");
		alignNotes();
	}

	for(var i = 0; i < notes.length; i++) {
		notes[i].onmouseenter = function() {
			this.setAttribute("class", "note show-right");
		};
		notes[i].onmouseleave = function() {
			this.setAttribute("class", "note show-front");
		};
		notes[i].oncontextmenu = function(e) {
			e.stopPropagation();
			e.preventDefault();
			this.setAttribute("class", "note show-back");
		};
		//책등이나 표지를 누르면 노트를 연다.
		notes[i].onclick = function() {
			window.location.href = this.parentElement.getAttribute("data-href");
		};
	}

	resize();
	window.onresize = resize;
});
