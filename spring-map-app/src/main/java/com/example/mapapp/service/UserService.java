package com.example.mapapp.service;

import com.example.mapapp.model.User;
import com.example.mapapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    /**
     * 從 Spring Security 的 OAuth2User 取得本地 User 實體
     */
    public Optional<User> getCurrentUser(OAuth2User oAuth2User) {
        if (oAuth2User == null) return Optional.empty();
        String googleId = oAuth2User.getAttribute("sub");
        return userRepository.findByGoogleId(googleId);
    }

    public Optional<User> findByGoogleId(String googleId) {
        return userRepository.findByGoogleId(googleId);
    }
}
