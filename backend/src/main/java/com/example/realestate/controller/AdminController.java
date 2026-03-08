package com.example.realestate.controller;

import com.example.realestate.model.Land;
import com.example.realestate.model.Project;
import com.example.realestate.model.ProjectStage;
import com.example.realestate.repository.LandRepository;
import com.example.realestate.repository.ProjectRepository;
import com.example.realestate.service.FinancialCalculatorService;
import com.example.realestate.service.IRRCalculator;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    private final LandRepository landRepository;
    private final ProjectRepository projectRepository;
    private final FinancialCalculatorService financialCalculatorService;

    public AdminController(LandRepository landRepository, ProjectRepository projectRepository, FinancialCalculatorService financialCalculatorService) {
        this.landRepository = landRepository;
        this.projectRepository = projectRepository;
        this.financialCalculatorService = financialCalculatorService;
    }

    // List pending lands
    @GetMapping("/pending-lands")
    public List<Land> pendingLands() {
        return landRepository.findByReviewStatus("PENDING");
    }

    // Approve land by id
    @PutMapping("/approve/{id}")
    public ResponseEntity<Land> approveLand(@PathVariable Long id, @RequestBody(required = false) String adminNotes) {
        return landRepository.findById(id).map(land -> {
            land.setReviewStatus("APPROVED");
            if (adminNotes != null) land.setAdminNotes(adminNotes);
            Land saved = landRepository.save(land);
            return ResponseEntity.ok(saved);
        }).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Reject land by id
    @PutMapping("/reject/{id}")
    public ResponseEntity<Land> rejectLand(@PathVariable Long id, @RequestBody(required = false) String adminNotes) {
        return landRepository.findById(id).map(land -> {
            land.setReviewStatus("REJECTED");
            if (adminNotes != null) land.setAdminNotes(adminNotes);
            Land saved = landRepository.save(land);
            return ResponseEntity.ok(saved);
        }).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Convert an approved land to a project by performing basic financial evaluation
    public static class ConversionRequest {
        public String title;
        public Double estimatedCost; // total project cost
        public Double expectedAnnualRevenue; // revenue per year
        public Integer evaluationYears = 5; // horizon for IRR/payback
    }

    @PostMapping("/convert/{landId}")
    public ResponseEntity<Project> convertLandToProject(@PathVariable Long landId, @RequestBody ConversionRequest req) {
        var optLand = landRepository.findById(landId);
        if (optLand.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Land land = optLand.get();
        if (!"APPROVED".equalsIgnoreCase(land.getReviewStatus())) {
            return ResponseEntity.status(400).body(null);
        }

        double estimatedCost = req.estimatedCost == null ? 0.0 : req.estimatedCost;
        double expectedAnnualRevenue = req.expectedAnnualRevenue == null ? 0.0 : req.expectedAnnualRevenue;
        int years = req.evaluationYears == null ? 5 : req.evaluationYears;

        // Expected ROI (simple annual ROI assumption)
        double expectedRoi = estimatedCost > 0 ? (expectedAnnualRevenue / estimatedCost) * 100.0 : 0.0;

        // Payback period in years
        double payback = expectedAnnualRevenue > 0 ? (estimatedCost / expectedAnnualRevenue) : Double.NaN;

        // Build cashflows for IRR: -cost at t0, then expected revenue for `years` years
        double[] cashFlows = new double[years + 1];
        cashFlows[0] = -estimatedCost;
        for (int i = 1; i <= years; i++) cashFlows[i] = expectedAnnualRevenue;
        double irr = IRRCalculator.calculateIRR(cashFlows);

        Project project = new Project();
        project.setProjectName(req.title == null ? "New Project" : req.title);
        project.setLocation(land.getLocation());
        project.setLandId(land.getId());
        project.setInvestmentRequired(estimatedCost);
        project.setExpectedROI(expectedRoi);
        project.setExpectedIRR(Double.isNaN(irr) ? 0.0 : irr);
    project.setStage(ProjectStage.PLANNING);

        Project saved = projectRepository.save(project);

        // Optionally mark land as converted/listed
        try {
            land.setStage("CONVERTED_TO_PROJECT");
            landRepository.save(land);
        } catch (Exception ignored) {
            // ignore if land doesn't have a stage field as enum/string mismatch
        }

        return ResponseEntity.ok(saved);
    }
}
