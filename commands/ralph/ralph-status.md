# Ralph Status - Check Progress

Display current Ralph mode status and progress.

## Check Ralph Active Status

```bash
if [ "$RALPH_ACTIVE" = "true" ]; then
  echo "✅ Ralph mode: ACTIVE"
  echo "🔄 Current iteration: $RALPH_ITERATION / $RALPH_MAX_ITERATIONS"
else
  echo "❌ Ralph mode: INACTIVE"
fi
```

## PRD Status

Read and display story completion:

```bash
if [ -f "scripts/ralph/prd.json" ]; then
  echo ""
  echo "📋 PRD Status:"
  echo "─────────────────────────────────────────"

  # Total stories
  TOTAL=$(jq '.userStories | length' scripts/ralph/prd.json)

  # Completed stories
  COMPLETED=$(jq '[.userStories[] | select(.passes == true)] | length' scripts/ralph/prd.json)

  # Blocked stories
  BLOCKED=$(jq '[.userStories[] | select(.blocked == true)] | length' scripts/ralph/prd.json)

  # Remaining stories
  REMAINING=$((TOTAL - COMPLETED))

  echo "Total stories: $TOTAL"
  echo "Completed: $COMPLETED"
  echo "Remaining: $REMAINING"
  echo "Blocked: $BLOCKED"
  echo ""

  # Show story details
  echo "Story Details:"
  jq -r '.userStories[] | "[\(.id)] \(.title) - \(if .passes then "✅ DONE" elif .blocked then "⛔ BLOCKED" else "⏳ PENDING" end)"' scripts/ralph/prd.json
else
  echo "❌ No PRD found at scripts/ralph/prd.json"
fi
```

## Recent Progress

Show recent progress entries:

```bash
if [ -f "scripts/ralph/progress.txt" ]; then
  echo ""
  echo "📝 Recent Progress:"
  echo "─────────────────────────────────────────"
  tail -30 scripts/ralph/progress.txt
else
  echo "❌ No progress log found"
fi
```

## Recent Commits

Show Ralph commits:

```bash
echo ""
echo "🔖 Recent Ralph Commits:"
echo "─────────────────────────────────────────"
git log --oneline --grep="feat(ralph):" -10 2>/dev/null || echo "No Ralph commits yet"
```

## Summary

Provide actionable summary:

```bash
echo ""
echo "═══════════════════════════════════════════"
if [ "$RALPH_ACTIVE" = "true" ]; then
  echo "💡 Ralph is actively working on stories"
  echo "   Use /ralph-stop to pause the loop"
else
  echo "💡 Ralph is not running"
  echo "   Use /ralph-start to begin execution"
fi
echo "═══════════════════════════════════════════"
```
