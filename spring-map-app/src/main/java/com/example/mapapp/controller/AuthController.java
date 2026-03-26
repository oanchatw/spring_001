package com.example.mapapp.controller;

import com.example.mapapp.model.User;
import com.example.mapapp.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    /**
     * 取得當前登入用戶資訊
     * GET /api/auth/me
     */
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@AuthenticationPrincipal OAuth2User oAuth2User) {
        if (oAuth2User == null) {
            return ResponseEntity.status(401).body(Map.of("error", "未登入"));
        }

        return userService.getCurrentUser(oAuth2User)
                .map(user -> ResponseEntity.ok(Map.of(
                        "id",        user.getId(),
                        "name",      user.getName(),
                        "email",     user.getEmail(),
                        "avatarUrl", user.getAvatarUrl() != null ? user.getAvatarUrl() : ""
                )))
                .orElse(ResponseEntity.status(404).build());
    }
}
