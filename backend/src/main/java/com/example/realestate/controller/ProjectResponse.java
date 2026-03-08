package com.example.realestate.controller;

public class ProjectResponse {
    private Long id;
    private Long landId;
    private String projectName;
    private String location;
    private double landSize;
    private double investmentRequired;
    private double expectedROI;
    private double expectedIRR;
    private String stage;
    private int progress;

    public ProjectResponse() {
    }

    public ProjectResponse(Long id, Long landId, String projectName, String location, double landSize, double investmentRequired, double expectedROI, double expectedIRR, String stage, int progress) {
        this.id = id;
        this.landId = landId;
        this.projectName = projectName;
        this.location = location;
        this.landSize = landSize;
        this.investmentRequired = investmentRequired;
        this.expectedROI = expectedROI;
        this.expectedIRR = expectedIRR;
        this.stage = stage;
        this.progress = progress;
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

    public String getStage() {
        return stage;
    }

    public void setStage(String stage) {
        this.stage = stage;
    }

    public int getProgress() {
        return progress;
    }

    public void setProgress(int progress) {
        this.progress = progress;
    }
}
