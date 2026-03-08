package com.example.realestate.model;

import jakarta.persistence.*;

@Entity
@Table(name = "destinations")
public class Destination {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private int touristsPerYear;
    private double hotelOccupancy;
    private double growthRate;

    public Destination() {}

    public Destination(String name, int touristsPerYear, double hotelOccupancy, double growthRate) {
        this.name = name;
        this.touristsPerYear = touristsPerYear;
        this.hotelOccupancy = hotelOccupancy;
        this.growthRate = growthRate;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getTouristsPerYear() { return touristsPerYear; }
    public void setTouristsPerYear(int touristsPerYear) { this.touristsPerYear = touristsPerYear; }

    public double getHotelOccupancy() { return hotelOccupancy; }
    public void setHotelOccupancy(double hotelOccupancy) { this.hotelOccupancy = hotelOccupancy; }

    public double getGrowthRate() { return growthRate; }
    public void setGrowthRate(double growthRate) { this.growthRate = growthRate; }
}
