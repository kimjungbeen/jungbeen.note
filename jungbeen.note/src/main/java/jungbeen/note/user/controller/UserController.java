package jungbeen.note.user.controller;

import javax.servlet.http.HttpServletRequest;

import jungbeen.note.user.domain.User;
import jungbeen.note.user.service.UserService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/")
public class UserController {
	@Autowired private UserService userService;
	
	@RequestMapping(method = RequestMethod.GET)
	public String login(){
		return "user/logIn";
	}
	
	@RequestMapping(method = RequestMethod.POST)
	@ResponseBody
	public boolean findId(HttpServletRequest request){
		boolean result = false;
		String userId = request.getParameter("userId");
		if(userId != null && !userId.equals("")){
			User corUser = userService.findUser(userId);
			if(corUser != null){
				request.getSession().setAttribute("corUser", corUser);		
				result = true;	
			}else{
				result = false;
			}
		}else{
			result = false;
		}
		return result;
	}
	
	@RequestMapping(value="passCheck", method = RequestMethod.POST)
	@ResponseBody
	public boolean checkPw(HttpServletRequest request){
		boolean result = false;
		String userPw = request.getParameter("userPw");		
		if(userPw != null && !userPw.equals("")){	
			User corUser = (User)request.getSession().getAttribute("corUser");
			if(userPw.equals(corUser.getUserPw())){
				result = true;
			}else{
				result = false;
			}
		}else{
			result = false;
		}
		return result;
	}
	
	@RequestMapping(value="/addUser",method = RequestMethod.GET)
	public String addUser(){
		return "user/addUser";
	}
	
	@ResponseBody
	@RequestMapping(value="/addUser",method = RequestMethod.POST)
	public boolean addUser(HttpServletRequest request){
		System.out.println("오류확인");
		String userName = request.getParameter("userName");
		String userId = request.getParameter("userId");
		String userPw = request.getParameter("userPw");
		String userEmail = request.getParameter("userEmail");	
		User newUser = new User(userId, userPw, userName, userEmail);
		boolean result = userService.join(newUser);
		return result;
	}
	
	@RequestMapping("/main")
	public String main(){
		return "main";
	}
	
	@RequestMapping("/img")
	public void image(){}
	
	@RequestMapping("/css")
	public void css(){}
	
	@RequestMapping("/js")
	public void js(){}
}
