package com.example.mapapp.repository;

import com.example.mapapp.model.Route;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RouteRepository extends JpaRepository<Route, Long> {
    List<Route> findByUserIdOrderByCreatedAtDesc(Long userId);
    Optional<Route> findByIdAndUserId(Long id, Long userId);
}
