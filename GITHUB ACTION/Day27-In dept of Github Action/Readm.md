# Day 27 - GitHub Actions Basics

## 📺 Resource
- Course: Complete GitHub Actions Course - From BEGINNER to PRO
- Link: https://youtu.be/Xwpi0ITkL3U

# GitHub Actions Learning Notes: Passing Variables, Secrets, Variables & Environments

## Overview

When building CI/CD pipelines, jobs often need to share information with each other, and workflows need access to configuration values like API keys, database passwords, or application URLs.

GitHub Actions provides several mechanisms for this:

1. **Shell Variables** – Temporary variables within a step.
2. **Environment Variables (`GITHUB_ENV`)** – Shared between steps in the same job.
3. **Step Outputs (`GITHUB_OUTPUT`)** – Expose values from one step.
4. **Job Outputs** – Pass values between different jobs.
5. **Repository Secrets** – Encrypted values available across the repository.
6. **Repository Variables** – Plain-text configuration values.
7. **Environment Secrets & Variables** – Configuration specific to environments such as staging or production.

---

# Part 1: Passing Variables Between Jobs

## Why is this needed?

Every GitHub Actions job runs on a **new virtual machine**.

Example:

```
Producer Job
    ↓
Ubuntu VM #1

Consumer Job
    ↓
Ubuntu VM #2
```

These jobs **do not share**

* Environment variables
* Files
* Shell variables
* Installed software (unless recreated)

Therefore, GitHub provides **Job Outputs** for sharing data.

---

## Example Workflow

```yaml
name: Passing Variables Between Jobs

on:
  workflow_dispatch:

jobs:
  producer:
    runs-on: ubuntu-24.04

    outputs:
      foo: ${{ steps.generate-foo.outputs.foo }}

    steps:
      - name: Generate and export foo
        id: generate-foo

        run: |
          foo=bar

          echo "foo=${foo}" >> "$GITHUB_OUTPUT"
          echo "FOO=${foo}" >> "$GITHUB_ENV"

      - name: Inspect values
        run: |
          echo $FOO
          echo ${{ steps.generate-foo.outputs.foo }}

  consumer:
    runs-on: ubuntu-24.04
    needs: producer

    steps:
      - run: |
          echo "${{ needs.producer.outputs.foo }}"
```

---

# Understanding "foo"

Many examples use names like

* foo
* bar
* baz

These are **placeholder names**.

```
foo=bar
```

means exactly the same as

```
name=Ananth
```

or

```
version=1.0
```

There is nothing special about the word **foo**.

---

# Step 1: Create a Shell Variable

```bash
foo=bar
```

Creates a variable inside the current shell.

```
Variable

foo
 │
 ▼
bar
```

This variable disappears when the step finishes.

---

# Step 2: Save Step Output

```bash
echo "foo=${foo}" >> "$GITHUB_OUTPUT"
```

GitHub provides a special file named

```
GITHUB_OUTPUT
```

Writing

```
foo=bar
```

to this file creates a **Step Output**.

It becomes

```
steps.generate-foo.outputs.foo

↓

bar
```

---

# Step 3: Save Environment Variable

```bash
echo "FOO=${foo}" >> "$GITHUB_ENV"
```

GitHub also provides another special file

```
GITHUB_ENV
```

Writing

```
FOO=bar
```

creates an environment variable for later steps in the **same job**.

```
Current Job

Step 1
   │
   ├── Write to GITHUB_ENV
   │
Step 2
   │
   └── $FOO = bar
```

---

# Step 4: Expose Job Output

```yaml
outputs:
  foo: ${{ steps.generate-foo.outputs.foo }}
```

A Step Output is only visible inside the current job.

To make it available to another job, it must be promoted to a **Job Output**.

```
Shell Variable
      │
      ▼
GITHUB_OUTPUT
      │
      ▼
Step Output
      │
      ▼
Job Output
```

---

# Step 5: Access Output in Another Job

The consumer waits for producer.

```yaml
needs: producer
```

Now it can access

```yaml
${{ needs.producer.outputs.foo }}
```

which evaluates to

```
bar
```

---

# Complete Flow

```
foo=bar
    │
    ▼
GITHUB_OUTPUT
    │
    ▼
Step Output
    │
    ▼
Job Output
    │
    ▼
needs.producer.outputs.foo
    │
    ▼
Consumer Job
```

---

# GITHUB_ENV vs GITHUB_OUTPUT

| Feature               | GITHUB_ENV            | GITHUB_OUTPUT                           |
| --------------------- | --------------------- | --------------------------------------- |
| Scope                 | Same job              | Same step (later exposed to other jobs) |
| Used for              | Environment variables | Step outputs                            |
| Access                | $FOO                  | steps.id.outputs.foo                    |
| Available across jobs | No                    | Yes (after creating Job Output)         |

---

# Part 2: GitHub Secrets, Variables & Environments

## Why use them?

