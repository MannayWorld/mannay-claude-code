#!/bin/bash
# Codex Review Queue Manager
# Manages background GPT code reviews via Codex CLI

QUEUE_DIR="${PROJECT_ROOT:-.}/.claude/gpt-reviews"
QUEUE_FILE="$QUEUE_DIR/queue.json"
USAGE_FILE="$QUEUE_DIR/usage.json"
CONFIG_FILE="${PROJECT_ROOT:-.}/.claude/settings.json"

# Ensure directories exist
mkdir -p "$QUEUE_DIR"

# Initialize queue file if not exists
init_queue() {
    if [ ! -f "$QUEUE_FILE" ]; then
        echo '{"reviews":[]}' > "$QUEUE_FILE"
    fi
    if [ ! -f "$USAGE_FILE" ]; then
        echo '{}' > "$USAGE_FILE"
    fi
}

# Get daily limit from config (default 10)
get_daily_limit() {
    if [ -f "$CONFIG_FILE" ]; then
        limit=$(cat "$CONFIG_FILE" 2>/dev/null | grep -o '"daily_limit"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*$')
        echo "${limit:-10}"
    else
        echo "10"
    fi
}

# Get today's usage count
get_today_usage() {
    init_queue
    today=$(date +%Y-%m-%d)
    if [ -f "$USAGE_FILE" ]; then
        count=$(cat "$USAGE_FILE" | grep -o "\"$today\"[[:space:]]*:[[:space:]]*{[^}]*\"count\"[[:space:]]*:[[:space:]]*[0-9]*" | grep -o '[0-9]*$')
        echo "${count:-0}"
    else
        echo "0"
    fi
}

# Increment usage for today
increment_usage() {
    init_queue
    today=$(date +%Y-%m-%d)
    current=$(get_today_usage)
    new_count=$((current + 1))

    # Simple update - just overwrite with today's count
    echo "{\"$today\":{\"count\":$new_count}}" > "$USAGE_FILE"
}

# Add review to queue
add_review() {
    local file="$1"
    local review_type="$2"
    local custom_prompt="$3"

    init_queue

    # Check daily limit
    usage=$(get_today_usage)
    limit=$(get_daily_limit)

    if [ "$usage" -ge "$limit" ]; then
        echo "ERROR: Daily limit reached ($usage/$limit)"
        echo "Wait until tomorrow or increase limit in .claude/settings.json"
        exit 1
    fi

    # Generate ID
    id=$(date +%s%N | sha256sum | head -c 8)
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Create review entry
    review_json=$(cat <<EOF
{
    "id": "$id",
    "file": "$file",
    "type": "$review_type",
    "custom_prompt": "$custom_prompt",
    "status": "pending",
    "queued_at": "$timestamp",
    "completed_at": null,
    "result_file": null
}
EOF
)

    # Add to queue (simple append approach)
    if [ -f "$QUEUE_FILE" ]; then
        # Read existing, add new review
        existing=$(cat "$QUEUE_FILE")
        if echo "$existing" | grep -q '"reviews":\[\]'; then
            # Empty array
            echo "{\"reviews\":[$review_json]}" > "$QUEUE_FILE"
        else
            # Has items - insert before closing bracket
            echo "$existing" | sed 's/\]}$/,'"$(echo "$review_json" | tr -d '\n')"']}/' > "$QUEUE_FILE"
        fi
    else
        echo "{\"reviews\":[$review_json]}" > "$QUEUE_FILE"
    fi

    increment_usage
    echo "$id"
}

# Get queue status
get_status() {
    init_queue

    if [ ! -f "$QUEUE_FILE" ]; then
        echo "No reviews queued"
        exit 0
    fi

    pending=$(grep -o '"status"[[:space:]]*:[[:space:]]*"pending"' "$QUEUE_FILE" | wc -l | tr -d ' ')
    completed=$(grep -o '"status"[[:space:]]*:[[:space:]]*"completed"' "$QUEUE_FILE" | wc -l | tr -d ' ')
    failed=$(grep -o '"status"[[:space:]]*:[[:space:]]*"failed"' "$QUEUE_FILE" | wc -l | tr -d ' ')

    usage=$(get_today_usage)
    limit=$(get_daily_limit)

    echo "=== Codex Review Queue ==="
    echo "Completed: $completed"
    echo "Pending: $pending"
    echo "Failed: $failed"
    echo ""
    echo "Today's usage: $usage/$limit reviews"
}

