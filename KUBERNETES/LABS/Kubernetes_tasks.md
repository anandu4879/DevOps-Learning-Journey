# Kubernetes Practice — CronJobs, Jobs, ConfigMaps & Volumes

This document contains hands-on Kubernetes exercises covering **CronJobs, Jobs, ConfigMaps, environment variables, volumes, namespaces, and troubleshooting**.

---

# 6. Kubernetes CronJob

## Requirements

| Configuration  | Value                          |
| -------------- | ------------------------------ |
| CronJob        | `nautilus`                     |
| Schedule       | `*/9 * * * *`                  |
| Container      | `cron-nautilus`                |
| Image          | `httpd:latest`                 |
| Command        | `echo Welcome to xfusioncorp!` |
| Restart Policy | `OnFailure`                    |

## Manifest

Create a file:

```bash
vi cronjob.yaml
```

Add:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nautilus
spec:
  schedule: "*/9 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: cron-nautilus
              image: httpd:latest
              command:
                - /bin/sh
                - -c
                - echo Welcome to xfusioncorp!
          restartPolicy: OnFailure
```

## Apply and Verify

```bash
kubectl apply -f cronjob.yaml
```

Check the CronJob:

```bash
kubectl get cronjobs
```

Check Jobs created by the CronJob:

```bash
kubectl get jobs
```

Check the Pods:

```bash
kubectl get pods
```

## Key Learning

A CronJob does not directly create a container.

The hierarchy is:

```text
CronJob
   ↓
Job
   ↓
Pod
   ↓
Container
```

The schedule:

```text
*/9 * * * *
```

means the CronJob runs **every 9 minutes**.

Cron format:

```text
┌──────── minute
│ ┌────── hour
│ │ ┌──── day of month
│ │ │ ┌── month
│ │ │ │ ┌ day of week
│ │ │ │ │
* * * * *
```

---

# 7. Countdown Job

## Requirements

| Configuration     | Value                          |
| ----------------- | ------------------------------ |
| Job               | `countdown-nautilus`           |
| Pod Template Name | `countdown-nautilus`           |
| Container         | `container-countdown-nautilus` |
| Image             | `fedora:latest`                |
| Command           | `sleep 5`                      |
| Restart Policy    | `Never`                        |

## Manifest

Create:

```bash
vi job.yaml
```

Add:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: countdown-nautilus
spec:
  template:
    metadata:
      name: countdown-nautilus
    spec:
      containers:
        - name: container-countdown-nautilus
          image: fedora:latest
          command:
            - sleep
            - "5"
      restartPolicy: Never
```

## Apply and Verify

```bash
kubectl apply -f job.yaml
```

Check the Job:

```bash
kubectl get jobs
```

Check the Pod:

```bash
kubectl get pods
```

For more information:

```bash
kubectl describe job countdown-nautilus
```

## Key Learning

A **Job** is designed for finite work that should eventually complete successfully.

```text
Job
 ↓
Pod
 ↓
Container
 ↓
Task completes
```

### Job vs Deployment

| Deployment                        | Job                               |
| --------------------------------- | --------------------------------- |
| Keeps applications running        | Runs work to completion           |
| Used for long-running services    | Used for finite tasks             |
| Replaces failed Pods continuously | Stops after successful completion |
| Example: Web server               | Example: Batch processing         |

A **Deployment** keeps applications running.

A **Job** runs a task until it completes successfully.

---

# 8. Time Check Pod with ConfigMap and Volume

## Requirements

| Configuration        | Value                           |
| -------------------- | ------------------------------- |
| Namespace            | `datacenter`                    |
| Pod                  | `time-check`                    |
| Container            | `time-check`                    |
| Image                | `busybox:latest`                |
| ConfigMap            | `time-config`                   |
| ConfigMap Data       | `TIME_FREQ=4`                   |
| Environment Variable | `TIME_FREQ`                     |
| Volume               | `log-volume`                    |
| Mount Path           | `/opt/data/time`                |
| Log File             | `/opt/data/time/time-check.log` |

The container should continuously write timestamps into:

```text
/opt/data/time/time-check.log
```

The interval between timestamps is controlled using the `TIME_FREQ` value stored in the ConfigMap.

---

## Manifest

Create:

```bash
vi time-check.yaml
```

Add:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: datacenter

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: time-config
  namespace: datacenter
data:
  TIME_FREQ: "4"

---
apiVersion: v1
kind: Pod
metadata:
  name: time-check
  namespace: datacenter
