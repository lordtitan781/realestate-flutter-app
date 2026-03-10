package com.example.realestate.controller;

import com.example.realestate.model.Land;
import com.example.realestate.repository.LandRepository;
import com.example.realestate.repository.UserRepository;
import com.example.realestate.model.User;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/lands")
@CrossOrigin(origins = "*")
public class LandController {

    @Autowired
    private LandRepository landRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public List<Land> getAllLands() {
        System.out.println(">>> LandController: Fetching all land submissions");
        return landRepository.findAll();
    }

    @GetMapping("/available")
    public List<Land> getAvailableLands() {
        System.out.println(">>> LandController: Fetching available (approved) lands");
        return landRepository.findByReviewStatus("APPROVED");
    }

    @PostMapping
    public ResponseEntity<Land> submitLand(@RequestBody Land land) {
        System.out.println(">>> LandController: Submitting new land: " + land.getName());

        // Extract authenticated user info from SecurityContext
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username;
        if (auth.getPrincipal() instanceof UserDetails) {
            username = ((UserDetails) auth.getPrincipal()).getUsername();
        } else {
            username = auth.getPrincipal().toString();
        }

        String email = username;
        String role = null;
        if (username != null && username.contains("|")) {
            String[] parts = username.split("\\|", 2);
            email = parts[0];
            role = parts[1];
        }

        // Lookup user by email+role (prefer specific), fallback to email-only
        User user = null;
        if (role != null) {
            user = userRepository.findByEmailAndRole(email, role).orElse(null);
        }
        if (user == null) {
            user = userRepository.findByEmail(email).orElse(null);
        }

        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        // Enforce server-side ownerId assignment (ignore any client-provided ownerId)
        land.setOwnerId(user.getId());

        Land saved = landRepository.save(land);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Land> getLandById(@PathVariable Long id) {
        System.out.println(">>> LandController: Fetching land with ID: " + id);
        return landRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Land> updateLand(@PathVariable Long id, @RequestBody Land landDetails) {
        System.out.println(">>> LandController: Updating land with ID: " + id);
        return landRepository.findById(id)
                .map(land -> {
                    land.setName(landDetails.getName());
                    land.setLocation(landDetails.getLocation());
                    land.setSize(landDetails.getSize());
                    land.setZoning(landDetails.getZoning());
                    land.setStage(landDetails.getStage());
                    land.setLegalDocuments(landDetails.getLegalDocuments());
                    land.setPhoneNumber(landDetails.getPhoneNumber());
                    land.setUtilities(landDetails.getUtilities());
                    land.setReviewStatus(landDetails.getReviewStatus());
                    return ResponseEntity.ok(landRepository.save(land));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // Admin: update review status (approve/reject)
    @PutMapping("/{id}/review")
    public ResponseEntity<Land> updateReviewStatus(@PathVariable Long id, @RequestBody String status) {
        System.out.println(">>> LandController: Updating review status for land ID: " + id + " to " + status);
        return landRepository.findById(id)
                .map(land -> {
                    // expect a plain string body or JSON string value
                    String newStatus = status.replaceAll("\"", "").trim();
                    land.setReviewStatus(newStatus);
                    return ResponseEntity.ok(landRepository.save(land));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLand(@PathVariable Long id) {
        System.out.println(">>> LandController: Deleting land with ID: " + id);
        return landRepository.findById(id)
                .map(land -> {
                    landRepository.delete(land);
                    return ResponseEntity.ok().<Void>build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
