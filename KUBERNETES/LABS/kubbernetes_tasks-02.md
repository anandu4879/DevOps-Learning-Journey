# Kubernetes Hands-On Practice — Tasks 9 to 12

This section documents my Kubernetes hands-on practice covering troubleshooting multi-container Pods, modifying live resources, exposing applications using Services, and debugging an Nginx + PHP-FPM architecture.

---

# Task 9 — Troubleshooting a Multi-Container Pod

## Scenario

A Pod named `webserver` contained two containers:

* `httpd-container`

  * Expected image: `httpd:latest`
* `sidecar-container`

  * Image: `ubuntu:latest`

The Pod was not working correctly and needed troubleshooting.

---

## Step 1 — Check Pod Status

```bash
kubectl get pods
```

The Pod showed that one of the containers was failing.

---

## Step 2 — Describe the Pod

```bash
kubectl describe pod webserver
```

The Events section revealed an image pull failure.

The configured image was:

```text
httpd:latests
```

instead of:

```text
httpd:latest
```

This caused an `ImagePullBackOff` because the tag `latests` did not exist.

---

## Step 3 — Check Individual Container Logs

For multi-container Pods, specify the container:

```bash
kubectl logs webserver -c httpd-container
```

```bash
kubectl logs webserver -c sidecar-container
```

For a restarting container:

```bash
kubectl logs webserver -c sidecar-container --previous
```

---

## Step 4 — Fix the Image

The container image can be updated directly:

```bash
kubectl set image pod/webserver \
httpd-container=httpd:latest
```

Syntax:

```text
kubectl set image <resource>/<resource-name> <container>=<image>
```

---

## Step 5 — Verify

```bash
kubectl get pods
```

Expected:

```text
NAME        READY   STATUS
webserver   2/2     Running
```

---

## Key Learning

A good Kubernetes troubleshooting workflow is:

```text
kubectl get pods
        ↓
Identify failing Pod
        ↓
kubectl describe pod
        ↓
Check Events
        ↓
kubectl logs -c <container>
        ↓
Identify root cause
        ↓
Apply smallest possible fix
        ↓
Verify
```

`kubectl describe` is especially useful for:

* `ImagePullBackOff`
* `CrashLoopBackOff`
* Scheduling failures
* Volume problems
* Probe failures

---

# Task 10 — Modify Existing Deployment and Service

## Scenario

Existing resources:

```text
Deployment: nginx-deployment
Service:    nginx-service
```

Required changes:

| Configuration |        Old |          New |
| ------------- | ---------: | -----------: |
| NodePort      |      30008 |        32165 |
| Replicas      |          1 |            5 |
| Image         | nginx:1.17 | nginx:latest |

The Deployment and Service must **not be deleted**.

---

## Step 1 — Inspect Existing Resources

```bash
kubectl get deployment nginx-deployment
```

```bash
kubectl get service nginx-service
```

```bash
kubectl describe deployment nginx-deployment
```

```bash
kubectl describe service nginx-service
```

---

## Step 2 — Scale Deployment

Change replicas from `1` to `5`:

```bash
kubectl scale deployment nginx-deployment --replicas=5
```

Verify:

```bash
kubectl get deployment nginx-deployment
```

Expected:

```text
READY
5/5
```

---

## Step 3 — Find Container Name

Before updating an image, identify the actual container name:

```bash
kubectl get deployment nginx-deployment \
-o jsonpath='{.spec.template.spec.containers[*].name}'
```

---

## Step 4 — Update Image

```bash
kubectl set image deployment/nginx-deployment \
<container-name>=nginx:latest
```

Monitor the rolling update:

```bash
kubectl rollout status deployment/nginx-deployment
```

---

## Step 5 — Change NodePort

Edit the Service:

```bash
kubectl edit service nginx-service
```

Find:

```yaml
nodePort: 30008
```

Change to:

```yaml
nodePort: 32165
```

