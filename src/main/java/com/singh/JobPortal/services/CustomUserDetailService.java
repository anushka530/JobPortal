package com.singh.JobPortal.services;

import com.singh.JobPortal.entity.Users;
import com.singh.JobPortal.repository.UsersRepository;
import com.singh.JobPortal.util.CustomUserDetails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailService implements UserDetailsService {
    private final UsersRepository usersRepository;
    @Autowired
    public CustomUserDetailService(UsersRepository usersRepository) {
        this.usersRepository = usersRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
         Users user = usersRepository.findByEmail(username).orElseThrow (() ->
            new UsernameNotFoundException("Could not found user"));
        return new CustomUserDetails(user);
    }
}

//Tell Spring security how to retrieve the users from the database