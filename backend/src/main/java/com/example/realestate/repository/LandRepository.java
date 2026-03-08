package com.example.realestate.repository;

import com.example.realestate.model.Land;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LandRepository extends JpaRepository<Land, Long> {
	java.util.List<Land> findByReviewStatus(String reviewStatus);
}
