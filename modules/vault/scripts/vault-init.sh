#!/bin/sh
# Vault Auto-Initialization Script
# Runs as init container to auto-initialize and unseal Vault

set -e

echo "Starting Vault auto-initialization..."

# Wait for Vault server to be ready
until vault status >/dev/null 2>&1 || [ $? -eq 2 ]; do
  echo "Waiting for Vault server to be ready..."
  sleep 5
done

# Check if Vault is already initialized
if vault status >/dev/null 2>&1; then
  echo "Vault is already initialized and unsealed"
  exit 0
fi

# Check if initialization is needed
if ! vault status 2>&1 | grep -q "Vault is sealed"; then
  echo "Initializing Vault..."

  # Initialize Vault with 5 key shares and threshold of 3
  vault operator init \
    -key-shares=5 \
    -key-threshold=3 \
    -format=json > /tmp/vault-init.json

  # Extract unseal keys and root token
  UNSEAL_KEY_1=$(jq -r '.unseal_keys_b64[0]' /tmp/vault-init.json)
  UNSEAL_KEY_2=$(jq -r '.unseal_keys_b64[1]' /tmp/vault-init.json)
  UNSEAL_KEY_3=$(jq -r '.unseal_keys_b64[2]' /tmp/vault-init.json)
  ROOT_TOKEN=$(jq -r '.root_token' /tmp/vault-init.json)

  # Store initialization data in Kubernetes secret
  kubectl create secret generic vault-init \
    --from-literal=unseal-key-1="$UNSEAL_KEY_1" \
    --from-literal=unseal-key-2="$UNSEAL_KEY_2" \
    --from-literal=unseal-key-3="$UNSEAL_KEY_3" \
    --from-literal=root-token="$ROOT_TOKEN" \
    -n vault || echo "Secret already exists"

  echo "Vault initialized successfully"
fi

# Unseal Vault
echo "Unsealing Vault..."
UNSEAL_KEY_1=$(kubectl get secret vault-init -n vault -o jsonpath='{.data.unseal-key-1}' | base64 -d)
UNSEAL_KEY_2=$(kubectl get secret vault-init -n vault -o jsonpath='{.data.unseal-key-2}' | base64 -d)
UNSEAL_KEY_3=$(kubectl get secret vault-init -n vault -o jsonpath='{.data.unseal-key-3}' | base64 -d)

vault operator unseal "$UNSEAL_KEY_1"
vault operator unseal "$UNSEAL_KEY_2"
vault operator unseal "$UNSEAL_KEY_3"

echo "Vault unsealed successfully"