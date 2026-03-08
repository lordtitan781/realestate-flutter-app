package com.example.realestate.repository;

import com.example.realestate.model.ProjectMilestone;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectMilestoneRepository extends JpaRepository<ProjectMilestone, Long> {
    List<ProjectMilestone> findByProjectIdOrderByDateAsc(Long projectId);
    List<ProjectMilestone> findByProjectId(Long projectId);
}
