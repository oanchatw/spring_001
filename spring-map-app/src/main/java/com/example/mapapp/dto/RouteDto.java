package com.example.mapapp.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RouteDto {

    private String name;

    @NotBlank(message = "起點不能為空")
    private String origin;

    @NotBlank(message = "終點不能為空")
    private String destination;

    /** 中繼點（JSON array 格式，例如：["台北101", "西門町"]） */
    private String waypoints;

    /** DRIVING / WALKING / BICYCLING / TRANSIT（預設 DRIVING） */
    private String travelMode = "DRIVING";
}
