package com.example.mapapp.repository;

import com.example.mapapp.model.SavedPlace;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SavedPlaceRepository extends JpaRepository<SavedPlace, Long> {
    List<SavedPlace> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<SavedPlace> findByUserIdAndCategory(Long userId, String category);
    Optional<SavedPlace> findByIdAndUserId(Long id, Long userId);
    boolean existsByUserIdAndPlaceId(Long userId, String placeId);
}
