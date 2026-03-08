package com.example.realestate.config;

import com.example.realestate.repository.UserRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Collections;

@Configuration
public class ApplicationConfig {

    private final UserRepository repository;

    public ApplicationConfig(UserRepository repository) {
        this.repository = repository;
    }

    @Bean
    public UserDetailsService userDetailsService() {
    return username -> {
        // username may be stored as "email|role" in tokens to disambiguate when same email has multiple roles
        String email = username;
        String role = null;
        if (username != null && username.contains("|")) {
        String[] parts = username.split("\\|", 2);
        email = parts[0];
        role = parts.length > 1 ? parts[1] : null;
        }

        if (role != null) {
        return repository.findByEmailAndRole(email, role)
            .map(user -> new org.springframework.security.core.userdetails.User(
                user.getEmail() + "|" + user.getRole(),
                user.getPassword(),
                Collections.singleton(() -> "ROLE_" + user.getRole())
            ))
            .orElseThrow(() -> new UsernameNotFoundException("User not found for email+role"));
        }

        // Fallback: find any user by email
        return repository.findByEmail(email)
            .map(user -> new org.springframework.security.core.userdetails.User(
                user.getEmail() + "|" + user.getRole(),
                user.getPassword(),
                Collections.singleton(() -> "ROLE_" + user.getRole())
            ))
            .orElseThrow(() -> new UsernameNotFoundException("User not found"));
    };
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService());
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