Hardcoding passwords or API keys inside workflows is insecure.

Instead of

```yaml
PASSWORD=mysecret123
```

GitHub allows secure storage.

Repository structure:

```
Repository
│
├── Secrets
│
├── Variables
│
└── Environments
       │
       ├── staging
       │
       └── production
```

---

# Repository Secrets

Stored under

```
Settings

↓

Secrets and Variables

↓

Actions

↓

Repository Secrets
```

Access using

```yaml
${{ secrets.SECRET_NAME }}
```

Example

```
DOCKER_PASSWORD
```

Used for

* API Keys
* Passwords
* Tokens
* SSH Keys

Repository secrets are

* Encrypted
* Masked in logs

---

# Repository Variables

Stored under

```
Settings

↓

Secrets and Variables

↓

Actions

↓

Variables
```

Access using

```yaml
${{ vars.VARIABLE_NAME }}
```

Variables are **not encrypted**.

Used for

* App name
* Region
* Port
* Docker image name

---

# Environments

Example environments

```
staging

production

development
```

Workflow:

```yaml
environment: staging
```

GitHub automatically loads

```
Staging Secrets

Staging Variables
```

Changing

```yaml
environment: production
```

automatically switches to

```
Production Secrets

Production Variables
```

without modifying the workflow.

---

# Example Workflow

```yaml
jobs:

  staging:
    environment: staging

  production:
    environment: production
```

---

# Injecting Secrets and Variables

Example

```yaml
env:

  EXAMPLE_REPOSITORY_SECRET:
    ${{ secrets.EXAMPLE_REPOSITORY_SECRET }}

  EXAMPLE_REPOSITORY_VARIABLE:
    ${{ vars.EXAMPLE_REPOSITORY_VARIABLE }}

  EXAMPLE_ENVIRONMENT_SECRET:
    ${{ secrets.EXAMPLE_ENVIRONMENT_SECRET }}

  EXAMPLE_ENVIRONMENT_VARIABLE:
    ${{ vars.EXAMPLE_ENVIRONMENT_VARIABLE }}
```

GitHub converts these into shell variables.

Inside the shell

```
$EXAMPLE_REPOSITORY_SECRET

$EXAMPLE_REPOSITORY_VARIABLE

$EXAMPLE_ENVIRONMENT_SECRET

$EXAMPLE_ENVIRONMENT_VARIABLE
```

can be used like normal environment variables.

---

# Repository vs Environment

Suppose

Repository Secret

```
DOCKER_USERNAME

↓

anandu4879
```

Staging Secret

```
DB_PASSWORD

↓

staging123
```

Production Secret

```
DB_PASSWORD

↓

Prod@987
```

Running

```yaml
environment: staging
```

gets

```
DB_PASSWORD

↓

staging123
```

Running

```yaml
environment: production
```

gets

```
DB_PASSWORD

↓

Prod@987
```

The workflow remains identical.

---

# Secret Masking

Suppose

```
API_KEY

↓

abcd12345
```

Running

```bash
echo $API_KEY
```

GitHub log shows

```
***
```

Secrets are automatically masked.

Variables are not.

---

# Repository Secrets vs Environment Secrets

| Repository Secret           | Environment Secret                      |
| --------------------------- | --------------------------------------- |
| Shared across repository    | Specific to an environment              |
| Same value everywhere       | Different values per environment        |
| Good for common credentials | Good for staging/production credentials |

---

# Repository Variables vs Environment Variables

| Repository Variable            | Environment Variable                        |
| ------------------------------ | ------------------------------------------- |
| Shared everywhere              | Environment specific                        |
| Plain text                     | Plain text                                  |
| Used for general configuration | Used for environment-specific configuration |

---

# Complete Architecture

```
Developer
     │
     ▼

Workflow
     │
     ▼

Producer Job
     │
     ├── Shell Variable
     │
     ├── GITHUB_ENV
     │
     ├── GITHUB_OUTPUT
     │
     └── Job Output
              │
              ▼

Consumer Job
     │
     ▼

needs.producer.outputs.foo

────────────────────────────────────────

Repository

├── Repository Secrets
│
├── Repository Variables
│
└── Environments
      │
      ├── Staging
      │      ├── Secrets
      │      └── Variables
      │
      └── Production
             ├── Secrets
             └── Variables
```

---

# Key Takeaways

* Every job runs on a **new runner (VM)**.
* Use **`GITHUB_ENV`** to share environment variables between **steps in the same job**.
* Use **`GITHUB_OUTPUT`** to create **step outputs**.
* Convert **step outputs → job outputs** using the `outputs:` section.
* Access another job's output using **`${{ needs.<job>.outputs.<output> }}`**.
* Store sensitive values in **Repository Secrets** or **Environment Secrets**.
* Store non-sensitive configuration in **Repository Variables** or **Environment Variables**.
* Use **GitHub Environments** (staging, production, development) to automatically load the correct secrets and variables for each deployment target.
