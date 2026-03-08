package com.example.realestate.model;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ProjectStageTest {

    @Test
    void fromString_validValues_shouldReturnEnum() {
        assertEquals(ProjectStage.LAND_APPROVED, ProjectStage.fromString("LAND_APPROVED"));
        assertEquals(ProjectStage.PLANNING, ProjectStage.fromString("planning"));
        assertEquals(ProjectStage.LAND_APPROVED, ProjectStage.fromString("land-approved"));
    }

    @Test
    void fromString_invalidValue_shouldThrow() {
        assertThrows(IllegalArgumentException.class, () -> ProjectStage.fromString("nope"));
        assertThrows(IllegalArgumentException.class, () -> ProjectStage.fromString(null));
    }
}
