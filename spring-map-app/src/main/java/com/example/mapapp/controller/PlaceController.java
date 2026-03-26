package com.example.mapapp.controller;

import com.example.mapapp.dto.SavedPlaceDto;
import com.example.mapapp.model.SavedPlace;
import com.example.mapapp.model.User;
import com.example.mapapp.service.PlaceService;
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
@RequestMapping("/api/places")
@RequiredArgsConstructor
public class PlaceController {

    private final PlaceService placeService;
    private final UserService userService;

    /** GET /api/places — 取得我的收藏清單 */
    @GetMapping
    public ResponseEntity<?> getMyPlaces(
            @AuthenticationPrincipal OAuth2User oAuth2User,
            @RequestParam(required = false) String category
    ) {
        User user = getUser(oAuth2User);
        List<SavedPlace> places = category != null
                ? placeService.getUserPlacesByCategory(user.getId(), category)
                : placeService.getUserPlaces(user.getId());
        return ResponseEntity.ok(places);
    }

    /** POST /api/places — 新增收藏地點 */
    @PostMapping
    public ResponseEntity<?> savePlace(
            @AuthenticationPrincipal OAuth2User oAuth2User,
            @Valid @RequestBody SavedPlaceDto dto
    ) {
        User user = getUser(oAuth2User);
        SavedPlace saved = placeService.savePlace(user, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    /** PUT /api/places/{id} — 更新備註/分類 */
    @PutMapping("/{id}")
    public ResponseEntity<?> updatePlace(
            @AuthenticationPrincipal OAuth2User oAuth2User,
            @PathVariable Long id,
            @RequestBody SavedPlaceDto dto
    ) {
        User user = getUser(oAuth2User);
        try {
            SavedPlace updated = placeService.updatePlace(id, user.getId(), dto);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(Map.of("error", e.getMessage()));
        }
    }

    /** DELETE /api/places/{id} — 刪除收藏 */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePlace(
            @AuthenticationPrincipal OAuth2User oAuth2User,
            @PathVariable Long id
    ) {
        User user = getUser(oAuth2User);
        try {
            placeService.deletePlace(id, user.getId());
            return ResponseEntity.ok(Map.of("message", "已刪除"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(Map.of("error", e.getMessage()));
        }
    }

    private User getUser(OAuth2User oAuth2User) {
        return userService.getCurrentUser(oAuth2User)
                .orElseThrow(() -> new RuntimeException("用戶不存在"));
    }
}
