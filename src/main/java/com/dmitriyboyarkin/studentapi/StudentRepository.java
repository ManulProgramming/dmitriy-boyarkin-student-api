package com.dmitriyboyarkin.studentapi;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentRepository extends JpaRepository<Student, Long> {

    List<Student> findByLastNameContainingIgnoreCase(String lastName);
}
