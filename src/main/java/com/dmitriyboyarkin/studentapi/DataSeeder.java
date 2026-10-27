package com.dmitriyboyarkin.studentapi;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** Inserts individual test data on first start and prints the student's name. */
@Component
@ConditionalOnProperty(name = "app.seed.enabled", havingValue = "true")
public class DataSeeder implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);

    private final StudentRepository repository;
    private final String studentName;
    private final String version;

    public DataSeeder(StudentRepository repository,
                      @Value("${app.student-name}") String studentName,
                      @Value("${app.version}") String version) {
        this.repository = repository;
        this.studentName = studentName;
        this.version = version;
    }

    @Override
    public void run(String... args) {
        log.info("==== Student API of {} - version {} ====", studentName, version);
        if (repository.count() == 0) {
            repository.save(new Student("Dmitriy", "Boyarkin", "john.doe556@tutamail.com", "DB-2026-001"));
            repository.save(new Student("Aigerim", "Testova", "aigerim.testova@example.com", "DB-2026-002"));
            log.info("Seeded individual test data for {}", studentName);
        }
    }
}
