package com.example.mapapp.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SavedPlaceDto {

    /** Google Place ID (可選) */
    private String placeId;

    @NotBlank(message = "地點名稱不能為空")
    private String name;

    private String address;

    private Double latitude;

    private Double longitude;

    /** 個人備註 */
    private String note;

    /** 分類：restaurant / attraction / hotel / other */
    private String category;
}
