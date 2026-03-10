package com.example.realestate.controller;

import com.example.realestate.model.Eoi;
import com.example.realestate.repository.EoiRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/eois")
@CrossOrigin(origins = "*")
public class EoiController {

    @Autowired
    private EoiRepository eoiRepository;

    @GetMapping
    public List<Eoi> getAllEOIs() {
        return eoiRepository.findAll();
    }

    @PostMapping
    public ResponseEntity<?> submitEOI(@RequestBody Eoi eoi) {
        System.out.println(">>> EoiController: Submitting EOI for investor: " + eoi.getInvestorId() + " project: " + eoi.getProjectId());
        
        // Check if EOI already exists for this investor-project combination
        boolean eoiExists = eoiRepository.findAll().stream()
            .anyMatch(e -> e.getInvestorId().equals(eoi.getInvestorId()) && 
                          e.getProjectId().equals(eoi.getProjectId()));
        
        if (eoiExists) {
            System.out.println(">>> EoiController: EOI already exists for investor: " + eoi.getInvestorId() + " project: " + eoi.getProjectId());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(
                Map.of("error", "EOI already submitted for this project", 
                       "message", "You have already submitted an Expression of Interest for this project")
            );
        }
        
        Eoi savedEoi = eoiRepository.save(eoi);
        System.out.println(">>> EoiController: EOI successfully saved with ID: " + savedEoi.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(savedEoi);
    }

    @GetMapping("/investor/{investorId}")
    public List<Eoi> getEOIsByInvestor(@PathVariable Long investorId) {
        System.out.println(">>> EoiController: Fetching EOIs for investor: " + investorId);
        return eoiRepository.findByInvestorId(investorId);
    }

    @GetMapping("/check/{investorId}/{projectId}")
    public ResponseEntity<Map<String, Boolean>> checkEOIExists(@PathVariable Long investorId, @PathVariable Long projectId) {
        boolean exists = eoiRepository.findAll().stream()
            .anyMatch(e -> e.getInvestorId().equals(investorId) && 
                          e.getProjectId().equals(projectId));
        return ResponseEntity.ok(Map.of("exists", exists));
    }
}