# Run a single review
run_review() {
    local id="$1"

    init_queue

    # Find review in queue
    review_line=$(grep -o "{[^}]*\"id\"[[:space:]]*:[[:space:]]*\"$id\"[^}]*}" "$QUEUE_FILE" | head -1)

    if [ -z "$review_line" ]; then
        echo "Review not found: $id"
        exit 1
    fi

    # Extract file and type
    file=$(echo "$review_line" | grep -o '"file"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
    review_type=$(echo "$review_line" | grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
    custom_prompt=$(echo "$review_line" | grep -o '"custom_prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')

    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        # Mark as failed
        sed -i '' "s/\"id\"[[:space:]]*:[[:space:]]*\"$id\"[^}]*\"status\"[[:space:]]*:[[:space:]]*\"pending\"/\"id\": \"$id\", \"status\": \"failed\"/" "$QUEUE_FILE" 2>/dev/null || true
        exit 1
    fi

    # Build prompt based on review type
    case "$review_type" in
        security)
            prompt="Review this code for security vulnerabilities. Focus on: input validation, auth issues, secrets exposure, injection vulnerabilities. Format: List issues with severity (HIGH/MEDIUM/LOW), line numbers, and fixes."
            ;;
        performance)
            prompt="Review this code for performance issues. Focus on: unnecessary computations, memory leaks, N+1 queries, missing caching. Format: List issues with impact and optimization suggestions."
            ;;
        refactor)
            prompt="Review this code for refactoring opportunities. Focus on: DRY violations, complex conditionals, unclear naming, missing abstractions. Format: List suggestions with before/after examples."
            ;;
        *)
            prompt="Review this code comprehensively for issues and improvements."
            ;;
    esac

    # Add custom prompt if provided
    if [ -n "$custom_prompt" ] && [ "$custom_prompt" != "null" ]; then
        prompt="$prompt Additional focus: $custom_prompt"
    fi

    # Read file content
    content=$(cat "$file")
    filename=$(basename "$file")

    # Run Codex
    full_prompt="$prompt

File: $filename
\`\`\`
$content
\`\`\`"

    result=$(codex "$full_prompt" 2>&1)

    if [ $? -eq 0 ]; then
        # Save result
        today=$(date +%Y-%m-%d)
        result_filename="${today}-$(basename "$file" | sed 's/\.[^.]*$//')-${review_type}.md"
        result_path="$QUEUE_DIR/$result_filename"

        cat > "$result_path" <<EOF
# Codex Review: $file

**Type:** $review_type
**Date:** $(date)

---

$result
EOF

        echo "Review complete: $result_path"
        echo "$result_path"
    else
        echo "Review failed: $result"
        exit 1
    fi
}

# Get results summary
get_results() {
    init_queue

    echo "=== Codex Review Results ==="
    echo ""

    # List all result files
    if [ -d "$QUEUE_DIR" ]; then
        for f in "$QUEUE_DIR"/*.md; do
            if [ -f "$f" ]; then
                filename=$(basename "$f")
                echo "- $filename"
                # Show first few lines as summary
                head -10 "$f" | tail -8
                echo ""
            fi
        done
    else
        echo "No results found"
    fi
}

# Main command handler
case "$1" in
    add)
        add_review "$2" "$3" "$4"
        ;;
    status)
        get_status
        ;;
    run)
        run_review "$2"
        ;;
    results)
        get_results
        ;;
    *)
        echo "Usage: queue.sh <command>"
        echo "Commands:"
        echo "  add <file> <type> [prompt]  - Add review to queue"
        echo "  status                       - Show queue status"
        echo "  run <id>                     - Run a specific review"
        echo "  results                      - Show all results"
        ;;
esac
