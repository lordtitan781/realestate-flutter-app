package com.example.realestate.service;

public class IRRCalculator {

    // Calculate IRR using Newton-Raphson method
    public static double calculateIRR(double[] cashFlows) {
        if (cashFlows == null || cashFlows.length == 0) return Double.NaN;

        double guess = 0.1; // initial guess 10%
        double x0 = guess;
        for (int iter = 0; iter < 1000; iter++) {
            double f = npv(x0, cashFlows);
            double fprime = npvDerivative(x0, cashFlows);
            if (Math.abs(fprime) < 1e-10) break;
            double x1 = x0 - f / fprime;
            if (Double.isNaN(x1) || Double.isInfinite(x1)) break;
            if (Math.abs(x1 - x0) < 1e-7) return x1 * 100.0; // return percent
            x0 = x1;
        }
        // fallback: try scanning
        for (double rate = -0.99; rate < 1.0; rate += 0.0005) {
            if (Math.abs(npv(rate, cashFlows)) < 1e-3) return rate * 100.0;
        }
        return Double.NaN;
    }

    private static double npv(double rate, double[] cashFlows) {
        double npv = 0.0;
        for (int t = 0; t < cashFlows.length; t++) {
            npv += cashFlows[t] / Math.pow(1 + rate, t);
        }
        return npv;
    }

    private static double npvDerivative(double rate, double[] cashFlows) {
        double deriv = 0.0;
        for (int t = 1; t < cashFlows.length; t++) {
            deriv += -t * cashFlows[t] / Math.pow(1 + rate, t + 1 - 1); // adjust exponent
            // actually derivative of cash[t]/(1+rate)^t is -t*cash[t]/(1+rate)^(t+1)
        }
        // correct derivative calculation
        deriv = 0.0;
        for (int t = 1; t < cashFlows.length; t++) {
            deriv += -t * cashFlows[t] / Math.pow(1 + rate, t + 1);
        }
        return deriv;
    }
}
