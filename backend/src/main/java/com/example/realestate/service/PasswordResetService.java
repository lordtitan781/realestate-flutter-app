package com.example.realestate.service;

import com.example.realestate.model.PasswordResetToken;
import com.example.realestate.model.User;
import com.example.realestate.repository.PasswordResetTokenRepository;
import com.example.realestate.repository.UserRepository;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;

@Service
public class PasswordResetService {

    private final PasswordResetTokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;
    private final PasswordEncoder passwordEncoder;

    public PasswordResetService(PasswordResetTokenRepository tokenRepository, UserRepository userRepository, JavaMailSender mailSender, PasswordEncoder passwordEncoder) {
        this.tokenRepository = tokenRepository;
        this.userRepository = userRepository;
        this.mailSender = mailSender;
        this.passwordEncoder = passwordEncoder;
    }

    // Generate 6-digit OTP, save and email it
    public boolean generateAndSendOtp(String email) {
        Optional<User> maybeUser = userRepository.findByEmail(email.trim());
        if (maybeUser.isEmpty()) return false;
        User user = maybeUser.get();

        // generate 6-digit numeric OTP
        String otp = String.format("%06d", new Random().nextInt(1_000_000));
        LocalDateTime expires = LocalDateTime.now().plusMinutes(15);
        PasswordResetToken token = new PasswordResetToken(user.getId(), otp, expires);
        tokenRepository.save(token);

        // send email (best-effort)
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(user.getEmail());
            message.setSubject("Your password reset OTP");
            message.setText("Your OTP is: " + otp + "\nIt expires in 15 minutes.");
            mailSender.send(message);
        } catch (Exception e) {
            // Log but don't propagate; token remains in DB so user can try again later
            System.err.println("Error sending OTP email: " + e.getMessage());
        }
        return true;
    }

    public boolean verifyOtp(String email, String otp) {
        Optional<User> maybeUser = userRepository.findByEmail(email.trim());
        if (maybeUser.isEmpty()) return false;
        User user = maybeUser.get();
        Optional<PasswordResetToken> maybeToken = tokenRepository.findFirstByUserIdAndOtpAndUsedFalse(user.getId(), otp);
        if (maybeToken.isEmpty()) return false;
        PasswordResetToken token = maybeToken.get();
        if (token.getExpiresAt().isBefore(LocalDateTime.now())) return false;
        return true;
    }

    public boolean resetPassword(String email, String otp, String newPassword) {
        Optional<User> maybeUser = userRepository.findByEmail(email.trim());
        if (maybeUser.isEmpty()) return false;
        User user = maybeUser.get();
        Optional<PasswordResetToken> maybeToken = tokenRepository.findFirstByUserIdAndOtpAndUsedFalse(user.getId(), otp);
        if (maybeToken.isEmpty()) return false;
        PasswordResetToken token = maybeToken.get();
        if (token.getExpiresAt().isBefore(LocalDateTime.now())) return false;

        // mark token used
        token.setUsed(true);
        tokenRepository.save(token);

        // update password
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        return true;
    }
}
