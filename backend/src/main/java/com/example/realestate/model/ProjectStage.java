package com.example.realestate.model;

import java.util.Arrays;

/**
 * Enum representing allowed lifecycle stages for a Project.
 */
public enum ProjectStage {
    LAND_APPROVED,
    PLANNING,
    FUNDING,
    CONSTRUCTION,
    COMPLETED,
    CANCELLED;

    public static ProjectStage fromString(String value) {
        if (value == null) throw new IllegalArgumentException("stage must not be null");
        String normalized = value.trim().toUpperCase().replace('-', '_');
        return Arrays.stream(ProjectStage.values())
                .filter(s -> s.name().equals(normalized))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Invalid project stage: " + value));
    }
}
