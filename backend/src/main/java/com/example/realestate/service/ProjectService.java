package com.example.realestate.service;

import com.example.realestate.model.Project;
import com.example.realestate.model.ProjectStage;
import com.example.realestate.repository.ProjectRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Stream;

@Service
public class ProjectService {

    private final ProjectRepository projectRepository;

    public ProjectService(ProjectRepository projectRepository) {
        this.projectRepository = projectRepository;
    }

    public Project createProject(Project project) {
        if (project.getStage() == null) project.setStage(ProjectStage.LAND_APPROVED);
        return projectRepository.save(project);
    }

    public List<Project> getAllProjects() {
        return projectRepository.findAll();
    }

    private static final Map<ProjectStage, Set<ProjectStage>> ALLOWED_TRANSITIONS = Map.of(
            ProjectStage.LAND_APPROVED, Set.of(ProjectStage.PLANNING, ProjectStage.CANCELLED, ProjectStage.LAND_APPROVED),
            ProjectStage.PLANNING, Set.of(ProjectStage.FUNDING, ProjectStage.CANCELLED, ProjectStage.PLANNING),
            ProjectStage.FUNDING, Set.of(ProjectStage.CONSTRUCTION, ProjectStage.CANCELLED, ProjectStage.FUNDING),
            ProjectStage.CONSTRUCTION, Set.of(ProjectStage.COMPLETED, ProjectStage.CANCELLED, ProjectStage.CONSTRUCTION),
            ProjectStage.COMPLETED, Set.of(ProjectStage.COMPLETED),
            ProjectStage.CANCELLED, Set.of(ProjectStage.CANCELLED)
    );

    private boolean isTransitionAllowed(ProjectStage from, ProjectStage to) {
        if (from == null) return true;
        return ALLOWED_TRANSITIONS.getOrDefault(from, Set.of()).contains(to);
    }

    public Optional<Project> updateStage(Long projectId, String stage) {
        // validate stage string -> ProjectStage
        ProjectStage stageEnum = ProjectStage.fromString(stage);
        Optional<Project> existing = projectRepository.findById(projectId);
        return existing.map(project -> {
            ProjectStage current = project.getStage();
            if (!isTransitionAllowed(current, stageEnum)) {
                throw new IllegalStateException("Transition from " + current + " to " + stageEnum + " is not allowed");
            }
            project.setStage(stageEnum);
            return projectRepository.save(project);
        });
    }

    /**
     * Return project by id.
     */
    public Optional<Project> getProjectById(Long id) {
        return projectRepository.findById(id);
    }

    private static final Map<String, Integer> PROGRESS_MAP = Map.ofEntries(
            Map.entry("LAND_APPROVED", 10),
            Map.entry("INVESTORS_JOINED", 30),
            Map.entry("DESIGN_PLANNING", 50),
            Map.entry("CONSTRUCTION_STARTED", 70),
            Map.entry("RESORT_COMPLETED", 90),
            Map.entry("TOURISTS_ARRIVING", 100),
            // backward-compatible aliases
            Map.entry("PLANNING", 50),
            Map.entry("FUNDING", 30),
            Map.entry("CONSTRUCTION", 70),
            Map.entry("COMPLETED", 90),
            Map.entry("CANCELLED", 0)
    );

    /**
     * Calculate project progress percentage based on the lifecycle stage string.
     * Accepts either the new tourism-focused stage names or legacy stage names.
     * Returns 0 if stage is unknown or null.
     */
    public double calculateProjectProgress(String stage) {
        if (stage == null) return 0.0;
        String normalized = stage.trim().toUpperCase().replace('-', '_');
        Integer pct = PROGRESS_MAP.get(normalized);
        return pct == null ? 0.0 : pct.doubleValue();
    }
}
