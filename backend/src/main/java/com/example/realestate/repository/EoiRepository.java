package com.example.realestate.repository;

import com.example.realestate.model.Eoi;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EoiRepository extends JpaRepository<Eoi, Long> {
    List<Eoi> findByInvestorId(Long investorId);
    List<Eoi> findByProjectId(Long projectId);
}
