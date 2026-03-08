package com.example.realestate.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "lands")
public class Land {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "owner_id")
    private Long ownerId;
    
    private String name;
    private String location;
    private Double size;
    private String zoning;
    private String stage;

    private String legalDocuments;

    @ElementCollection
    @CollectionTable(name = "land_utilities", joinColumns = @JoinColumn(name = "land_id"))
    @Column(name = "utility")
    private List<String> utilities = new ArrayList<>();

    private String reviewStatus;
    private String adminNotes;

    public Land() {}

    public Land(Long id, Long ownerId, String name, String location, Double size, String zoning, String stage) {
        this.id = id;
        this.ownerId = ownerId;
        this.name = name;
        this.location = location;
        this.size = size;
        this.zoning = zoning;
        this.stage = stage;
        this.reviewStatus = "PENDING";
    }

    public Land(Long id, Long ownerId, String name, String location, Double size, String zoning, String stage, String legalDocuments, List<String> utilities, String reviewStatus) {
        this.id = id;
        this.ownerId = ownerId;
        this.name = name;
        this.location = location;
        this.size = size;
        this.zoning = zoning;
        this.stage = stage;
        this.legalDocuments = legalDocuments;
        this.utilities = utilities == null ? new ArrayList<>() : utilities;
        this.reviewStatus = reviewStatus;
        this.adminNotes = null;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Double getSize() { return size; }
    public void setSize(Double size) { this.size = size; }

    public String getZoning() { return zoning; }
    public void setZoning(String zoning) { this.zoning = zoning; }

    public String getStage() { return stage; }
    public void setStage(String stage) { this.stage = stage; }

    public String getLegalDocuments() { return legalDocuments; }
    public void setLegalDocuments(String legalDocuments) { this.legalDocuments = legalDocuments; }

    public List<String> getUtilities() { return utilities; }
    public void setUtilities(List<String> utilities) { this.utilities = utilities; }

    public String getReviewStatus() { return reviewStatus; }
    public void setReviewStatus(String reviewStatus) { this.reviewStatus = reviewStatus; }

    public String getAdminNotes() { return adminNotes; }
    public void setAdminNotes(String adminNotes) { this.adminNotes = adminNotes; }
}
