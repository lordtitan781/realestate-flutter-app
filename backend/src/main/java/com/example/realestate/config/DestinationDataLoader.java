package com.example.realestate.config;

import com.example.realestate.model.Destination;
import com.example.realestate.repository.DestinationRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

@Component
public class DestinationDataLoader {

    private final DestinationRepository repo;

    public DestinationDataLoader(DestinationRepository repo) {
        this.repo = repo;
    }

    @PostConstruct
    public void init() {
        if (repo.count() == 0) {
            repo.save(new Destination("Goa", 8500000, 78.0, 6.2));
            repo.save(new Destination("Kerala Backwaters", 3200000, 72.0, 5.4));
            repo.save(new Destination("Himachal Pradesh", 5400000, 69.0, 7.1));
            repo.save(new Destination("Bali", 6200000, 81.0, 6.9));
        }
    }
}
