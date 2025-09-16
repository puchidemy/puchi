# k0s cluster setup (dev)

- Install k0s: https://docs.k0sproject.io/
- Create controller+worker (single node for dev):

```bash
k0s install controller --single
k0s start
```

- Install kube tools (kubectl, kustomize).
- Install APISIX Ingress Controller via Helm.
- Install SuperTokens via Helm/manifest.
- Configure Cloudflare Tunnel to forward dev/auth/gateway domains to APISIX.
