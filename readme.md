

> Application → Docker → Helm → Kubernetes → Argo CD (GitOps)
> Local setup using **Kind**

No fluff. Just structured execution.

---

# 🧱 FINAL TARGET ARCHITECTURE

```
GitHub (demo-gitops)
        ↓
Argo CD (inside cluster)
        ↓
Helm Chart
        ↓
Kubernetes (Kind)
        ↓
Docker Container (Your App)
```

---

# 🚀 PHASE 1 — APPLICATION

## ✅ 1. Create Simple App

Example: simple Node/Java app or even static nginx.

Project structure:

```
demo-app/
 ├── Dockerfile
 └── app code
```

---

# 🐳 PHASE 2 — DOCKER

## ✅ 2. Create Dockerfile

Example:

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
```

---

## ✅ 3. Build Image

```bash
docker build -t yourdockerhub/demo-app:1.0 .
```

---

## ✅ 4. Push Image (Private or Public)

```bash
docker login
docker push yourdockerhub/demo-app:1.0
```

If private:

```bash
kubectl create secret docker-registry regcred \
  --docker-username=USERNAME \
  --docker-password=PASSWORD \
  --docker-email=EMAIL
```

---

# ☸️ PHASE 3 — KUBERNETES (Kind Cluster)

## ✅ 5. Create Kind Cluster

```bash
kind create cluster --name gitops-cluster
```

Check:

```bash
kubectl get nodes
```

---

# 📦 PHASE 4 — HELM CHART

## ✅ 6. Create Helm Chart

```bash
helm create demo-app
```

Structure:

```
demo-gitops/
 ├── apps/
 │    └── demo-app/
 │         ├── Chart.yaml
 │         ├── values.yaml
 │         └── templates/
```

---

## ✅ 7. Update values.yaml

```yaml
replicaCount: 2

image:
  repository: yourdockerhub/demo-app
  tag: "1.0"
  pullPolicy: IfNotPresent

imagePullSecrets:
  - name: regcred

service:
  type: ClusterIP
  port: 80
```

---

## ✅ 8. Ensure deployment.yaml Uses Values

```yaml
replicas: {{ .Values.replicaCount }}

image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

---

# 🌍 PHASE 5 — INSTALL ARGO CD

## ✅ 9. Install Argo CD

```bash
kubectl create namespace argocd

kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait:

```bash
kubectl get pods -n argocd
```

All must be Running.

---

## ✅ 10. Access Argo CD

```bash
kubectl port-forward svc/argocd-server -n argocd 9090:443
```

Open:

```
https://localhost:9090
```

---

# 📁 PHASE 6 — GITOPS REPO STRUCTURE

## ✅ 11. Final GitHub Structure

```
demo-gitops/
 ├── apps/
 │    └── demo-app/   (Helm chart)
 └── argocd/
      └── demo-app-application.yaml
```

---

## ✅ 12. Argo CD Application File

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR_USERNAME/demo-gitops.git
    targetRevision: HEAD
    path: apps/demo-app
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## ✅ 13. Push to GitHub

```bash
git init
git remote add origin https://github.com/YOUR_USERNAME/demo-gitops.git
git add .
git commit -m "initial gitops setup"
git branch -M main
git push -u origin main
```

---

# 🔄 PHASE 7 — CONNECT ARGO CD

## ✅ 14. Apply Application

```bash
kubectl apply -f argocd/demo-app-application.yaml
```

Check:

```bash
kubectl get applications -n argocd
kubectl get pods
```

Pods should be created automatically.

---

# 🔁 PHASE 8 — GITOPS FLOW TEST

## ✅ 15. Change Replica

Edit:

```yaml
replicaCount: 3
```

Push:

```bash
git add .
git commit -m "scale to 3"
git push
```

Argo CD detects change → redeploys.

Check:

```bash
kubectl get pods
```

You now have 3 replicas.

---

# 🧠 WHAT IS HAPPENING INTERNALLY

```
Git push
   ↓
Argo CD polls repo
   ↓
Repo-server renders Helm
   ↓
Argo CD compares desired vs live
   ↓
kubectl apply (internally)
   ↓
Kubernetes reconciles
```

