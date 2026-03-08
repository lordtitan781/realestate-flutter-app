package com.example.realestate.service;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class FinancialCalculatorService {

    // ROI calculation
    public double calculateROI(double investment, double finalValue) {
        double profit = finalValue - investment;
        return (profit / investment) * 100.0;
    }

    // Simple scenarios based on multipliers
    public Map<String, Double> scenarioROI(double investment) {
        Map<String, Double> scenarios = new HashMap<>();
        scenarios.put("Worst Case", calculateROI(investment, investment * 1.2));
        scenarios.put("Normal Case", calculateROI(investment, investment * 1.5));
        scenarios.put("Best Case", calculateROI(investment, investment * 2.0));
        return scenarios;
    }
}
