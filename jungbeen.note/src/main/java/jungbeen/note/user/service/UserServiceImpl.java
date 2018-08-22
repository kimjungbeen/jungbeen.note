package jungbeen.note.user.service;

import jungbeen.note.user.dao.UserDao;
import jungbeen.note.user.dao.UserDaoImpl;
import jungbeen.note.user.domain.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService{
	@Autowired private UserDao userDao;
	
	public UserServiceImpl(){
		this.userDao = new UserDaoImpl();
	}

	@Override
	public User findUser(String userId){
		return userDao.getUser(userId);
	}
	
	@Override
	public boolean join(User user){
		return userDao.addUser(user)>0;
	}
}
