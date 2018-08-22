package jungbeen.note.user.dao.mapper;

import jungbeen.note.user.domain.User;

public interface UserMapper {
	User getUser(String userId);           //사용자 정보 한명
	int addUser(User user);            //사용자 정보 추가
}
