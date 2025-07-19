package com.singh.JobPortal.services;

import com.singh.JobPortal.entity.UsersType;
import com.singh.JobPortal.repository.UsersTypeRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UsersTypeService {
    private final UsersTypeRepository usersTypeRepository;

    public UsersTypeService(UsersTypeRepository usersTypeRepository) {
        this.usersTypeRepository = usersTypeRepository;
    }

   public List<UsersType> getAll(){
        return usersTypeRepository.findAll();
   }
}
