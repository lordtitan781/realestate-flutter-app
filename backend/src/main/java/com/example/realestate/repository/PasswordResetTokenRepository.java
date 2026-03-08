package com.example.realestate.repository;

import com.example.realestate.model.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {
    Optional<PasswordResetToken> findFirstByUserIdAndOtpAndUsedFalse(Long userId, String otp);
    List<PasswordResetToken> findAllByExpiresAtBefore(LocalDateTime time);
    List<PasswordResetToken> findAllByUserIdAndUsedFalse(Long userId);
}