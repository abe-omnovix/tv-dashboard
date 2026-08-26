# Request: read-only AWS credentials for a home TV dashboard

Abe's TV screensaver shows a small ops readout (deploys, analytics, AWS
spend). It needs a **long-lived, read-only** credential because the TV
refreshes 24/7 and SSO sessions expire. Everything below is read-only and
revocable at any time.

## What to create

An IAM user with **no console access** and a minimal CloudWatch-read
policy:

```bash
cat > /tmp/skylight-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricData",
        "cloudwatch:ListMetrics"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-user --user-name skylight-tv
aws iam put-user-policy --user-name skylight-tv \
  --policy-name skylight-cloudwatch-read \
  --policy-document file:///tmp/skylight-policy.json
aws iam create-access-key --user-name skylight-tv
```

Send the resulting `AccessKeyId` + `SecretAccessKey` to Abe through a
secure channel (1Password share, not Slack plaintext).

## One account-level toggle (for the spend number)

The month-to-date bill is read from the free CloudWatch billing metric
(`AWS/Billing → EstimatedCharges`, us-east-1). That metric only exists if
**Billing preferences → "Receive Billing Alerts"** has been enabled once
for the account. If it's off, please flip it (no cost, no other effect).

## Revoking later

```bash
aws iam delete-access-key --user-name skylight-tv --access-key-id AKIA...
aws iam delete-user-policy --user-name skylight-tv --policy-name skylight-cloudwatch-read
aws iam delete-user --user-name skylight-tv
```