Save and exit.

---

## Step 6 — Verify

```bash
kubectl get deployment nginx-deployment
```

```bash
kubectl get service nginx-service
```

```bash
kubectl get pods
```

Check the image:

```bash
kubectl get deployment nginx-deployment \
-o jsonpath='{.spec.template.spec.containers[*].image}'
```

Expected:

```text
nginx:latest
```

---

## Key Learning

Different changes have different `kubectl` commands:

```text
Replica count
     ↓
kubectl scale

Container image
     ↓
kubectl set image

Other configuration
     ↓
kubectl edit
```

Resources do not always need to be deleted and recreated.

---

# Task 11 — Expose a ReplicaSet Using NodePort

## Scenario

An existing ReplicaSet:

```text
nginx-replicaset
```

manages application Pods.

Pod labels:

```yaml
app: nginx_app
type: front-end
```

Requirements:

```text
Service: nginx-service
Type: NodePort
NodePort: 30080
Application Port: 80
```

The existing ReplicaSet must not be modified.

---

## Step 1 — Inspect ReplicaSet and Pod Labels

```bash
kubectl get rs nginx-replicaset
```

```bash
kubectl describe rs nginx-replicaset
```

Check Pod labels:

```bash
kubectl get pods --show-labels
```

Expected labels:

```text
app=nginx_app
type=front-end
```

---

## Step 2 — Create Service

Create:

```bash
vi service.yaml
```

Add:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort

  selector:
    app: nginx_app
    type: front-end

  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

Apply:

```bash
kubectl apply -f service.yaml
```

---

# Understanding Labels and Selectors

Pods have labels:

```yaml
labels:
  app: nginx_app
  type: front-end
```

The Service has selectors:

```yaml
selector:
  app: nginx_app
  type: front-end
```

Kubernetes matches them:

```text
Service
   │
   │ selector
   │
   │ app=nginx_app
   │ type=front-end
   ↓
Matching Pods
```

A Service does not directly connect to a ReplicaSet.

Instead:

```text
ReplicaSet
     │
     │ creates/manages
     ▼
    Pods
     ▲
     │ labels/selectors
     │
  Service
```

---

# Understanding NodePort

The Service contains:

```yaml
ports:
- port: 80
  targetPort: 80
  nodePort: 30080
```

Traffic flow:

```text
External User
      │
      │ NodeIP:30080
      ▼
Kubernetes Node
      │
      │ nodePort: 30080
      ▼
nginx-service
      │
      │ port: 80
      ▼
Selected Pod
      │
      │ targetPort: 80
      ▼
Nginx
```

### nodePort

```yaml
nodePort: 30080
```

External port exposed on Kubernetes nodes.

### port

```yaml
port: 80
```

Port exposed by the Service.

### targetPort

```yaml
targetPort: 80
```

Port where the application is listening in the selected Pods.

---

## Step 3 — Verify Service

```bash
kubectl get svc nginx-service
```

Expected:

```text
80:30080/TCP
```

Check endpoints:

```bash
kubectl get endpoints nginx-service
```

If Pod IPs appear, the Service successfully found its backend Pods.

If you see:

```text
<none>
```

check:

```bash
kubectl get pods --show-labels
```

and:

```bash
kubectl describe svc nginx-service
```

The Service selector probably does not match the Pod labels.

---

## Key Learning

The important relationship is:

```text
Pod labels
     ↕
Service selectors
```

Services provide a stable network endpoint even though individual Pods may be destroyed and recreated with different IP addresses.

---

# Task 12 — Troubleshoot Nginx + PHP-FPM

## Scenario

Resources:

```text
Pod:       nginx-phpfpm
ConfigMap: nginx-config
Service:   nginx-service
```

The Pod contains:

```text
nginx-container
php-fpm-container
```

Both containers were running, but the application configuration had an issue.

---

# Step 1 — Inspect Pod

