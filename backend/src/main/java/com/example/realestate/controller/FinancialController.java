package com.example.realestate.controller;

import com.example.realestate.service.FinancialCalculatorService;
import com.example.realestate.service.IRRCalculator;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/finance")
@CrossOrigin(origins = "*")
public class FinancialController {

    private final FinancialCalculatorService service;

    public FinancialController(FinancialCalculatorService service) {
        this.service = service;
    }

    @GetMapping("/roi")
    public double calculateROI(
            @RequestParam double investment,
            @RequestParam double finalValue
    ) {
        return service.calculateROI(investment, finalValue);
    }

    @GetMapping("/roi/scenarios")
    public Map<String, Double> scenarioROI(@RequestParam double investment) {
        return service.scenarioROI(investment);
    }

    @PostMapping("/irr")
    public double calculateIRR(@RequestBody double[] cashFlows) {
        return IRRCalculator.calculateIRR(cashFlows);
    }
}
