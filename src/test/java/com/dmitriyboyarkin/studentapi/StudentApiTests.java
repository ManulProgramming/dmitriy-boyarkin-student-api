package com.dmitriyboyarkin.studentapi;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class StudentApiTests {

    @Autowired
    private MockMvc mvc;

    private String json(String first, String last, String email) {
        return "{\"firstName\":\"" + first + "\",\"lastName\":\"" + last
                + "\",\"email\":\"" + email + "\",\"studentCode\":\"DB-TEST\"}";
    }

    private long createStudent(String email) throws Exception {
        String body = mvc.perform(post("/api/students")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json("Dmitriy", "Boyarkin", email)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return ((Number) JsonPath.read(body, "$.id")).longValue();
    }

    @Test
    void createAndGetStudentById() throws Exception {
        long id = createStudent("create@example.com");
        mvc.perform(get("/api/students/" + id))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName").value("Dmitriy"))
                .andExpect(jsonPath("$.lastName").value("Boyarkin"));
    }

    @Test
    void getAllStudents() throws Exception {
        createStudent("all@example.com");
        mvc.perform(get("/api/students"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].lastName").value("Boyarkin"));
    }

    @Test
    void updateStudent() throws Exception {
        long id = createStudent("update@example.com");
        mvc.perform(put("/api/students/" + id)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json("Dmitriy", "Boyarkin-Updated", "update@example.com")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.lastName").value("Boyarkin-Updated"));
    }

    @Test
    void deleteStudentThenNotFound() throws Exception {
        long id = createStudent("delete@example.com");
        mvc.perform(delete("/api/students/" + id)).andExpect(status().isNoContent());
        mvc.perform(get("/api/students/" + id)).andExpect(status().isNotFound());
    }

    @Test
    void nonexistentStudentReturns404() throws Exception {
        mvc.perform(get("/api/students/999999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    @Test
    void invalidStudentReturns400() throws Exception {
        mvc.perform(post("/api/students")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json("", "Boyarkin", "not-an-email")))
                .andExpect(status().isBadRequest());
    }
}
