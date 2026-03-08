package com.example.realestate.model;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.persistence.*;

@Entity
@Table(name = "projects")
public class Project {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonAlias({"landId", "land_id"})
    @Column(name = "land_id")
    private Long landId;

    @JsonAlias({"projectName", "title"})
    @Column(name = "project_name", nullable = false)
    private String projectName;

    @Column(nullable = false)
    private String location;

    @JsonAlias({"landSize", "land_size"})
    @Column(name = "land_size", nullable = false)
    private double landSize = 0.0;

    @JsonAlias({"investmentRequired", "capitalRequired", "capital_required"})
    @Column(name = "investment_required", nullable = false)
    private double investmentRequired = 0.0;

    @JsonAlias({"expectedROI", "projectedGrowth", "expected_roi"})
    @Column(name = "expected_roi", nullable = false)
    private double expectedROI = 0.0;

    @JsonAlias({"expectedIRR", "irr", "expected_irr"})
    @Column(name = "expected_irr", nullable = false)
    private double expectedIRR = 0.0;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProjectStage stage;

    public Project() {
    }

    @PrePersist
    public void ensureDefaultStage() {
        if (this.stage == null) this.stage = ProjectStage.LAND_APPROVED;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getLandId() {
        return landId;
    }

    public void setLandId(Long landId) {
        this.landId = landId;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public double getLandSize() {
        return landSize;
    }

    public void setLandSize(double landSize) {
        this.landSize = landSize;
    }

    public double getInvestmentRequired() {
        return investmentRequired;
    }

    public void setInvestmentRequired(double investmentRequired) {
        this.investmentRequired = investmentRequired;
    }

    public double getExpectedROI() {
        return expectedROI;
    }

    public void setExpectedROI(double expectedROI) {
        this.expectedROI = expectedROI;
    }

    public double getExpectedIRR() {
        return expectedIRR;
    }

    public void setExpectedIRR(double expectedIRR) {
        this.expectedIRR = expectedIRR;
    }

    public ProjectStage getStage() {
        return stage;
    }

    public void setStage(ProjectStage stage) {
        this.stage = stage;
    }
}

