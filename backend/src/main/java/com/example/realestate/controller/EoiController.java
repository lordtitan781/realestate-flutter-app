package com.example.realestate.controller;

import com.example.realestate.model.Eoi;
import com.example.realestate.repository.EoiRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
    public Eoi submitEOI(@RequestBody Eoi eoi) {
        System.out.println(">>> EoiController: Submitting EOI for project: " + eoi.getProjectId());
        return eoiRepository.save(eoi);
    }

    @GetMapping("/investor/{investorId}")
    public List<Eoi> getEOIsByInvestor(@PathVariable Long investorId) {
        return eoiRepository.findByInvestorId(investorId);
    }
}
