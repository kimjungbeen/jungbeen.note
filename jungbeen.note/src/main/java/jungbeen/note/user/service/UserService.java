package jungbeen.note.user.service;

import jungbeen.note.user.domain.User;

public interface UserService {
	User findUser(String userId);    //사용자 한명 조회
	boolean join(User user);     //사용자 등록
}