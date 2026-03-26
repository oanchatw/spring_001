package com.example.mapapp.security;

import com.example.mapapp.model.User;
import com.example.mapapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

/**
 * Google OAuth2 登入後處理：
 * 將 Google 帳號資訊同步到本地 H2 資料庫
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CustomOAuth2UserService implements OAuth2UserService<OAuth2UserRequest, OAuth2User> {

    private final UserRepository userRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        // 使用預設服務取得 Google 用戶資訊
        OAuth2UserService<OAuth2UserRequest, OAuth2User> delegate = new DefaultOAuth2UserService();
        OAuth2User oAuth2User = delegate.loadUser(userRequest);

        // 從 Google 取得的基本資訊
        String googleId = oAuth2User.getAttribute("sub");       // Google 唯一 ID
        String email    = oAuth2User.getAttribute("email");
        String name     = oAuth2User.getAttribute("name");
        String picture  = oAuth2User.getAttribute("picture");

        log.info("Google OAuth2 登入: email={}, googleId={}", email, googleId);

        // 查找或建立本地用戶
        userRepository.findByGoogleId(googleId)
                .orElseGet(() -> {
                    log.info("新用戶首次登入，建立帳號: {}", email);
                    User newUser = User.builder()
                            .googleId(googleId)
                            .email(email)
                            .name(name)
                            .avatarUrl(picture)
                            .build();
                    return userRepository.save(newUser);
                });

        // 如果已存在，更新名稱和頭像（以防用戶改了 Google 帳號資料）
        userRepository.findByGoogleId(googleId).ifPresent(user -> {
            if (!name.equals(user.getName()) || !picture.equals(user.getAvatarUrl())) {
                user.setName(name);
                user.setAvatarUrl(picture);
                userRepository.save(user);
            }
        });

        return oAuth2User;
    }
}
