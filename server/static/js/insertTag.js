//option = {baseElement:”...”, selection:window.getSelection(), tagName:”...”, attr:[{name:”...”, value:”...”}, {name:”...”, value:”...”}, ...]}
function insertTag(option) {
    var baseElement = option.baseElement;
    var tag = option.tagName;
    
    var attr = "";
    if (option.attr != undefined) {
    	for(var i = 0; i < option.attr.length; i++) {
    		attr += " " + option.attr[i].name + "='" + option.attr[i].value + "'";
    	}
    }

	var sel = document.getSelection();
	if(option.selection != undefined)
		sel = option.selection;

	if(!sel.isCollapsed) {

		var range = sel.getRangeAt(0);
		
		//선택된 text의 index
		var startIdx = range.startOffset;

		var childNodes;
		var preNode;

		var currNode = range.startContainer;
		var parentNode = currNode.parentElement;
		var parentNodeCnt = 1;
		while(parentNode != baseElement) {
			parentNode = parentNode.parentElement;
			parentNodeCnt++;
		}

		parentNode = range.startContainer.parentElement;
		while(parentNodeCnt != 0) {

			childNodes = parentNode.childNodes;

			preNode = currNode.previousSibling;

			currNode = parentNode;

			parentNode = parentNode.parentElement;

			var preNodeCnt = 0;
			while(preNode != null) {
				preNodeCnt++;
				preNode = preNode.previousSibling;
			}

			for(var i = 0; i < preNodeCnt; i++) {
				if(childNodes[i].nodeName == "#text") {
					startIdx += childNodes[i].length;
				} else {
				    startIdx += childNodes[i].innerText.length;
				}
			}

			parentNodeCnt--;
		}

		var endIdx = startIdx + sel.toString().length;

		var baseElementHTML = baseElement.innerHTML;
 
		var brTagsCnt = 0; // <br>의 도입 부분에서 text의 &nbsp; 가 html에서는 인식되지 않는 문제를 해결하기 위함.
		var isBrTag = false; //<br>이 text에서는 문자열 1개로 인식되지만 이 프로그램의 알고리즘으로는 인식되지 않는 문제를 해결하기 위함.
		var isNBSP = false; //띄어쓰기가 html에서 &nbsp;로 인식되는 경우, 띄어쓰기 문자열의 길이 1이 인식되지 않는 문제를 해결하기 위함.

		//0 ~ startIndex
		var htmlIdx = 0;
		if(startIdx != 0) {
		    do {
			    if (baseElementHTML.charAt(htmlIdx) == "<") {

			        if (baseElementHTML.charAt(htmlIdx + 1) == "b")
			            if (baseElementHTML.charAt(htmlIdx + 2) == "r")
			                if (baseElementHTML.charAt(htmlIdx + 3) == ">") {
			                    isBrTag = true;
			                }

					while(baseElementHTML.charAt(htmlIdx) != ">") {
						startIdx++;
						endIdx++;
						htmlIdx++;
						
						if(startIdx < htmlIdx) break;
					}

					if (isBrTag) {
					    startIdx--;
					    endIdx--;
					    isBrTag = false;
					}

					startIdx++;
					endIdx++;
					htmlIdx++;
					
					if(startIdx < htmlIdx) break;

				} else if (baseElementHTML.charAt(htmlIdx) == "&") {

				    if (baseElementHTML.charAt(htmlIdx + 1) == "n")
				        if (baseElementHTML.charAt(htmlIdx + 2) == "b")
				            if (baseElementHTML.charAt(htmlIdx + 3) == "s")
				                if (baseElementHTML.charAt(htmlIdx + 4) == "p")
				                    if (baseElementHTML.charAt(htmlIdx + 5) == ";")
				                        isNBSP = true;

					while(baseElementHTML.charAt(htmlIdx) != ";") {
						startIdx++;
						endIdx++;
						htmlIdx++;
						
						if(startIdx < htmlIdx) break;
					}

					if (isNBSP) {
					    endIdx--;
					    startIdx--;
					    isNBSP = false;
					}

					startIdx++;
					endIdx++;
					htmlIdx++;
					
					if(startIdx < htmlIdx) break;

				} else {
				    htmlIdx++;
				    
				    if(startIdx < htmlIdx) break;
				}
		    } while (htmlIdx != startIdx);

			baseElementHTML = baseElementHTML.substr(0, startIdx) + "<" + tag + attr + ">" + baseElementHTML.substr(startIdx, baseElementHTML.length);
			htmlIdx += tag.length + attr.length + 2;
			endIdx += tag.length + attr.length + 2;

		} else {

			baseElementHTML = "<" + tag + attr + ">" + baseElementHTML;
			htmlIdx += tag.length + attr.length + 2;
			endIdx += tag.length + attr.length + 2;

		}

		//startIndex ~ endIndex
	    //htmlIdx;
		brTagsCnt = 0;
		do {
			if(baseElementHTML.charAt(htmlIdx) == "<") {
				baseElementHTML = baseElementHTML.substr(0, htmlIdx) + "</" + tag + ">" + baseElementHTML.substr(htmlIdx, baseElementHTML.length);
				htmlIdx += tag.length + 3;
				endIdx += tag.length + 3;
			}

			if(baseElementHTML.charAt(htmlIdx) == "<") {

				if(baseElementHTML.charAt(htmlIdx + 1) == "b")
					if(baseElementHTML.charAt(htmlIdx + 2) == "r")
					    if (baseElementHTML.charAt(htmlIdx + 3) == ">") {
					        isBrTag = true;
					        brTagsCnt++;
					    }

				while(baseElementHTML.charAt(htmlIdx) != ">") {
				    endIdx++;
					htmlIdx++;
					
					if(endIdx < htmlIdx) break;
				}

				if (isBrTag) {
				    endIdx--;
				    isBrTag = false;
				}

				if (brTagsCnt == 1) {
				    endIdx--;
				    brTagsCnt++;
				}

				htmlIdx++;
				endIdx++;

				baseElementHTML = baseElementHTML.substr(0, htmlIdx) + "<" + tag + attr + ">" + baseElementHTML.substr(htmlIdx, baseElementHTML.length);
				htmlIdx += tag.length + attr.length + 2;
				endIdx += tag.length + attr.length + 2;
				
				if(endIdx < htmlIdx) break;

			} else if(baseElementHTML.charAt(htmlIdx) == "&") {

			    if (baseElementHTML.charAt(htmlIdx + 1) == "n")
			        if (baseElementHTML.charAt(htmlIdx + 1) == "b")
			            if (baseElementHTML.charAt(htmlIdx + 1) == "s")
			                if (baseElementHTML.charAt(htmlIdx + 1) == "p")
			                    if (baseElementHTML.charAt(htmlIdx + 1) == ";")
			                        isNBSP = true;

				while(baseElementHTML.charAt(htmlIdx) != ";") {
					endIdx++;
					htmlIdx++;
					
					if(endIdx < htmlIdx) break;
				}

				if (isNBSP) {
				    endIdx--;
				    isNBSP = false;
				}
				
				if(endIdx < htmlIdx) break;

			} else {

			    htmlIdx++;

			    if (brTagsCnt != 0) {
			        brTagsCnt = 0;
			    }
			    
			    if(endIdx < htmlIdx) break;
			}
		} while(htmlIdx != endIdx);

		baseElementHTML = baseElementHTML.substr(0, endIdx) + "</" + tag + ">" + baseElementHTML.substr(endIdx, baseElementHTML.length);
		baseElement.innerHTML = baseElementHTML;
		
	//anchor와 focus가 동일한 경우, range는 존재하지 않는다.
	//이렇게 되면, 기존의 startIdx를 구하는 방식에서는 range를 사용하므로
	//startIdx를 구할 수 없게된다.
	//따라서 아래의 코드는 range의 startContainer대신
	//selection의 anchorNode를 사용한다.
	} else {
		
		//선택된 text의 index
		var startIdx = sel.anchorOffset;
		
		var childNodes;
		var preNode;

		var currNode = sel.anchorNode;
		var parentNode = currNode.parentElement;
		var parentNodeCnt = 1;
		while(parentNode != baseElement) {
			parentNode = parentNode.parentElement;
			parentNodeCnt++;
		}

		parentNode = currNode.parentElement;
		while(parentNodeCnt != 0) {

			childNodes = parentNode.childNodes;

			preNode = currNode.previousSibling;

			currNode = parentNode;

			parentNode = parentNode.parentElement;

			var preNodeCnt = 0;
			while(preNode != null) {
				preNodeCnt++;
				preNode = preNode.previousSibling;
			}

			for(var i = 0; i < preNodeCnt; i++) {
				if(childNodes[i].nodeName == "#text") {
					startIdx += childNodes[i].length;
				} else {
				    startIdx += childNodes[i].innerText.length;
				}
			}

			parentNodeCnt--;
		}
		
		var baseElementHTML = baseElement.innerHTML;
		
		//0 ~ startIndex
		var htmlIdx = 0;
		if(startIdx != 0) {
		    do {
			    if (baseElementHTML.charAt(htmlIdx) == "<") {

			        if (baseElementHTML.charAt(htmlIdx + 1) == "b")
			            if (baseElementHTML.charAt(htmlIdx + 2) == "r")
			                if (baseElementHTML.charAt(htmlIdx + 3) == ">") {
			                    isBrTag = true;
			                }

					while(baseElementHTML.charAt(htmlIdx) != ">") {
						startIdx++;
						htmlIdx++;
						
						if(startIdx < htmlIdx) break;
					}

					if (isBrTag) {
					    startIdx--;
					    isBrTag = false;
					}

					startIdx++;
					htmlIdx++;
					
					if(startIdx < htmlIdx) break;

				} else if (baseElementHTML.charAt(htmlIdx) == "&") {

				    if (baseElementHTML.charAt(htmlIdx + 1) == "n")
				        if (baseElementHTML.charAt(htmlIdx + 2) == "b")
				            if (baseElementHTML.charAt(htmlIdx + 3) == "s")
				                if (baseElementHTML.charAt(htmlIdx + 4) == "p")
				                    if (baseElementHTML.charAt(htmlIdx + 5) == ";")
				                        isNBSP = true;

					while(baseElementHTML.charAt(htmlIdx) != ";") {
						startIdx++;
						htmlIdx++;
						
						if(startIdx < htmlIdx) break;
					}

					if (isNBSP) {
					    startIdx--;
					    isNBSP = false;
					}

					startIdx++;
					htmlIdx++;

					if(startIdx < htmlIdx) break;
					
				} else {
				    htmlIdx++;
				}
		    } while (htmlIdx != startIdx);

		    baseElementHTML = baseElementHTML.substr(0,startIdx) + "<" + tag + attr + "></" + tag + ">" + baseElementHTML.substr(startIdx, baseElementHTML.length);

		} else {

			baseElementHTML = "<" + tag + attr + "></" + tag + ">" + baseElementHTML;

		}
		
		baseElement.innerHTML = baseElementHTML;
	}
}

