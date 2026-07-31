# Kubernetes KodeKloud Tasks -- Learning Notes

## Task 1: Create Namespace and Pod

### Objective

-   Create namespace: `dev`
-   Create Pod: `dev-nginx-pod`
-   Image: `nginx:latest`

### Commands

``` bash
kubectl create namespace dev

kubectl run dev-nginx-pod \
  --image=nginx:latest \
  --restart=Never \
  -n dev

kubectl get pods -n dev
```

### Concepts

-   Namespace isolates Kubernetes resources.
-   A Pod is the smallest deployable unit.
-   `kubectl run` creates a Pod when `--restart=Never` is used.

------------------------------------------------------------------------

## Task 2: Create a Pod with Resource Requests and Limits

### Objective

Create `httpd-pod` with: - Container: `httpd-container` - Image:
`httpd:latest` - Requests: - CPU: `100m` - Memory: `15Mi` - Limits: -
CPU: `100m` - Memory: `20Mi`

### YAML

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: httpd-pod
spec:
  containers:
  - name: httpd-container
    image: httpd:latest
    resources:
      requests:
        cpu: "100m"
        memory: "15Mi"
      limits:
        cpu: "100m"
        memory: "20Mi"
```

### Apply

``` bash
kubectl apply -f pod.yaml
kubectl describe pod httpd-pod
```

### Concepts

-   Requests determine scheduling.
-   Limits prevent excessive resource usage.
-   CPU is throttled when exceeding its limit.
-   Memory limit violations cause `OOMKilled`.

------------------------------------------------------------------------

## Task 3: Rolling Update Deployment

### Objective

Update Deployment `nginx-deployment` to use `nginx:1.19`.

### Find Container Name

``` bash
kubectl get deployment nginx-deployment \
-o jsonpath='{.spec.template.spec.containers[*].name}'
```

### Update

``` bash
kubectl set image deployment/nginx-deployment \
nginx-container=nginx:1.19
```

### Verify

``` bash
kubectl rollout status deployment/nginx-deployment
kubectl get pods
```

### Concepts

-   `kubectl set image`
-   Rolling Update
-   ReplicaSet creation
-   Zero-downtime deployments

Command syntax:

``` text
kubectl set image <resource>/<name> <container>=<image>
```

------------------------------------------------------------------------

## Task 4: Rollback Deployment

### Objective

Rollback `nginx-deployment` to the previous revision.

### Commands

``` bash
kubectl rollout undo deployment/nginx-deployment

kubectl rollout status deployment/nginx-deployment

kubectl rollout history deployment/nginx-deployment
```

### Concepts

-   Deployment revisions
-   Rollback
-   Rollout history
-   `CHANGE-CAUSE`
-   New Pods are created during rollback because Pods are immutable.

------------------------------------------------------------------------

## Task 5: Create ReplicaSet

### Objective

Create ReplicaSet: - Name: `httpd-replicaset` - Image: `httpd:latest` -
Container: `httpd-container` - Replicas: `4` - Labels: - app:
`httpd_app` - type: `front-end`

### YAML

``` yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: httpd-replicaset
  labels:
    app: httpd_app
    type: front-end
spec:
  replicas: 4
  selector:
    matchLabels:
      app: httpd_app
  template:
    metadata:
      labels:
        app: httpd_app
    spec:
      containers:
      - name: httpd-container
        image: httpd:latest
```

### Apply

``` bash
kubectl apply -f replicaset.yaml
kubectl get rs
kubectl get pods
```

### Concepts

-   ReplicaSets maintain the desired number of Pods.
-   `selector.matchLabels` must match `template.metadata.labels`.
-   Containers are defined last because they belong inside the Pod
    specification.

------------------------------------------------------------------------

# Key kubectl Commands

``` bash
kubectl get pods
kubectl get deployments
kubectl get rs
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>
kubectl rollout status deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name>
kubectl rollout undo deployment/<deployment-name>
kubectl set image deployment/<deployment> <container>=<image>
kubectl apply -f <file>.yaml
```

# Interview Takeaways

-   Pod: Smallest deployable unit.
-   Namespace: Logical isolation.
-   ReplicaSet: Maintains desired Pod count.
-   Deployment: Manages ReplicaSets, rolling updates, and rollbacks.
-   Requests: Minimum guaranteed resources.
-   Limits: Maximum allowed resources.
-   Rolling Update: Gradually replaces Pods without downtime.
-   Rollback: Creates a new revision using a previous Pod template.
