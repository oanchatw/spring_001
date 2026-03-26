package com.example.mapapp.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class MapsApiConfig {

    @Value("${google.maps.api-key}")
    private String apiKey;

    @Value("${google.maps.base-url}")
    private String baseUrl;

    /**
     * WebClient 用於呼叫 Google Maps REST API
     * (Places API, Directions API, Geocoding API)
     */
    @Bean
    public WebClient mapsWebClient() {
        return WebClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader("Accept", "application/json")
                .build();
    }

    @Bean
    public String mapsApiKey() {
        return apiKey;
    }
}