spec:
  containers:
    - name: time-check
      image: busybox:latest

      env:
        - name: TIME_FREQ
          valueFrom:
            configMapKeyRef:
              name: time-config
              key: TIME_FREQ

      command:
        - /bin/sh
        - -c
        - while true; do date; sleep $TIME_FREQ; done >> /opt/data/time/time-check.log

      volumeMounts:
        - name: log-volume
          mountPath: /opt/data/time

  volumes:
    - name: log-volume
      emptyDir: {}
```

---

## Apply the Manifest

```bash
kubectl apply -f time-check.yaml
```

Check the Pod:

```bash
kubectl get pods -n datacenter
```

Check the ConfigMap:

```bash
kubectl get configmap -n datacenter
```

View ConfigMap details:

```bash
kubectl describe configmap time-config -n datacenter
```

---

## Verify the Environment Variable

Run:

```bash
kubectl exec -n datacenter time-check -- printenv TIME_FREQ
```

Expected output:

```text
4
```

This confirms that the value from the ConfigMap was successfully injected into the container.

The flow is:

```text
ConfigMap
   │
   │ TIME_FREQ=4
   ↓
Pod
   ↓
Container Environment Variable
   ↓
$TIME_FREQ
```

---

## Verify the Log File

Run:

```bash
kubectl exec -n datacenter time-check -- \
  cat /opt/data/time/time-check.log
```

Example output:

```text
Wed Aug 5 12:00:01 UTC 2026
Wed Aug 5 12:00:05 UTC 2026
Wed Aug 5 12:00:09 UTC 2026
```

Because:

```text
TIME_FREQ=4
```

the container writes a timestamp approximately every **4 seconds**.

---

# Understanding ConfigMap

A ConfigMap stores **non-sensitive configuration outside the container image**.

Instead of hardcoding:

```bash
sleep 4
```

we use:

```bash
sleep $TIME_FREQ
```

The value comes from:

```yaml
data:
  TIME_FREQ: "4"
```

and is injected using:

```yaml
env:
  - name: TIME_FREQ
    valueFrom:
      configMapKeyRef:
        name: time-config
        key: TIME_FREQ
```

This separates configuration from application/container logic.

---

# Understanding Volumes

The Pod defines:

```yaml
volumes:
  - name: log-volume
    emptyDir: {}
```

The container mounts it:

```yaml
volumeMounts:
  - name: log-volume
    mountPath: /opt/data/time
```

Mental model:

```text
Pod
│
├── Volume
│     log-volume
│
└── Container
      │
      └── volumeMount
             ↓
       /opt/data/time
```

### Important

`volumes` are defined at the **Pod level**.

`volumeMounts` are defined at the **container level**.

---

# Understanding `emptyDir`

```yaml
emptyDir: {}
```

creates temporary storage for the Pod.

The directory exists for the **lifetime of the Pod**.

If the container restarts, the data remains because the Pod still exists.

If the Pod is deleted, the `emptyDir` data is deleted as well.

For persistent application data, Kubernetes typically uses a **PersistentVolume (PV)** and **PersistentVolumeClaim (PVC)** instead.

---

# Troubleshooting Learned

## Namespace Does Not Exist

If Kubernetes reports:

```text
namespaces "datacenter" not found
```

create the namespace:

```bash
kubectl create namespace datacenter
```

Then apply the resources again.

---

## CrashLoopBackOff Due to Incorrect Mount Path

If the command writes to:

```text
/opt/data/time/time-check.log
```

the volume should be mounted at:

```text
/opt/data/time
```

For example:

```yaml
volumeMounts:
  - name: log-volume
    mountPath: /opt/data/time
```

A mismatched path can cause the application command to fail, potentially causing the container to restart repeatedly.

Check the Pod:

```bash
kubectl get pods -n datacenter
```

Then investigate:

```bash
kubectl describe pod time-check -n datacenter
```

and:

```bash
kubectl logs time-check -n datacenter
```

---

# Immutable Pod Fields

Most Pod specification fields cannot be modified after the Pod has been created.

For example, changing:

* Commands
* Environment configuration
* Volumes
* Volume mounts
* Container configuration

may require recreating the Pod.

Delete it:

```bash
kubectl delete pod time-check -n datacenter
```

Then recreate it:

```bash
kubectl apply -f time-check.yaml
```

General delete syntax:

```bash
kubectl delete <resource-type> <resource-name> -n <namespace>
```

Example:

```bash
kubectl delete pod time-check -n datacenter
```

---

# Kubernetes YAML Mental Model

## Basic Pod

```text
Pod
└── spec
    ├── containers
    │   ├── name
    │   ├── image
    │   ├── command
    │   ├── env
    │   ├── resources
    │   └── volumeMounts
    │
    ├── volumes
    └── restartPolicy
```

---

## Deployment / ReplicaSet

Controllers contain a Pod template:

```text
Deployment / ReplicaSet
└── spec
    └── template
        ├── metadata
        └── spec
            └── containers
