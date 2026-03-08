package com.example.realestate.controller;

import com.example.realestate.model.MilestoneStatus;
import com.example.realestate.model.ProjectMilestone;
import com.example.realestate.service.ProjectMilestoneService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = ProjectMilestoneController.class)
class ProjectMilestoneControllerWebTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ProjectMilestoneService milestoneService;

    @Test
    void addMilestone_returnsCreated() throws Exception {
        ProjectMilestone in = new ProjectMilestone(1L, "Design Planning", "desc", LocalDate.now(), MilestoneStatus.PENDING);
        ProjectMilestone saved = new ProjectMilestone(1L, "Design Planning", "desc", LocalDate.now(), MilestoneStatus.PENDING);
        saved.setId(10L);

        when(milestoneService.addMilestone(any())).thenReturn(saved);

        mockMvc.perform(post("/api/milestones/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(in)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(10));
    }

    @Test
    void getMilestones_returnsList() throws Exception {
        ProjectMilestone m1 = new ProjectMilestone(1L, "Land Approved", "ok", LocalDate.now(), MilestoneStatus.COMPLETED);
        m1.setId(1L);
        when(milestoneService.getMilestonesForProject(1L)).thenReturn(List.of(m1));

        mockMvc.perform(get("/api/projects/1/milestones").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("[0].id").value(1));
    }
}