//option = {targetElement:DOMCollection, unicode:String, selection:window.getSelection()}
function insertUnicode(option) {
	  var target = option.targetElement;
      var doc = target.ownerDocument.defaultView;
      
      var sel = doc.getSelection();
      if(option.selection != undefined)
    	  sel = option.selection;
      
      var range = sel.getRangeAt(0);
      
      var newNode = document.createTextNode(option.unicode);
      range.insertNode(newNode);

      range.setStartAfter(newNode);
      range.setEndAfter(newNode); 
      sel.removeAllRanges();
      sel.addRange(range);
}

//{baseElement:DOMCollection, targetTagName:String, exceptTagName:String}
function deleteTag(option) {
	var sel = document.getSelection();
	if(option.selection != undefined)
		sel = option.selection;
	
	var baseElement = option.baseElement;
	
	var targetTag = "";
	var everyTag = false;
	if(option.targetTagName != undefined)
		targetTag = option.targetTagName.toUpperCase();
	else
		everyTag = true;
	
	var exceptTag = "";
	if(option.exceptTagName != undefined)
		exceptTag = option.exceptTagName.toUpperCase();

	var HTML = "";
	var selNode = sel.anchorNode.parentNode;

	if(selNode != baseElement && 
			(selNode.tagName == targetTag || everyTag) && 
			selNode.tagName != exceptTag) {
		
	    HTML = selNode.innerHTML;
		var tmpTag = document.createElement("span");
		tmpTag.innerHTML = HTML;

		selNode.parentNode.insertBefore(tmpTag, selNode);
		selNode.parentNode.removeChild(selNode);

		baseElement.innerHTML = baseElement.innerHTML.replace("<span>", "");
		baseElement.innerHTML = baseElement.innerHTML.replace("</span>", "");
	}
}

