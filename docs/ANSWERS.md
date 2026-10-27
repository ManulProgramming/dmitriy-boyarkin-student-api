# Written answers - Dmitriy Boyarkin

## Task 1.4 - `>` versus `>>`
* `>` **redirects and overwrites**: the target file is created if missing, and if it exists its previous content is truncated (lost) before the new output is written.
  `echo "one" > f.txt` followed by `echo "two" > f.txt` leaves only `two`.
* `>>` **redirects and appends**: output is added to the end of the file; existing content is kept.
  `echo "one" > f.txt; echo "two" >> f.txt` leaves both lines.
* In this project the report script uses `tee -a` (append) so that every run is added to `logs/Dmitriy_Boyarkin_system_report.log`, while `Dmitriy_Boyarkin_log_analysis.txt` is written with `>` so it always contains only the latest search result.

## Task 2.4 - Why `.env` files, passwords and credentials must not be committed
1. **Git history is permanent and widely copied.** Even if the file is deleted in a later commit, the secret stays in every clone, fork and old commit; removing it requires history rewriting and, more importantly, *rotating* the secret.
2. **Repositories are shared.** Teachers, teammates, CI servers and (if public) the whole internet can read it. Automated bots scan GitHub for leaked keys within minutes.
3. **Environments differ.** Development, test and production need different credentials; hard-coding them couples code to one environment.
4. **Least privilege and auditing.** Secrets belong in a secret store (`.env` excluded by `.gitignore`, Jenkins Credentials, Docker/Kubernetes secrets, a vault) where access can be controlled, audited and rotated.
5. **Compliance/legal.** Leaked database credentials can lead to data breaches affecting personal data.

This project therefore commits only `.env.example` (placeholders), ignores `.env` in `.gitignore`, and Compose refuses to start without `POSTGRES_PASSWORD`.

## Task 4.4 - Continuous Integration vs Continuous Deployment
* **Continuous Integration (CI)**: every change is merged frequently into a shared branch and automatically built and tested (here: Checkout -> Build -> Test -> Docker Build -> Verify). Goal: find integration errors and broken tests within minutes.
* **Continuous Delivery/Deployment (CD)**: after CI succeeds, the artefact is automatically prepared for release (delivery - a human approves) or automatically released to an environment (deployment - no human step). Goal: ship working software quickly and repeatably.
* This assignment implements **CI only**; automated deployment is not enabled unless the instructor requires it.

## Task 4.3 - Failure explanation (template, fill in after your own run)
The controlled failing test `ControlledFailureTest` asserts `1 == 2`. Gradle's `test` task exits non-zero, so the *Test* stage is marked FAILED, Jenkins aborts the pipeline and the *Docker Build* and *Verify* stages are skipped - this is the "stop on failure" behaviour. Removing the test (commit "fix: ...") makes all stages green again.
