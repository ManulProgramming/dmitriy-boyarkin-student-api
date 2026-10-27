# Jenkins setup - Dmitriy Boyarkin (Tasks 4.1 - 4.4)

## 4.1 Job and environment
1. **Tools** (*Manage Jenkins > Tools*): add JDK named `jdk17` (Temurin 17). Gradle is used via the wrapper (`./gradlew`) or a global `gradle` on the agent. Generate the wrapper once locally: `gradle wrapper --gradle-version 8.10.2` and commit `gradlew`, `gradlew.bat`, `gradle/wrapper/*`.
2. **Agent**: the build agent needs Docker. For a Jenkins container, mount `/var/run/docker.sock` and install the Docker CLI, or add the `jenkins` user to the `docker` group on a VM agent. Check: `docker version` as the `jenkins` user.
3. **Plugins**: Git, GitHub, Pipeline, JUnit.
4. **Credentials** (*Manage Jenkins > Credentials*): for a private repo add *Username with password* (GitHub username + **personal access token**), ID `github-dmitriy-boyarkin`. Never put tokens in the Jenkinsfile.
5. **Create job**: *New Item* > name **`Dmitriy_Boyarkin_Student_API`** > *Pipeline*.
   * Definition: *Pipeline script from SCM* > Git > Repository URL `https://github.com/<your-username>/dmitriy-boyarkin-student-api.git` > credentials (if private) > Branch `*/main` > Script Path `Jenkinsfile`.
6. Click *Build Now* once: *Checkout* stage proves Jenkins can read the repo (screenshot the console).

## 4.3 Failure demonstration
```
./scripts/Dmitriy_Boyarkin_jenkins_failure_demo.sh break   # creates test/dmitriy-boyarkin-controlled-failure
# Jenkins: build that branch (job needs "Branch Specifier" */test/dmitriy-boyarkin-controlled-failure,
# or use a Multibranch pipeline) -> Test stage FAILED, later stages skipped
./scripts/Dmitriy_Boyarkin_jenkins_failure_demo.sh fix     # remove the test, push -> green build
```

## 4.4 Trigger
* **Webhook**: GitHub repo > Settings > Webhooks > Payload URL `http://<jenkins-host>:8080/github-webhook/` > content type `application/json` > event *push*. Job > Configure > *Build Triggers* > *GitHub hook trigger for GITScm polling* (the `githubPush()` trigger in the Jenkinsfile enables this after the first run).
  A local Jenkins is not reachable from GitHub; use a tunnel (e.g. ngrok) or rely on the polling fallback.
* **Polling fallback**: `pollSCM('H/2 * * * *')` is already in the Jenkinsfile.
* Demonstrate: `git commit --allow-empty -m "ci: trigger build (Dmitriy Boyarkin)" && git push`, then show the new build in *Build History* and its *Console Output* (contains `Student: Dmitriy Boyarkin`).
