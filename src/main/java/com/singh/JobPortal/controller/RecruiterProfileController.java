package com.singh.JobPortal.controller;

import com.singh.JobPortal.entity.RecruiterProfile;
import com.singh.JobPortal.entity.Users;
import com.singh.JobPortal.repository.UsersRepository;
import com.singh.JobPortal.services.RecruiterProfileService;
import com.singh.JobPortal.util.FileUploadUtil;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StreamUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.Objects;
import java.util.Optional;

@Controller
@RequestMapping("recruiter-profile")
public class RecruiterProfileController {
    private final UsersRepository usersRepository;
    private final RecruiterProfileService recruiterProfileService;
    public RecruiterProfileController(UsersRepository usersRepository, RecruiterProfileService recruiterProfileService) {
        this.usersRepository = usersRepository;
        this.recruiterProfileService = recruiterProfileService;
    }


@GetMapping("/")
public String recruiterProfile(Model model){
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    if(!(authentication instanceof AnonymousAuthenticationToken)){
        String currentUsername = authentication.getName();
        Users users = usersRepository.findByEmail(currentUsername)
                .orElseThrow(() -> new UsernameNotFoundException("Could not found user"));

        Optional<RecruiterProfile> recruiterProfile = recruiterProfileService.getOne(users.getUserId());

        // Always add a profile attribute to the model
        model.addAttribute("profile", recruiterProfile.orElse(new RecruiterProfile()));
    }
    return "recruiter_profile";
}

    @PostMapping("/addNew")
    public String addNew(RecruiterProfile recruiterProfile,
                         @RequestParam("image") MultipartFile multipartFile,
                         Model model) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (!(authentication instanceof AnonymousAuthenticationToken)) {
            String currentUsername = authentication.getName();
            Users users = usersRepository.findByEmail(currentUsername)
                    .orElseThrow(() -> new UsernameNotFoundException("Could not find user"));

            // 🔍 Check if profile already exists
            Optional<RecruiterProfile> existingOpt = recruiterProfileService.getOne(users.getUserId());

            RecruiterProfile profileToSave;
            if (existingOpt.isPresent()) {
                profileToSave = existingOpt.get(); // 🟢 Use existing profile
            } else {
                profileToSave = new RecruiterProfile();
                profileToSave.setUserId(users); // @MapsId handles ID
            }

            // ✅ Update fields from form
            profileToSave.setFirstName(recruiterProfile.getFirstName());
            profileToSave.setLastName(recruiterProfile.getLastName());
            profileToSave.setCity(recruiterProfile.getCity());
            profileToSave.setState(recruiterProfile.getState());
            profileToSave.setCountry(recruiterProfile.getCountry());
            profileToSave.setCompany(recruiterProfile.getCompany());

            // ✅ Save photo if new file uploaded
            String fileName = "";
            if (!Objects.equals(multipartFile.getOriginalFilename(), "")) {
                fileName = StringUtils.cleanPath(Objects.requireNonNull(multipartFile.getOriginalFilename()));
                profileToSave.setProfilePhoto(fileName);
            }

            RecruiterProfile savedUser = recruiterProfileService.addNew(profileToSave);

            if (!fileName.isEmpty()) {
                String uploadDir = "photos/recruiter/" + savedUser.getUserAccountId();
                try {
                    FileUploadUtil.saveFile(uploadDir, fileName, multipartFile);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            model.addAttribute("profile", savedUser);
        }

        return "redirect:/dashboard/";
    }


}
