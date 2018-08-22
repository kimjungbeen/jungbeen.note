package jungbeen.note.user.dao;

import jungbeen.note.user.dao.mapper.UserMapper;
import jungbeen.note.user.domain.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class UserDaoImpl implements UserDao{
	@Autowired private UserMapper userMapper;

	//사용자 한명의 정보를 조회한다.
	public User getUser(String userId){
		return userMapper.getUser(userId);
	}
	
	//사용자 정보를 추가한다.
	//return: 추가한 사용자 정보 수
	//param: 사용자 이름
	public int addUser(User user){
		return userMapper.addUser(user);
	}
}
