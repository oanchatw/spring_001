package com.example.mapapp.service;

import com.example.mapapp.dto.SavedPlaceDto;
import com.example.mapapp.model.SavedPlace;
import com.example.mapapp.model.User;
import com.example.mapapp.repository.SavedPlaceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlaceService {

    private final SavedPlaceRepository savedPlaceRepository;

    /** 取得用戶所有收藏地點 */
    public List<SavedPlace> getUserPlaces(Long userId) {
        return savedPlaceRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    /** 依分類篩選 */
    public List<SavedPlace> getUserPlacesByCategory(Long userId, String category) {
        return savedPlaceRepository.findByUserIdAndCategory(userId, category);
    }

    /** 新增收藏地點 */
    @Transactional
    public SavedPlace savePlace(User user, SavedPlaceDto dto) {
        SavedPlace place = SavedPlace.builder()
                .user(user)
                .placeId(dto.getPlaceId())
                .name(dto.getName())
                .address(dto.getAddress())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .note(dto.getNote())
                .category(dto.getCategory())
                .build();
        return savedPlaceRepository.save(place);
    }

    /** 更新備註與分類 */
    @Transactional
    public SavedPlace updatePlace(Long placeId, Long userId, SavedPlaceDto dto) {
        SavedPlace place = savedPlaceRepository.findByIdAndUserId(placeId, userId)
                .orElseThrow(() -> new RuntimeException("地點不存在或無權限"));
        place.setNote(dto.getNote());
        place.setCategory(dto.getCategory());
        place.setName(dto.getName());
        return savedPlaceRepository.save(place);
    }

    /** 刪除收藏 */
    @Transactional
    public void deletePlace(Long placeId, Long userId) {
        SavedPlace place = savedPlaceRepository.findByIdAndUserId(placeId, userId)
                .orElseThrow(() -> new RuntimeException("地點不存在或無權限"));
        savedPlaceRepository.delete(place);
    }

    /** 檢查是否已收藏 */
    public boolean isAlreadySaved(Long userId, String googlePlaceId) {
        return savedPlaceRepository.existsByUserIdAndPlaceId(userId, googlePlaceId);
    }
}
