package com.example.mapapp.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;

@Entity
@Table(name = "saved_places")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SavedPlace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** Google Places API 的 Place ID */
    @Column(name = "place_id", length = 200)
    private String placeId;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(length = 500)
    private String address;

    /** 緯度 */
    @Column
    private Double latitude;

    /** 經度 */
    @Column
    private Double longitude;

    /** 個人備註 */
    @Column(columnDefinition = "TEXT")
    private String note;

    /** 分類：restaurant / attraction / hotel / other */
    @Column(length = 50)
    private String category;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
