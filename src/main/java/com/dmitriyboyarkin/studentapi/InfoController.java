package com.dmitriyboyarkin.studentapi;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** Shows the student's name and the running application version. */
@RestController
public class InfoController {

    @Value("${app.student-name}")
    private String studentName;

    @Value("${app.version}")
    private String version;

    @Value("${spring.application.name}")
    private String applicationName;

    @GetMapping("/api/info")
    public Map<String, String> info() {
        Map<String, String> m = new LinkedHashMap<>();
        m.put("student", studentName);
        m.put("application", applicationName);
        m.put("version", version);
        return m;
    }
}
