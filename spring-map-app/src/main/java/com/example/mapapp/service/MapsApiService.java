package com.example.mapapp.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Map;

/**
 * 串接 Google Maps Platform API：
 * - Places API (附近搜尋、地點詳情)
 * - Directions API (路線規劃)
 * - Geocoding API (地址轉座標)
 */
@Service
@Slf4j
public class MapsApiService {

    private final WebClient mapsWebClient;
    private final String mapsApiKey;

    public MapsApiService(WebClient mapsWebClient, String mapsApiKey) {
        this.mapsWebClient = mapsWebClient;
        this.mapsApiKey = mapsApiKey;
    }

    /**
     * 附近搜尋 (Places API - Nearby Search)
     * @param lat      緯度
     * @param lng      經度
     * @param radius   搜尋半徑（公尺，最大 50000）
     * @param type     地點類型 (restaurant / tourist_attraction / lodging ...)
     * @param keyword  關鍵字（可選）
     */
    public Mono<Map> searchNearby(double lat, double lng, int radius, String type, String keyword) {
        log.info("附近搜尋: lat={}, lng={}, type={}, keyword={}", lat, lng, type, keyword);

        return mapsWebClient.get()
                .uri(uriBuilder -> {
                    uriBuilder
                            .path("/place/nearbysearch/json")
                            .queryParam("location", lat + "," + lng)
                            .queryParam("radius", radius)
                            .queryParam("key", mapsApiKey)
                            .queryParam("language", "zh-TW");
                    if (type != null && !type.isBlank()) uriBuilder.queryParam("type", type);
                    if (keyword != null && !keyword.isBlank()) uriBuilder.queryParam("keyword", keyword);
                    return uriBuilder.build();
                })
                .retrieve()
                .bodyToMono(Map.class)
                .doOnError(e -> log.error("附近搜尋失敗: {}", e.getMessage()));
    }

    /**
     * 地點詳情 (Places API - Place Details)
     * @param placeId  Google Place ID
     */
    public Mono<Map> getPlaceDetails(String placeId) {
        log.info("取得地點詳情: placeId={}", placeId);

        return mapsWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/place/details/json")
                        .queryParam("place_id", placeId)
                        .queryParam("fields", "name,formatted_address,geometry,rating,photos,opening_hours,formatted_phone_number,website")
                        .queryParam("language", "zh-TW")
                        .queryParam("key", mapsApiKey)
                        .build()
                )
                .retrieve()
                .bodyToMono(Map.class)
                .doOnError(e -> log.error("取得地點詳情失敗: {}", e.getMessage()));
    }

    /**
     * 路線規劃 (Directions API)
     * @param origin      起點（地址或 lat,lng）
     * @param destination 終點
     * @param waypoints   中繼點（pipe 分隔，例如 "台北101|西門町"）
     * @param mode        交通方式：driving / walking / bicycling / transit
     */
    public Mono<Map> getDirections(String origin, String destination, String waypoints, String mode) {
        log.info("路線規劃: {} → {} (mode={})", origin, destination, mode);

        return mapsWebClient.get()
                .uri(uriBuilder -> {
                    uriBuilder
                            .path("/directions/json")
                            .queryParam("origin", origin)
                            .queryParam("destination", destination)
                            .queryParam("mode", mode != null ? mode.toLowerCase() : "driving")
                            .queryParam("language", "zh-TW")
                            .queryParam("key", mapsApiKey);
                    if (waypoints != null && !waypoints.isBlank()) {
                        uriBuilder.queryParam("waypoints", waypoints);
                    }
                    return uriBuilder.build();
                })
                .retrieve()
                .bodyToMono(Map.class)
                .doOnError(e -> log.error("路線規劃失敗: {}", e.getMessage()));
    }

    /**
     * 地址轉座標 (Geocoding API)
     * @param address 地址字串
     */
    public Mono<Map> geocode(String address) {
        return mapsWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/geocode/json")
                        .queryParam("address", address)
                        .queryParam("language", "zh-TW")
                        .queryParam("key", mapsApiKey)
                        .build()
                )
                .retrieve()
                .bodyToMono(Map.class);
    }
}
