package com.example.realestate.controller;

import com.example.realestate.model.User;
import com.example.realestate.repository.UserRepository;
import com.example.realestate.security.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import com.example.realestate.service.PasswordResetService;

import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final PasswordResetService passwordResetService;

    public AuthController(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtService jwtService, AuthenticationManager authenticationManager, PasswordResetService passwordResetService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        System.out.println(">>> AuthController: Registering user: " + request.getEmail());
    // Prevent duplicate exact account (same email + same role)
    if (userRepository.findByEmailAndRole(request.getEmail(), request.getRole()).isPresent()) {
        return ResponseEntity.status(409).build(); // Conflict
    }

    User user = new User(
        request.getEmail(),
        passwordEncoder.encode(request.getPassword()),
        request.getRole()
    );
    // Optional investor profile details for recommendation engine
    user.setMinBudget(request.getMinBudget());
    user.setMaxBudget(request.getMaxBudget());
    user.setRiskProfile(request.getRiskProfile());
    User savedUser = userRepository.save(user);
        
    // Include role in username portion so tokens are specific to an email+role account
    var userDetails = new org.springframework.security.core.userdetails.User(
        savedUser.getEmail() + "|" + savedUser.getRole(), savedUser.getPassword(), java.util.Collections.emptyList());
    var jwtToken = jwtService.generateToken(userDetails);
        
        return ResponseEntity.ok(new AuthResponse(
                jwtToken,
                savedUser.getRole(),
                savedUser.getEmail(),
                savedUser.getId(),
                savedUser.getMinBudget(),
                savedUser.getMaxBudget(),
                savedUser.getRiskProfile()
        ));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> authenticate(@RequestBody AuthRequest request) {
        System.out.println(">>> AuthController: Authenticating user: " + request.getEmail());
    // Authenticate using email+role to select the correct account when same email has multiple roles
    String subject = request.getEmail();
    if (request.getRole() != null && !request.getRole().isEmpty()) {
        subject = request.getEmail() + "|" + request.getRole();
    }

    authenticationManager.authenticate(
        new UsernamePasswordAuthenticationToken(subject, request.getPassword())
    );

    var user = userRepository.findByEmailAndRole(request.getEmail(), request.getRole()).orElseGet(() -> userRepository.findByEmail(request.getEmail()).orElseThrow());
    var userDetails = new org.springframework.security.core.userdetails.User(
        user.getEmail() + "|" + user.getRole(), user.getPassword(), java.util.Collections.emptyList());
    var jwtToken = jwtService.generateToken(userDetails);
        
        return ResponseEntity.ok(new AuthResponse(
                jwtToken,
                user.getRole(),
                user.getEmail(),
                user.getId(),
                user.getMinBudget(),
                user.getMaxBudget(),
                user.getRiskProfile()
        ));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@RequestBody String emailRaw) {
        String email = emailRaw.replaceAll("\"", "").trim();
        boolean ok = passwordResetService.generateAndSendOtp(email);
        if (ok) return ResponseEntity.ok("OTP sent to email if account exists (check your inbox).");
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<String> verifyOtp(@RequestBody VerifyOtpRequest req) {
        boolean ok = passwordResetService.verifyOtp(req.getEmail(), req.getOtp());
        if (ok) return ResponseEntity.ok("OTP valid");
        return ResponseEntity.status(400).body("OTP invalid or expired");
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest req) {
        boolean ok = passwordResetService.resetPassword(req.getEmail(), req.getOtp(), req.getNewPassword());
        if (ok) return ResponseEntity.ok("Password reset successful");
        return ResponseEntity.status(400).body("OTP invalid/expired or password could not be reset");
    }
}

class AuthRequest {
    private String email;
    private String password;
    private String role; // optional: specify which role to login as when same email has multiple roles
    public AuthRequest() {}
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}

class RegisterRequest {
    private String email;
    private String password;
    private String role;
    private Double minBudget;
    private Double maxBudget;
    private String riskProfile;
    public RegisterRequest() {}
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public Double getMinBudget() { return minBudget; }
    public void setMinBudget(Double minBudget) { this.minBudget = minBudget; }
    public Double getMaxBudget() { return maxBudget; }
    public void setMaxBudget(Double maxBudget) { this.maxBudget = maxBudget; }
    public String getRiskProfile() { return riskProfile; }
    public void setRiskProfile(String riskProfile) { this.riskProfile = riskProfile; }
}

class AuthResponse {
    private String token;
    private String role;
    private String email;
    private Long userId;
    private Double minBudget;
    private Double maxBudget;
    private String riskProfile;
    
    public AuthResponse() {}
    
    public AuthResponse(String token, String role, String email, Long userId,
                        Double minBudget, Double maxBudget, String riskProfile) {
        this.token = token;
        this.role = role;
        this.email = email;
        this.userId = userId;
        this.minBudget = minBudget;
        this.maxBudget = maxBudget;
        this.riskProfile = riskProfile;
    }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Double getMinBudget() { return minBudget; }
    public void setMinBudget(Double minBudget) { this.minBudget = minBudget; }
    public Double getMaxBudget() { return maxBudget; }
    public void setMaxBudget(Double maxBudget) { this.maxBudget = maxBudget; }
    public String getRiskProfile() { return riskProfile; }
    public void setRiskProfile(String riskProfile) { this.riskProfile = riskProfile; }
}

class ResetRequest {
    private String token;
    private String newPassword;
    public ResetRequest() {}
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}

class VerifyOtpRequest {
    private String email;
    private String otp;
    public VerifyOtpRequest() {}
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }
}

class ResetPasswordRequest {
    private String email;
    private String otp;
    private String newPassword;
    public ResetPasswordRequest() {}
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}
