package com.example.realestate.service;

import com.example.realestate.model.ProjectMilestone;
import com.example.realestate.model.MilestoneStatus;
import com.example.realestate.repository.ProjectMilestoneRepository;
import com.example.realestate.repository.ProjectRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class ProjectMilestoneService {

    private final ProjectMilestoneRepository milestoneRepository;
    private final ProjectRepository projectRepository;

    public ProjectMilestoneService(ProjectMilestoneRepository milestoneRepository, ProjectRepository projectRepository) {
        this.milestoneRepository = milestoneRepository;
        this.projectRepository = projectRepository;
    }

    public ProjectMilestone addMilestone(ProjectMilestone milestone) {
        // ensure the project exists
        if (milestone.getProjectId() == null || projectRepository.findById(milestone.getProjectId()).isEmpty()) {
            throw new IllegalArgumentException("Project not found for id: " + milestone.getProjectId());
        }

        // if date not provided, default to today
        if (milestone.getDate() == null) {
            milestone.setDate(LocalDate.now());
        }

        // default status to PENDING if not provided
        if (milestone.getStatus() == null) {
            milestone.setStatus(MilestoneStatus.PENDING);
        }

        return milestoneRepository.save(milestone);
    }

    public ProjectMilestone updateMilestoneStatus(Long milestoneId, MilestoneStatus status) {
        return milestoneRepository.findById(milestoneId).map(m -> {
            m.setStatus(status);
            return milestoneRepository.save(m);
        }).orElseThrow(() -> new IllegalArgumentException("Milestone not found for id: " + milestoneId));
    }

    public List<ProjectMilestone> getMilestonesForProject(Long projectId) {
        return milestoneRepository.findByProjectIdOrderByDateAsc(projectId);
    }
}