```bash
kubectl get pod nginx-phpfpm -o wide
```

```bash
kubectl describe pod nginx-phpfpm
```

The Pod showed:

```text
2/2 Running
```

This told us:

> The problem was not that the containers were crashing.

---

# Step 2 — Inspect Logs

```bash
kubectl logs nginx-phpfpm -c nginx-container
```

```bash
kubectl logs nginx-phpfpm -c php-fpm-container
```

Both processes were healthy.

PHP-FPM reported that it was ready to handle connections.

---

# Step 3 — Inspect ConfigMap

```bash
kubectl get configmap nginx-config -o yaml
```

Nginx configuration contained:

```nginx
server {
    listen 8099 default_server;
    listen [::]:8099 default_server;

    root /var/www/html;

    index index.html index.htm index.php;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;

        fastcgi_param REQUEST_METHOD $request_method;

        fastcgi_param SCRIPT_FILENAME \
        $document_root$fastcgi_script_name;

        fastcgi_pass 127.0.0.1:9000;
    }
}
```

---

# Step 4 — Inspect Volume Mounts

```bash
kubectl get pod nginx-phpfpm -o yaml
```

The important discovery was:

### nginx-container

```text
shared-files → /var/www/html
```

### php-fpm-container

```text
shared-files → /usr/share/nginx/html
```

But Nginx sends PHP-FPM:

```nginx
SCRIPT_FILENAME $document_root$fastcgi_script_name;
```

And:

```nginx
root /var/www/html;
```

Therefore a request for:

```text
/index.php
```

becomes:

```text
/var/www/html/index.php
```

PHP-FPM must therefore also see the shared files at:

```text
/var/www/html
```

The PHP-FPM volume mount was the configuration mismatch.

---

# Correct Architecture

Both containers should access the shared application files using:

```text
/var/www/html
```

Architecture:

```text
                   shared-files
                     emptyDir
                        │
               ┌────────┴────────┐
               │                 │
               ▼                 ▼
        nginx-container    php-fpm-container
               │                 │
         /var/www/html      /var/www/html
               │                 │
               └──── index.php ──┘
```

---

# Why localhost Works Between Containers

Nginx configuration uses:

```nginx
fastcgi_pass 127.0.0.1:9000;
```

This works because containers inside the same Pod share the Pod's network namespace.

```text
Pod
│
├── nginx-container
│       │
│       │ localhost:9000
│       ▼
│
└── php-fpm-container
        │
        └── PHP-FPM :9000
```

Containers in the same Pod can communicate using `localhost`.

---

# Step 5 — Correct the Pod Configuration

Because Pod volume mounts are generally immutable, changing the mount requires recreating the Pod with the corrected configuration.

A clean version of the existing manifest can be obtained from its last-applied configuration:

```bash
kubectl get pod nginx-phpfpm \
-o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}' \
> /tmp/nginx-phpfpm.json
```

Edit:

```bash
vi /tmp/nginx-phpfpm.json
```

Find the `php-fpm-container`.

Change:

```text
/usr/share/nginx/html
```

to:

```text
/var/www/html
```

The final relationship should be:

```text
nginx-container
shared-files → /var/www/html

php-fpm-container
shared-files → /var/www/html
```

Recreate:

```bash
kubectl delete pod nginx-phpfpm
```

```bash
kubectl apply -f /tmp/nginx-phpfpm.json
```

Verify:

```bash
kubectl get pod nginx-phpfpm
```

Expected:

```text
nginx-phpfpm   2/2   Running
```

---

# Step 6 — Copy index.php

The Nginx document root is:

```text
/var/www/html
```

Copy the provided PHP file:

```bash
kubectl cp /home/thor/index.php \
nginx-phpfpm:/var/www/html/index.php \
-c nginx-container
```

---

# Step 7 — Verify Shared File

Check from Nginx:

```bash
kubectl exec nginx-phpfpm \
-c nginx-container -- \
ls -l /var/www/html/index.php
```

