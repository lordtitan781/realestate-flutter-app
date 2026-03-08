package com.example.realestate.controller;

import com.example.realestate.model.Project;
import com.example.realestate.model.ProjectStage;
import com.example.realestate.service.ProjectService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Optional;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = ProjectController.class)
class ProjectControllerWebTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ProjectService projectService;

    @Test
    void getProjectProgress_found_returns200() throws Exception {
        Project p = new Project();
        p.setId(1L);
        p.setProjectName("Eco Resort Project");
        p.setStage(ProjectStage.CONSTRUCTION);

        when(projectService.getProjectById(1L)).thenReturn(Optional.of(p));
        when(projectService.calculateProjectProgress("CONSTRUCTION")).thenReturn(70.0);

        mockMvc.perform(get("/api/projects/1/progress").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.projectName").value("Eco Resort Project"))
                .andExpect(jsonPath("$.stage").value("CONSTRUCTION"))
                .andExpect(jsonPath("$.progress").value(70));
    }

    @Test
    void getProjectProgress_notFound_returns404() throws Exception {
        when(projectService.getProjectById(99L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/projects/99/progress").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Project not found"));
    }
}
