# Kubernetes deployment (minikube)

Manifests to run the LMS platform (Django app + PostgreSQL + Redis) in a
dedicated `lms` namespace.

| File | Resource(s) |
|------|-------------|
| `00-namespace.yaml` | `lms` Namespace |
| `10-postgres.yaml` | Postgres **StatefulSet** + headless Service + ConfigMap + Secret |
| `20-redis.yaml` | Redis Deployment + Service |
| `30-web-config.yaml` | Web **ConfigMap** + **Secret** |
| `40-web-deployment.yaml` | Web **Deployment** (`magnolija/lmsproject:latest`) |
| `50-web-service.yaml` | Web **Service** (ClusterIP) |
| `60-web-ingress.yaml` | Web **Ingress** (`lms.local`) |

## 1. Start minikube and enable ingress
```bash
minikube start
minikube addons enable ingress
```

## 2. Apply everything
```bash
kubectl apply -f k8s/
```

## 3. Watch it come up
```bash
kubectl get pods -n lms -w
```
The web pod runs migrations + collectstatic on start, so it may take a
minute before it becomes Ready.

## 4. Map the hostname to the ingress
```bash
echo "$(minikube ip) lms.local" | sudo tee -a /etc/hosts
```

## 5. Open the app
```bash
curl -H "Host: lms.local" http://$(minikube ip)/
# or simply open http://lms.local in a browser
```

## Useful checks
```bash
kubectl get all,ingress,configmap,secret,pvc -n lms
kubectl logs -n lms deploy/lms-web
kubectl exec -n lms statefulset/postgres -- psql -U lms -d lms -c '\dt'
```

## Tear down
```bash
kubectl delete namespace lms
```
