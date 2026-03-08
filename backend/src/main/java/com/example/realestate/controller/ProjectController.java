package com.example.realestate.controller;

import com.example.realestate.model.Project;
import com.example.realestate.service.ProjectService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@RestController
@RequestMapping("/api/projects")
@CrossOrigin(origins = "*")
public class ProjectController {

    private final ProjectService projectService;

    public ProjectController(ProjectService projectService) {
        this.projectService = projectService;
    }

    @PostMapping("/create")
    public ResponseEntity<Project> createProject(@RequestBody Project project) {
        Project saved = projectService.createProject(project);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping
    public List<ProjectResponse> getAllProjects() {
        return projectService.getAllProjects().stream().map(project -> {
            String stageName = project.getStage() != null ? project.getStage().name() : null;
            double progressVal = projectService.calculateProjectProgress(stageName);
            int progress = (int) progressVal;
            return new ProjectResponse(
                    project.getId(),
                    project.getLandId(),
                    project.getProjectName(),
                    project.getLocation(),
                    project.getLandSize(),
                    project.getInvestmentRequired(),
                    project.getExpectedROI(),
                    project.getExpectedIRR(),
                    stageName,
                    progress
            );
        }).toList();
    }

    @PutMapping("/update-stage/{projectId}")
    public ResponseEntity<?> updateProjectStage(@PathVariable Long projectId, @RequestParam String stage) {
        try {
            var updated = projectService.updateStage(projectId, stage);
            if (updated.isPresent()) {
                return ResponseEntity.ok(updated.get());
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ErrorResponse("Project not found", Instant.now().toString()));
            }
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return ResponseEntity.badRequest().body(new ErrorResponse(ex.getMessage(), Instant.now().toString()));
        }
    }

    @GetMapping("/{projectId}/progress")
    public ResponseEntity<?> getProjectProgress(@PathVariable("projectId") Long projectId) {
        var opt = projectService.getProjectById(projectId);
        if (opt.isPresent()) {
            var project = opt.get();
            String stageName = project.getStage() != null ? project.getStage().name() : null;
            double progress = projectService.calculateProjectProgress(stageName);
            ProjectProgressResponse resp = new ProjectProgressResponse(project.getProjectName(), stageName, (int) progress);
            return ResponseEntity.ok(resp);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse("Project not found", Instant.now().toString()));
        }
    }
}
