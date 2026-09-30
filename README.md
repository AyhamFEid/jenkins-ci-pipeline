# Jenkins CI Pipeline Demo

A minimal, production-ready Continuous Integration (CI) pipeline managing a Python Flask API. This project demonstrates localized unit testing isolation using Docker container stream passing, multi-stage secure container builds, and automated pipeline guardrails.

## Project Structure

```text
jenkins-ci-pipeline/
├── app/
│   ├── __init__.py
│   └── main.py          # Minimal Flask application with core functions
├── tests/
│   ├── __init__.py
│   └── test_main.py     # Pytest unit assertions
├── Dockerfile           # Secure production multi-stage app build
├── Dockerfile.jenkins   # Custom Jenkins base with embedded Docker CLI
├── Jenkinsfile          # Declarative multi-stage CI pipeline automation
└── requirements.txt     # Python dependency manifest
```

---

## Local Setup & Infrastructure Architecture

### 1. Custom Jenkins Controller Setup

To bypass common Windows mounting issues and tool availability limits, Jenkins is spun up via a custom `Dockerfile.jenkins` incorporating the native Linux Docker CLI. This allows Jenkins to orchestrate sibling container tasks through the host's Docker socket without mixing host dependencies.

Run the following inside **Git Bash** to launch the controller container securely:

```bash
# 1. Build the custom Jenkins management image
docker build -f Dockerfile.jenkins -t custom-jenkins-with-cli .

# 2. Spin up the container bypassing standard Git Bash path translation
MSYS_NO_PATHCONV=1 docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  custom-jenkins-with-cli

# 3. Apply socket read/write permissions inside the container runtime environment
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### 2. Extracting Setup Credentials

Obtain the initialization secret string printed inside the operational logs to unlock the user interface at `http://localhost:8080`:

```bash
docker logs jenkins
```

\*(Look for the asterisk `***` box containing the 32-character security key string).\*

---

## The CI Pipeline Architecture (`Jenkinsfile`)

The pipeline runs across three primary stages, emphasizing stateless workspace handling and isolated component orchestration:

1. **Checkout SCM:** Automatically clones the source repository state directly from the specified GitHub branch.
2. **Install & Test:**
   - Bypasses host volume-mount mapping limits on Windows by packaging codebase assets into a temporary `tar` binary stream.
   - Feeds the stream directly into a clean, isolated standard `python:3.11-slim` container runtime environment.
   - Runs dependencies inside the isolated environment via explicit `PYTHONPATH=.` environment definitions to accurately target structural modular unit lookups.
3. **Build Docker Image:** Upon passing assertions, builds a lightweight production container tagged with the incremental Jenkins sequence `${BUILD_NUMBER}` for absolute version control lineage tracing.

---

## Validating Pipeline Guardrails (Failure Scenario)

To guarantee the integrity of the release candidate pipeline structure, you can intentionally trigger a pipeline guardrail failure:

1. Alter an expected calculation outcome inside `tests/test_main.py` (e.g., change `assert compute_square(4) == 16` to `15`).
2. Commit and push the alteration to your repository branch.
3. Trigger **Build Now** within Jenkins.
4. **Result:** The automated testing runner alerts with a terminal exit status 1, freezing execution instantly. The downstream **Build Docker Image** stage is blocked, preventing broken artifacts from hitting production deployment registries.
