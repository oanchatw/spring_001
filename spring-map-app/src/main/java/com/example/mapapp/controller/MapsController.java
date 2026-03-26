package com.example.mapapp.controller;

import com.example.mapapp.service.MapsApiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.Map;

@RestController
@RequestMapping("/api/maps")
@RequiredArgsConstructor
public class MapsController {

    private final MapsApiService mapsApiService;

    /**
     * 附近搜尋
     * GET /api/maps/nearby?lat=25.033&lng=121.565&radius=1000&type=restaurant&keyword=拉麵
     */
    @GetMapping("/nearby")
    public Mono<ResponseEntity<Map>> searchNearby(
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "1000") int radius,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String keyword
    ) {
        return mapsApiService.searchNearby(lat, lng, radius, type, keyword)
                .map(ResponseEntity::ok)
                .onErrorReturn(ResponseEntity.status(500).build());
    }

    /**
     * 路線規劃
     * GET /api/maps/directions?origin=台北車站&destination=台北101&mode=driving
     */
    @GetMapping("/directions")
    public Mono<ResponseEntity<Map>> getDirections(
            @RequestParam String origin,
            @RequestParam String destination,
            @RequestParam(required = false) String waypoints,
            @RequestParam(defaultValue = "driving") String mode
    ) {
        return mapsApiService.getDirections(origin, destination, waypoints, mode)
                .map(ResponseEntity::ok)
                .onErrorReturn(ResponseEntity.status(500).build());
    }

    /**
     * 地點詳情
     * GET /api/maps/place/{placeId}
     */
    @GetMapping("/place/{placeId}")
    public Mono<ResponseEntity<Map>> getPlaceDetails(@PathVariable String placeId) {
        return mapsApiService.getPlaceDetails(placeId)
                .map(ResponseEntity::ok)
                .onErrorReturn(ResponseEntity.status(500).build());
    }

    /**
     * 地址轉座標
     * GET /api/maps/geocode?address=台北101
     */
    @GetMapping("/geocode")
    public Mono<ResponseEntity<Map>> geocode(@RequestParam String address) {
        return mapsApiService.geocode(address)
                .map(ResponseEntity::ok)
                .onErrorReturn(ResponseEntity.status(500).build());
    }
}
