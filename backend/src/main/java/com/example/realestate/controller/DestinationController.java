package com.example.realestate.controller;

import com.example.realestate.model.Destination;
import com.example.realestate.repository.DestinationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/destinations")
@CrossOrigin(origins = "*")
public class DestinationController {

    @Autowired
    private DestinationRepository repo;

    @GetMapping("/all")
    public List<Destination> getDestinations() {
        return repo.findAll();
    }
}
