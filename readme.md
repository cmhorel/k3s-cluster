# Hosts - Arch & Names

Originally was going to do k0s. Naw I'm too lazy to change them

horel-k0s-1 - chromebook 192.168.0.204
horel-k0s-2 - rpi 4 192.168.0.168
horel-k0s-3 - rpi3b 192.168.0.4

## Hosts Entries
```
192.168.0.4     horel-k0s-3
192.168.0.204   horel-k0s-1
192.168.0.168   horel-k0s-2
```

## Nginx Config (not using this any longer, using a single control plane node)
```
frontend cluster_front
   bind 192.168.0.200:8443
   stats uri /haproxy?stats
#   option tcplog
   default_backend cluster_back

backend cluster_back
#   mode tcp
   option ssl-hello-chk
   balance roundrobin
   server horel-k0s-1 192.168.0.204:6443 check
   server horel-k0s-2 192.168.0.168:6443 check
   server horel-k0s-3 192.168.0.4:6443 check

frontend argo_front
   bind 192.168.0.200:10443
   stats uri /haproxy?stats
#   option tcplog
   default_backend argo_back

backend argo_back
#   mode tcp
   stick-table type ip  size 1m  expire 30m
   stick on src
   option ssl-hello-chk
   balance roundrobin
   server horel-k0s-1 192.168.0.204:10443 check
   server horel-k0s-2 192.168.0.168:10443 check
   server horel-k0s-3 192.168.0.4:10443 check

resolvers mynameservers
  nameserver horel-k0s-1 192.168.0.204:53
  nameserver horel-k0s-2 192.168.0.168:53
  nameserver horel-k0s-3 192.168.0.4:53
```

## Setup K3S
```
#Add token to environment on all nodes
export K3S_TOKEN=somesecret
#Add k3s url to only machines that will be WORKERS
export K3S_URL=https://horel-k0s-2:6443 
#(add to /etc/environment)

#Run on all 3 hosts. First control plane, then once it finishes join others.
curl -sfL https://get.k3s.io | sh -
```

## Host Setup Steps

1. Annoying process to connect monitor & set root password
2. enable root login or user acct & sudo
3. Set env (k3s token/url) /etc/environment
4. set /etc/hostname
5. populate /etc/hosts
6. apt update && apt upgrade
7. Setup unattended upgrades
8. Setup k3s steps
9. Install SSH Key

## Post Setup Bootstrap
```
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace -f .\releases\argocd\argocd-values.yaml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
#login to argo and configure a repo. Need URL, github username & PAT.
kubectl apply -f .\bootstrap\app-of-apps.yaml
```

## Bootstrap Vault
```
vault operator init \
    -key-shares=1 \
    -key-threshold=1 

cd /tmp
wget https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64
chmod +x jq-linux-arm64
ln -s ./jq-linux-amd64 jq
vault secrets enable -version=2 kv
vault kv put kv/pihole/admin password=<password> username=admin
vault kv put kv/grafana/admin password=dsafdfa username=admin
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write -field=certificate pki/root/generate/internal \
     common_name="horel.io" \
     issuer_name="horel-certs" \
     ttl=87600h > horel-ca-root.crt
vault write pki/roles/horelio-servers allow_any_name=true
vault write pki/config/urls \
     issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
     crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int
vault write -format=json pki_int/intermediate/generate/internal \
     common_name="horel.io Intermediate Authority" \
     issuer_name="horel-dot-io-certificate"  \
     | ./jq -r '.data.csr' > pki_intermediate.csr

vault write -format=json pki/root/sign-intermediate \
     issuer_ref="horel-certs" \
     csr=@pki_intermediate.csr \
     format=pem_bundle ttl="43800h" \
     | ./jq -r '.data.certificate' > intermediate.cert.pem

vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem

vault write pki_int/roles/horel-dot-io \
     issuer_ref="$(vault read -field=default pki_int/config/issuers)" \
     allowed_domains="horel.io" \
     allow_subdomains=true \
     max_ttl="720h"


```

## Secret For ESO Cluster Store
```
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
  namespace: vault
data:
  token: Blah=
```


