package com.example.realestate.controller;

import com.example.realestate.model.ProjectMilestone;
import com.example.realestate.service.ProjectMilestoneService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ProjectMilestoneController {

    private final ProjectMilestoneService milestoneService;

    public ProjectMilestoneController(ProjectMilestoneService milestoneService) {
        this.milestoneService = milestoneService;
    }

    @PostMapping("/milestones/add")
    public ResponseEntity<?> addMilestone(@RequestBody ProjectMilestone milestone) {
        try {
            ProjectMilestone saved = milestoneService.addMilestone(milestone);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(new ErrorResponse(ex.getMessage(), Instant.now().toString()));
        }
    }

    @GetMapping("/projects/{projectId}/milestones")
    public ResponseEntity<?> getMilestones(@PathVariable Long projectId) {
        List<ProjectMilestone> list = milestoneService.getMilestonesForProject(projectId);
        return ResponseEntity.ok(list);
    }

    @PutMapping("/milestones/{milestoneId}/status")
    public ResponseEntity<?> updateMilestoneStatus(@PathVariable Long milestoneId, @RequestParam String status) {
        try {
            // normalize and convert to enum
            com.example.realestate.model.MilestoneStatus ms = com.example.realestate.model.MilestoneStatus.valueOf(status.trim().toUpperCase());
            ProjectMilestone updated = milestoneService.updateMilestoneStatus(milestoneId, ms);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(new ErrorResponse(ex.getMessage(), Instant.now().toString()));
        }
    }
}
