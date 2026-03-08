package com.example.realestate.service;

import com.example.realestate.model.Project;
import com.example.realestate.model.ProjectStage;
import com.example.realestate.repository.ProjectRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProjectServiceTest {

    @Mock
    ProjectRepository projectRepository;

    @InjectMocks
    ProjectService projectService;

    @Test
    void updateStage_validTransition_shouldSucceed() {
        Project p = new Project();
        p.setId(1L);
        p.setStage(ProjectStage.LAND_APPROVED);

        when(projectRepository.findById(1L)).thenReturn(Optional.of(p));
        when(projectRepository.save(any(Project.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Optional<Project> result = projectService.updateStage(1L, "PLANNING");

        assertTrue(result.isPresent());
        assertEquals(ProjectStage.PLANNING, result.get().getStage());
        verify(projectRepository).save(result.get());
    }

    @Test
    void updateStage_invalidStageString_shouldThrow() {
        assertThrows(IllegalArgumentException.class, () -> projectService.updateStage(1L, "NOPE"));
    }

    @Test
    void updateStage_forbiddenTransition_shouldThrow() {
        Project p = new Project();
        p.setId(2L);
        p.setStage(ProjectStage.COMPLETED);

        when(projectRepository.findById(2L)).thenReturn(Optional.of(p));

        assertThrows(IllegalStateException.class, () -> projectService.updateStage(2L, "PLANNING"));
        verify(projectRepository, never()).save(any());
    }
}