Check from PHP-FPM:

```bash
kubectl exec nginx-phpfpm \
-c php-fpm-container -- \
ls -l /var/www/html/index.php
```

Both containers should see the same file.

---

# Step 8 — Verify Service

```bash
kubectl get svc
```

The Service exposes:

```text
8099:30008/TCP
```

Nginx listens on:

```nginx
listen 8099;
```

Therefore the networking path is:

```text
Browser
   │
   │ NodePort 30008
   ▼
nginx-service
   │
   │ Service port 8099
   ▼
nginx-container
   │
   │ Nginx :8099
   ▼
/var/www/html/index.php
   │
   │ FastCGI
   ▼
127.0.0.1:9000
   │
   ▼
php-fpm-container
```

---

# Kubernetes Troubleshooting Workflow Learned

These tasks reinforced a systematic troubleshooting process:

```text
1. kubectl get
        ↓
2. kubectl describe
        ↓
3. Check Events
        ↓
4. kubectl logs
        ↓
5. Inspect YAML
        ↓
6. Compare expected vs actual configuration
        ↓
7. Apply smallest possible fix
        ↓
8. Verify application
```

Useful commands:

```bash
kubectl get pods
kubectl get pods -o wide
kubectl describe pod <pod>
kubectl logs <pod> -c <container>
kubectl get pod <pod> -o yaml
kubectl get svc
kubectl get endpoints <service>
kubectl get pods --show-labels
```

---

# Key Concepts Learned — Tasks 9 to 12

| Concept             | What I Learned                                                    |
| ------------------- | ----------------------------------------------------------------- |
| Multi-container Pod | A Pod can contain multiple cooperating containers                 |
| `kubectl describe`  | Useful for identifying failures and inspecting Events             |
| Container logs      | Use `-c` when a Pod contains multiple containers                  |
| `ImagePullBackOff`  | Often caused by invalid image names/tags or registry problems     |
| `kubectl set image` | Update container images                                           |
| `kubectl scale`     | Change Deployment replica count                                   |
| `kubectl edit`      | Modify existing Kubernetes resources                              |
| ReplicaSet          | Maintains the desired number of Pods                              |
| Service             | Provides stable network access to Pods                            |
| Labels              | Identify Kubernetes resources                                     |
| Selectors           | Allow controllers and Services to find matching Pods              |
| NodePort            | Exposes a Service through a port on Kubernetes nodes              |
| `port`              | Service-facing port                                               |
| `targetPort`        | Destination port on selected Pods                                 |
| ConfigMap           | Stores application configuration separately from container images |
| `emptyDir`          | Temporary Pod-level storage shared between containers             |
| `volumeMount`       | Makes a Pod volume available inside a container                   |
| Pod networking      | Containers in the same Pod can communicate through `localhost`    |
| Pod immutability    | Many Pod spec fields require recreation to change                 |

---

# Important Mental Models

## Deployment

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
    ↓
Containers
```

## Service

```text
Service selector
       ↓
Pod labels
       ↓
Matching Pods
```

## NodePort

```text
External User
     ↓
NodeIP:NodePort
     ↓
Service Port
     ↓
targetPort
     ↓
Application
```

## Multi-Container Pod

```text
                 Pod
                  │
        ┌─────────┴─────────┐
        │                   │
   Container A         Container B
        │                   │
        └── Shared Volume ──┘

Containers also share the Pod network.
```

---

# Final Takeaway

The biggest lesson from these tasks was not memorizing `kubectl` commands.

The important skill is understanding the flow:

```text
Observe
   ↓
Find the failing layer
   ↓
Understand why it failed
   ↓
Fix only the incorrect configuration
   ↓
Verify
```

For Kubernetes troubleshooting, always start with:

```bash
kubectl get
kubectl describe
kubectl logs
```

Then inspect the YAML and follow the application's actual traffic, storage, and container relationships.
