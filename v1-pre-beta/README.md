# CrunchClock k8 Ollama Image: v1-pre-beta

Welcome to the **v1-pre-beta** release of the CrunchClock k8 Ollama image! This Docker image provides a convenient way to run [Ollama](https://github.com/jmorganca/ollama) with a specified LLM model (`llama3` in this example) under Ubuntu 22.04, and is prepped for Kubernetes deployments.

> **Important:** This is a **pre-beta** release. Expect potential breaking changes, limited stability, and minimal performance tuning at this stage. We welcome feedback and bug reports to improve it.

---

## Overview

- **Base Image**: Ubuntu 22.04  
- **Ollama Installation**: [Ollama’s official install script](https://ollama.com/install.sh)  
- **Default Model**: `llama3` (replace or override as needed)  
- **Port Exposed**: 11434 (Ollama’s default HTTP API port)  

When the container starts, it automatically serves Ollama via `ollama serve --model llama3`. You can call the service at `http://<container-host-or-ip>:11434/api/generate`.

---

## Dockerfile

Below is the core Dockerfile used for this **v1-pre-beta** release:

```dockerfile
FROM ubuntu:22.04

# Install curl and libclang-dev (dependencies for Ollama)
RUN apt-get update && \
    apt-get install -y curl libclang-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Ollama via script (fetches the Linux binary release)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Pull the desired model (e.g., "llama3")
RUN ollama pull llama3

# Expose Ollama’s default port
EXPOSE 11434

# Start Ollama serving the "llama3" model
CMD ["ollama", "serve", "--model", "llama3"]
```

You can adapt or extend this Dockerfile to suit your needs (such as adding additional dependencies, mounting volumes for models, etc.).

---

## Building the Image

1. **Clone** or create a local folder containing the Dockerfile (above).
2. **Build** the image, tagging it as `crunchclock-k8-ollama:v1-pre-beta` (example):

   ```bash
   docker build -t crunchclock-k8-ollama:v1-pre-beta .
   ```

3. **Verify** that it built successfully:

   ```bash
   docker images | grep crunchclock-k8-ollama
   ```

---

## Running Locally (Optional)

You can test the container locally before pushing to a registry:

```bash
docker run -it -p 11434:11434 crunchclock-k8-ollama:v1-pre-beta
```

- **Check logs**: ensure there are no errors.  
- **Test**:  
  ```bash
  curl -X POST -H "Content-Type: application/json" \
  -d '{"prompt":"Hello Llama3"}' \
  http://localhost:11434/api/generate
  ```

You should receive a JSON response from the Ollama service.

---

## Pushing to a Container Registry

Once you’ve tested locally, push the image to your preferred container registry (Docker Hub, ECR, GCR, etc.):

```bash
docker tag crunchclock-k8-ollama:v1-pre-beta your-registry/crunchclock-k8-ollama:v1-pre-beta
docker push your-registry/crunchclock-k8-ollama:v1-pre-beta
```

Replace `your-registry` with the actual registry address (for example, `docker.io/username`, `ghcr.io/orgname`, etc.).

---

## Deploying to Kubernetes

Below is a minimal Deployment and Service manifest to run **CrunchClock k8 Ollama** in Kubernetes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: crunchclock-ollama-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: crunchclock-ollama
  template:
    metadata:
      labels:
        app: crunchclock-ollama
    spec:
      containers:
      - name: crunchclock-ollama
        image: your-registry/crunchclock-k8-ollama:v1-pre-beta
        ports:
          - containerPort: 11434
        # Optional: If you have large resource needs, specify requests/limits
        # resources:
        #   requests:
        #     memory: "4Gi"
        #     cpu: "2"
        #   limits:
        #     memory: "8Gi"
        #     cpu: "4"
---
apiVersion: v1
kind: Service
metadata:
  name: crunchclock-ollama-service
spec:
  selector:
    app: crunchclock-ollama
  ports:
  - protocol: TCP
    port: 11434
    targetPort: 11434
```

### Apply to Your Cluster

```bash
kubectl apply -f k8-ollama-deployment.yaml
```

*(Update the filename or YAML contents to match your environment.)*

### Verify

- **Check pods**:
  ```bash
  kubectl get pods
  ```
  Ensure the `crunchclock-ollama` pod is running.

- **Check service**:
  ```bash
  kubectl get svc
  ```
  Confirm there is a `crunchclock-ollama-service` exposing port 11434.

- **Test from inside the cluster** (e.g., via a debug pod):
  ```bash
  curl http://crunchclock-ollama-service:11434/api/generate \
    -X POST -H "Content-Type: application/json" \
    -d '{"prompt":"Hello from inside k8s"}'
  ```

---

## Model Management Notes

- By default, this image **bakes in** the `llama3` model. This can inflate the Docker image size by gigabytes, depending on the model size.  
- If you prefer not to bake large models into the image, consider:
  - **Pulling models at runtime** using an override `CMD` or entrypoint.  
  - **Mounting a volume** containing your models so they don’t live in the container itself.  

---

## Known Limitations (Pre-Beta)

1. **Resource Usage**: Large LLMs can consume significant memory and CPU. Validate your cluster capacity and consider adjusting resource requests/limits.  
2. **Model “llama3”**: Ensure you have a valid `llama3` model name or replace it with one Ollama supports (e.g., `llama2`, `llama2-7b`, etc.).  
3. **Scalability**: Scaling multiple replicas of this Pod can lead to high memory usage across the cluster (each Pod loads the model).  
4. **Logging & Monitoring**: Minimal logging is enabled by default. You may want to incorporate more robust monitoring for production usage.

---

## Feedback & Contributions

Since this is **v1-pre-beta** for CrunchClock’s Ollama image, we appreciate any feedback, bug reports, or pull requests. Please reach out through your usual CrunchClock channels or repository issues.

**Thank you** for trying out the CrunchClock k8 Ollama image! We look forward to improving it based on your input.  