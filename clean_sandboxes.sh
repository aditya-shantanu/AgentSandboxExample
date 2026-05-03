#!/bin/bash
echo "Deleting all SandboxClaims..."
kubectl delete sandboxclaim --all

echo "Waiting for all SandboxClaims to be deleted..."
while true; do
    OUTPUT=$(kubectl get sandboxclaim --no-headers 2>/dev/null)
    if [ -z "$OUTPUT" ]; then
        echo "All SandboxClaims deleted."
        break
    fi
    COUNT=$(echo "$OUTPUT" | wc -l | tr -d ' ')
    echo "Still waiting for $COUNT SandboxClaims to be deleted..."
    sleep 2
done

echo "Deleting warm pool pods..."
kubectl delete pods -l app=demo-agent --ignore-not-found

echo "Restarting main application deployment to synchronize in-memory state..."
kubectl rollout restart deployment main-app-deployment -n main-app-ns
kubectl rollout status deployment main-app-deployment -n main-app-ns

echo "Cleanup complete."
