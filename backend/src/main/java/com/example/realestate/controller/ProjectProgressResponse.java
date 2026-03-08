package com.example.realestate.controller;

public class ProjectProgressResponse {
    private String projectName;
    private String stage;
    private int progress;

    public ProjectProgressResponse() {
    }

    public ProjectProgressResponse(String projectName, String stage, int progress) {
        this.projectName = projectName;
        this.stage = stage;
        this.progress = progress;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
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
