#!/usr/bin/env bash
# Task 4.3 - controlled failure on a PERSONAL TEST BRANCH (never on main).
# Usage: ./scripts/Dmitriy_Boyarkin_jenkins_failure_demo.sh break | fix
set -e
TEST_FILE=src/test/java/com/dmitriyboyarkin/studentapi/ControlledFailureTest.java
case "$1" in
  break)
    git checkout -b test/dmitriy-boyarkin-controlled-failure
    cat > "$TEST_FILE" <<'JAVA'
package com.dmitriyboyarkin.studentapi;

import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;

class ControlledFailureTest {
    @Test
    void deliberatelyFailing() {
        assertEquals(1, 2, "Controlled failure introduced by Dmitriy Boyarkin for Task 4.3");
    }
}
JAVA
    git add "$TEST_FILE"
    git commit -m "test: introduce controlled failing test (Dmitriy Boyarkin, Task 4.3)"
    git push -u origin test/dmitriy-boyarkin-controlled-failure
    echo "Now build branch test/dmitriy-boyarkin-controlled-failure in Jenkins -> Test stage must FAIL."
    ;;
  fix)
    git rm -f "$TEST_FILE"
    git commit -m "fix: remove controlled failing test, pipeline green again (Dmitriy Boyarkin)"
    git push
    echo "Re-run the build -> all stages must be green."
    ;;
  *) echo "usage: $0 break|fix"; exit 1;;
esac
