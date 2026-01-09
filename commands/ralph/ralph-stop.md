# Ralph Stop - Pause Autonomous Loop

Stop the Ralph autonomous loop after the current iteration completes.

## Deactivate Ralph Mode

```bash
export RALPH_ACTIVE=false

echo "🛑 Ralph mode deactivated"
echo ""
echo "The loop will stop after the current iteration completes."
echo "Any work in progress will be preserved."
echo ""
echo "To resume: /ralph-start"
```

## Current Status

Show what was completed:

```bash
if [ -f "scripts/ralph/prd.json" ]; then
  echo "📊 Progress at stop:"

  COMPLETED=$(jq '[.userStories[] | select(.passes == true)] | length' scripts/ralph/prd.json)
  TOTAL=$(jq '.userStories | length' scripts/ralph/prd.json)

  echo "Completed: $COMPLETED / $TOTAL stories"
  echo ""
  echo "Completed stories:"
  jq -r '.userStories[] | select(.passes == true) | "  ✅ [\(.id)] \(.title)"' scripts/ralph/prd.json

  echo ""
  echo "Remaining stories:"
  jq -r '.userStories[] | select(.passes == false and .blocked == false) | "  ⏳ [\(.id)] \(.title)"' scripts/ralph/prd.json

  BLOCKED=$(jq '[.userStories[] | select(.blocked == true)] | length' scripts/ralph/prd.json)
  if [ "$BLOCKED" -gt 0 ]; then
    echo ""
    echo "Blocked stories (need human review):"
    jq -r '.userStories[] | select(.blocked == true) | "  ⛔ [\(.id)] \(.title) - \(.blockedReason)"' scripts/ralph/prd.json
  fi
fi
```

## Next Steps

```bash
echo ""
echo "═══════════════════════════════════════════"
echo "Next steps:"
echo "1. Review scripts/ralph/progress.txt for learnings"
echo "2. Check git log for commits made"
echo "3. Review any blocked stories in prd.json"
echo "4. Use /ralph-start to resume when ready"
echo "═══════════════════════════════════════════"
```
