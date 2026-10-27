package com.dmitriyboyarkin.studentapi;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class StudentSearchTest {

    @Autowired
    private MockMvc mvc;

    @Autowired
    private StudentRepository repository;

    @Test
    void searchBySurnameIsCaseInsensitive() throws Exception {
        repository.save(new Student("Dmitriy", "Boyarkin", "search.boyarkin@example.com", "DB-S1"));
        repository.save(new Student("Other", "Person", "search.other@example.com", "DB-S2"));

        mvc.perform(get("/api/students/search").param("lastName", "BOYARKIN"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].firstName").value("Dmitriy"));
    }
}
