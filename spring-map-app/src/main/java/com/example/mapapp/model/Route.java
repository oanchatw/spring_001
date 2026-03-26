package com.example.mapapp.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;

@Entity
@Table(name = "routes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(length = 200)
    private String name;

    @Column(length = 500)
    private String origin;

    @Column(length = 500)
    private String destination;

    /** 中繼點，JSON 格式儲存 */
    @Column(columnDefinition = "TEXT")
    private String waypoints;

    /** DRIVING / WALKING / BICYCLING / TRANSIT */
    @Column(name = "travel_mode", length = 20)
    private String travelMode;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
