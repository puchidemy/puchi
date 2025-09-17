# SuperTokens manifests for host-self

This folder contains SuperTokens ingress and example values for the self-host setup.

## Files

- `ingress.yaml`: APISIX ingress for SuperTokens (auth.puchi.io.vn)
- `values.example.yaml`: Example Helm values for SuperTokens
- `kustomization.yaml`: Kustomize configuration

## Usage

1. Install SuperTokens via Helm (see main README)
2. Apply ingress: `kubectl apply -k manifests/supertokens/`
3. Configure DNS: point auth.puchi.io.vn to APISIX

## Notes

- SuperTokens handles its own auth flow; don't add APISIX auth plugins to this route
- Adjust values.example.yaml for your environment before using
