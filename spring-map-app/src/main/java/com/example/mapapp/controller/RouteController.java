package com.example.mapapp.controller;

import com.example.mapapp.dto.RouteDto;
import com.example.mapapp.model.Route;
import com.example.mapapp.model.User;
import com.example.mapapp.service.RouteService;
import com.example.mapapp.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/routes")
@RequiredArgsConstructor
public class RouteController {

    private final RouteService routeService;
    private final UserService userService;

    /** GET /api/routes — 取得我的路線清單 */
    @GetMapping
    public ResponseEntity<List<Route>> getMyRoutes(@AuthenticationPrincipal OAuth2User oAuth2User) {
        User user = getUser(oAuth2User);
        return ResponseEntity.ok(routeService.getUserRoutes(user.getId()));
    }

    /** POST /api/routes — 儲存路線 */
    @PostMapping
    public ResponseEntity<?> saveRoute(
            @AuthenticationPrincipal OAuth2User oAuth2User,
            @Valid @RequestBody RouteDto dto
    ) {
        User user = getUser(oAuth2User);
        Route saved = routeService.saveRoute(user, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    /** DELETE /api/routes/{id} — 刪除路線 */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteRoute(
            @AuthenticationPrincipal OAuth2User oAuth2User,
            @PathVariable Long id
    ) {
        User user = getUser(oAuth2User);
        try {
            routeService.deleteRoute(id, user.getId());
            return ResponseEntity.ok(Map.of("message", "路線已刪除"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(Map.of("error", e.getMessage()));
        }
    }

    private User getUser(OAuth2User oAuth2User) {
        return userService.getCurrentUser(oAuth2User)
                .orElseThrow(() -> new RuntimeException("用戶不存在"));
    }
}
