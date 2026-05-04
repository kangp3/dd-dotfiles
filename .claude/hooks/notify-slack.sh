#!/bin/bash
# Send Slack notification via Datadog workflow
# Usage: notify-slack.sh "Your message here"

MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
  echo "Usage: $0 \"message\""
  exit 1
fi

# Use DD API/App keys provisioned by laptop-setup.sh via `dd-auth --workspace`.
# In workspaces they're exported by ~/.zshrc from encrypted pass store files.
# On macOS, dd-auth can generate them on demand if env vars aren't set.
if [ -z "${DD_API_KEY:-}" ] || [ -z "${DD_APP_KEY:-}" ]; then
  if command -v dd-auth >/dev/null 2>&1; then
    dd-auth --domain=app.datadoghq.com -o --actions-api > /tmp/dd_keys_slack.txt
    DD_API_KEY=$(grep DD_API_KEY /tmp/dd_keys_slack.txt | cut -d= -f2)
    DD_APP_KEY=$(grep DD_APP_KEY /tmp/dd_keys_slack.txt | cut -d= -f2)
  else
    echo "⚠️ DD_API_KEY/DD_APP_KEY not set and dd-auth not found. Run laptop-setup.sh <name> from your laptop."
    exit 1
  fi
fi

# Send notification and capture both response body and HTTP status
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -d "{\"meta\": {\"payload\":{\"user\": \"$USER@datadoghq.com\",\"message\":\"$MESSAGE\"}}}" \
  https://api.datadoghq.com/api/v2/workflows/0aa7e144-e474-4be5-9ba6-bb9480876d12/instances)

# Parse response body and status code
RESPONSE_BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS:/d')
HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS:" | cut -d: -f2)

# Check for successful workflow instance creation
if echo "$RESPONSE_BODY" | grep -q '"id"'; then
  INSTANCE_ID=$(echo "$RESPONSE_BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
  echo "✅ Slack notification sent (HTTP $HTTP_STATUS, instance: $INSTANCE_ID)"
  exit 0
else
  echo "⚠️ Workflow may not have executed (HTTP $HTTP_STATUS): $RESPONSE_BODY"
  exit 1
fi
