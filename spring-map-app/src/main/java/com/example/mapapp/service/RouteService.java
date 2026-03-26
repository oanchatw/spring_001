package com.example.mapapp.service;

import com.example.mapapp.dto.RouteDto;
import com.example.mapapp.model.Route;
import com.example.mapapp.model.User;
import com.example.mapapp.repository.RouteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RouteService {

    private final RouteRepository routeRepository;

    public List<Route> getUserRoutes(Long userId) {
        return routeRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Transactional
    public Route saveRoute(User user, RouteDto dto) {
        Route route = Route.builder()
                .user(user)
                .name(dto.getName())
                .origin(dto.getOrigin())
                .destination(dto.getDestination())
                .waypoints(dto.getWaypoints())
                .travelMode(dto.getTravelMode() != null ? dto.getTravelMode() : "DRIVING")
                .build();
        return routeRepository.save(route);
    }

    @Transactional
    public void deleteRoute(Long routeId, Long userId) {
        Route route = routeRepository.findByIdAndUserId(routeId, userId)
                .orElseThrow(() -> new RuntimeException("路線不存在或無權限"));
        routeRepository.delete(route);
    }
}
