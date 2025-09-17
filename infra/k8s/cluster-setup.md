# k0s cluster setup (dev)

- Install k0s: https://docs.k0sproject.io/
- Create controller+worker (single node for dev):

```bash
k0s install controller --single
k0s start
```

```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

```
helm repo add apisix https://charts.apiseven.com && helm repo update
```
```
helm template apisix apisix/apisix --namespace apisix --create-namespace --set ingress-controller.enabled=true --set ingress-controller.config.apisix.serviceNamespace=apisix > infra/k8s/platform/apisix/rendered.yaml
```

- Install kube tools (kubectl, kustomize).
- Install APISIX Ingress Controller via Helm.
- Install SuperTokens via Helm/manifest.
- Configure Cloudflare Tunnel to forward dev/auth/gateway domains to APISIX.
