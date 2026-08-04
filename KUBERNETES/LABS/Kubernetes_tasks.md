6. Kubernetes CronJob

Requirements

CronJob: nautilus

Schedule: */9 * * * *

Container: cron-nautilus

Image: httpd:latest

Command: echo Welcome to xfusioncorp!

Restart policy: OnFailure

Manifest

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

kubectl apply -f cronjob.yaml
kubectl get cronjobs
kubectl get jobs

Key Learning

CronJob
   ↓
Job
   ↓
Pod
   ↓
Container

*/9 * * * * means every 9 minutes.

7. Countdown Job

Requirements

Job: countdown-nautilus

Pod template metadata name: countdown-nautilus

Container: container-countdown-nautilus

Image: fedora:latest

Command: sleep 5

Restart policy: Never

Manifest

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

kubectl apply -f job.yaml
kubectl get jobs
kubectl get pods

Key Learning

A Job is designed for finite work that should complete. A Deploymentkeeps applications running; a Job runs work until successful completion.

8. Time Check Pod with ConfigMap and Volume

Requirements

Namespace: datacenter

Pod: time-check

Container: time-check

Image: busybox:latest

ConfigMap: time-config

ConfigMap data: TIME_FREQ=4

Environment variable TIME_FREQ from the ConfigMap

Command writes timestamps to /opt/data/time/time-check.log

Volume: log-volume

Mount path: /opt/data/time

Manifest

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

Apply and verify:

kubectl apply -f time-check.yaml

kubectl get pods -n datacenter
kubectl get configmap -n datacenter

kubectl exec -n datacenter time-check -- printenv TIME_FREQ

kubectl exec -n datacenter time-check -- \
  cat /opt/data/time/time-check.log

Troubleshooting Learned

If Kubernetes reports:

namespaces "datacenter" not found

create the namespace first:

kubectl create namespace datacenter

If the command writes to /opt/data/time/..., the volume must also bemounted at /opt/data/time. A mismatched mount path can cause thecontainer to exit and enter CrashLoopBackOff.

Most Pod specification fields are immutable. If the Pod already existsand you change its command, volumes, mounts, or environmentconfiguration, delete and recreate it:

kubectl delete pod time-check -n datacenter
kubectl apply -f time-check.yaml

Delete syntax:

kubectl delete <resource-type> <resource-name> -n <namespace>

Example:

kubectl delete pod time-check -n datacenter

Kubernetes YAML Mental Model

For a basic Pod:

Pod
└── spec
    ├── containers
    │   ├── image
    │   ├── command
    │   ├── env
    │   ├── resources
    │   └── volumeMounts
    ├── volumes
    └── restartPolicy

For controllers:

Deployment / ReplicaSet
└── spec
    └── template
        └── spec
            └── containers

For scheduled workloads:

CronJob
└── jobTemplate
    └── spec
        └── template
            └── spec
                └── containers

Useful Commands

# Resources
kubectl get pods
kubectl get pods -n <namespace>
kubectl get deployments
kubectl get rs
kubectl get jobs
kubectl get cronjobs
kubectl get configmaps

# Details
kubectl describe pod <pod>
kubectl describe deployment <deployment>

# Apply/delete
kubectl apply -f file.yaml
kubectl delete pod <pod-name> -n <namespace>

# Deployment rollout
kubectl rollout status deployment/<deployment>
kubectl rollout history deployment/<deployment>
kubectl rollout undo deployment/<deployment>

# Update image
kubectl set image deployment/<deployment> \
  <container>=<image>

# Container debugging
kubectl logs <pod> -n <namespace>
kubectl exec -n <namespace> <pod> -- <command>

Interview Revision

Resource     Main Purpose

Pod          Smallest deployable Kubernetes workloadNamespace    Logical isolation of resourcesConfigMap    Store non-sensitive configurationReplicaSet   Maintain a desired number of PodsDeployment   Manage ReplicaSets, updates and rollbacksJob          Run finite work to completionCronJob      Run Jobs on a scheduleVolume       Provide storage accessible to containers

Key Takeaways

Containers run inside Pods.

ReplicaSets maintain Pod replica counts.

Deployments manage ReplicaSets and provide rollingupdates/rollbacks.

Jobs are for one-time finite tasks.

CronJobs create Jobs according to a cron schedule.

ConfigMaps separate configuration from container images.

volumeMounts are container-level; volumes are Pod-level.

Namespace-scoped resources require the namespace to exist first.

Most Pod spec fields cannot be modified after creation.

Always verify with kubectl get, kubectl describe,kubectl logs, and kubectl exec.