//불필요하게 사용된 tag들을 정리합니다.
function optimizeTags(option) {
	var baseElement = option.baseElement;
	var tagName = option.tagName;

	//<>...<>...</>...</> -> <>.........</>
	var initHTML; var tags; var tag;
	var tmpHTML; var tmpTag;
	do {
		initHTML = baseElement.innerHTML;
		tags= baseElement.getElementsByTagName(tagName);

		for(var i = 0; i < tags.length; i++) {
			tag = tags[i];

			if(tag.parentElement.tagName == tag.tagName) {
				tmpHTML = tag.innerHTML;
				tmpTag = document.createElement("span");
				tmpTag.innerHTML = tmpHTML;

				tag.parentElement.insertBefore(tmpTag, tag);
				tag.parentElement.removeChild(tag);

				baseElement.innerHTML = baseElement.innerHTML.replace("<span>", "");
				baseElement.innerHTML = baseElement.innerHTML.replace("</span>", "");
			}
		}
	} while(initHTML != baseElement.innerHTML);

	//<>...</><>...</> -> <>......</>
	while(baseElement.innerHTML != baseElement.innerHTML.replace("</" + tagName + "></" + tagName + ">", "</" + tagName + ">")) {
		baseElement.innerHTML = baseElement.innerHTML.replace("</" + tagName + "></" + tagName + ">", "</" + tagName + ">");
	}
	while(baseElement.innerHTML != baseElement.innerHTML.replace("</" + tagName + "><" + tagName + ">", "")) {
		baseElement.innerHTML = baseElement.innerHTML.replace("</" + tagName + "><" + tagName + ">", "");
	}
	
	//<></> -> 삭제
	var initHTML; var tags; var tag;
	do {
		initHTML = baseElement.innerHTML;
		tags= baseElement.getElementsByTagName(tagName);

		for(var i = 0; i < tags.length; i++) {
			tag = tags[i];

			if(tag.innerHTML == "")
				tag.parentElement.removeChild(tag);
		}
	} while(initHTML != baseElement.innerHTML);
}