```

The important concept is:

```text
Deployment
    ↓
ReplicaSet
    ↓
Pod
    ↓
Container
```

---

## Job

```text
Job
└── spec
    └── template
        └── spec
            └── containers
```

---

## CronJob

CronJobs contain a Job template, which contains a Pod template.

```text
CronJob
└── spec
    └── jobTemplate
        └── spec
            └── template
                └── spec
                    └── containers
```

Therefore:

```text
CronJob
   ↓
Job
   ↓
Pod
   ↓
Container
```

---

# Useful Kubernetes Commands

## View Resources

```bash
kubectl get pods
```

```bash
kubectl get pods -n <namespace>
```

```bash
kubectl get deployments
```

```bash
kubectl get rs
```

```bash
kubectl get jobs
```

```bash
kubectl get cronjobs
```

```bash
kubectl get configmaps
```

---

## Get More Information

```bash
kubectl describe pod <pod>
```

```bash
kubectl describe deployment <deployment>
```

```bash
kubectl describe job <job>
```

```bash
kubectl describe cronjob <cronjob>
```

---

## Apply Resources

```bash
kubectl apply -f file.yaml
```

---

## Delete Resources

```bash
kubectl delete pod <pod-name>
```

With a namespace:

```bash
kubectl delete pod <pod-name> -n <namespace>
```

---

## Deployment Rollouts

Check rollout status:

```bash
kubectl rollout status deployment/<deployment>
```

View rollout history:

```bash
kubectl rollout history deployment/<deployment>
```

Rollback:

```bash
kubectl rollout undo deployment/<deployment>
```

---

## Update a Deployment Image

```bash
kubectl set image deployment/<deployment> \
  <container>=<image>
```

Example:

```bash
kubectl set image deployment/nginx \
  nginx=nginx:1.27
```

---

## Container Debugging

View logs:

```bash
kubectl logs <pod> -n <namespace>
```

Execute a command inside a container:

```bash
kubectl exec -n <namespace> <pod> -- <command>
```

Example:

```bash
kubectl exec -n datacenter time-check -- printenv TIME_FREQ
```

---

## Wide Output

Use:

```bash
kubectl get pods -o wide
```

The `-o` flag means **output format**.

`wide` tells Kubernetes to display additional information beyond the default columns.

For Pods, this can include information such as:

```text
NAME      READY   STATUS    RESTARTS   AGE   IP          NODE
nginx     1/1     Running   0          10m   10.1.0.12   node01
```

So:

```bash
kubectl get pod nginx-phpfpm -o wide
```

means:

> Get information about the `nginx-phpfpm` Pod and display additional details such as its IP address and the node where it is running.

---

# Interview Revision

| Resource       | Main Purpose                                       |
| -------------- | -------------------------------------------------- |
| **Pod**        | Smallest deployable Kubernetes workload            |
| **Namespace**  | Logical isolation/grouping of resources            |
| **ConfigMap**  | Store non-sensitive configuration                  |
| **ReplicaSet** | Maintain the desired number of Pod replicas        |
| **Deployment** | Manage ReplicaSets, updates, scaling and rollbacks |
| **Job**        | Run finite work to successful completion           |
| **CronJob**    | Run Jobs according to a schedule                   |
| **Volume**     | Provide storage accessible to containers           |

---

# Quick Architecture Revision

```text
Deployment
    ↓
ReplicaSet
    ↓
Pod
    ↓
Container
```

```text
CronJob
    ↓
Job
    ↓
Pod
    ↓
Container
```

```text
ConfigMap
    ↓
Environment Variable
    ↓
Container
```

```text
Pod Volume
    ↓
volumeMount
    ↓
Container Path
```

---

# Key Takeaways

* Containers run inside **Pods**.
* Pods are the smallest deployable Kubernetes workload.
* ReplicaSets maintain the desired number of Pod replicas.
* Deployments manage ReplicaSets and provide rolling updates and rollbacks.
* Jobs are designed for one-time or finite tasks.
* CronJobs create Jobs according to a cron schedule.
* ConfigMaps separate non-sensitive configuration from container images.
* `volumeMounts` are defined at the container level.
* `volumes` are defined at the Pod level.
* `emptyDir` exists for the lifetime of a Pod.
* Namespace-scoped resources require the namespace to exist.
* Most Pod specification fields cannot be modified after creation.
* `kubectl get` is used to view resources.
* `kubectl describe` provides detailed troubleshooting information.
* `kubectl logs` displays container logs.
* `kubectl exec` runs commands inside containers.
* `-o wide` displays additional resource information.
* Always verify your resources after applying Kubernetes manifests.
