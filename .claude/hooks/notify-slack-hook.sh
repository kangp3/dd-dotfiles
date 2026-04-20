#!/bin/bash
# Hook wrapper for Slack notifications on blocking/idle events
# Reads JSON from stdin and sends contextual Slack messages

INPUT=$(cat)
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name')

# Get worktree directory name for context
WORKTREE=""
if git rev-parse --show-toplevel &>/dev/null; then
  WORKTREE_PATH=$(git rev-parse --show-toplevel)
  WORKTREE="[$(basename "$WORKTREE_PATH")] "
fi

# Build context-aware message based on event type
case "$HOOK_EVENT" in
  "Notification")
    NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type')
    NOTIFICATION_MSG=$(echo "$INPUT" | jq -r '.message')
    case "$NOTIFICATION_TYPE" in
      "permission_prompt")
        MESSAGE="${WORKTREE}🔔 Claude needs permission: $NOTIFICATION_MSG"
        ;;
      "elicitation_dialog")
        MESSAGE="${WORKTREE}❓ Claude is asking: $NOTIFICATION_MSG"
        ;;
      *)
        # Skip other notification types
        exit 0
        ;;
    esac
    ;;

  "Stop")
    MESSAGE="${WORKTREE}✅ Claude finished responding"
    ;;

  "TeammateIdle")
    TEAMMATE=$(echo "$INPUT" | jq -r '.teammate_name')
    MESSAGE="${WORKTREE}💤 Teammate '$TEAMMATE' is going idle"
    ;;

  "TaskCompleted")
    TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')
    MESSAGE="${WORKTREE}✓ Task completed: $TASK_SUBJECT"
    ;;

  *)
    # Unknown event, skip notification
    exit 0
    ;;
esac

# Properly escape message for JSON using jq
MESSAGE_ESCAPED=$(printf '%s' "$MESSAGE" | jq -Rs . | sed 's/^"//; s/"$//')

# Call the actual Slack notification script
~/.claude/hooks/notify-slack.sh "$MESSAGE_ESCAPED"
exit 0
