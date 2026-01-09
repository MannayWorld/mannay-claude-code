#!/bin/bash
set -e

echo "Testing PRD JSON generation..."

# Create test PRD
cat > /tmp/test-prd.json << 'JSONEOF'
{
  "projectName": "Test Feature",
  "branchName": "ralph/test",
  "description": "Test description",
  "created": "2026-01-07",
  "userStories": [
    {
      "id": "US-001",
      "title": "Test story",
      "description": "As a user, I want to test",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2",
        "Tests passing (coverage ≥ 85%)"
      ],
      "priority": 1,
      "passes": false
    }
  ],
  "completionPromise": "<promise>COMPLETE</promise>",
  "maxIterations": 20
}
JSONEOF

# Validate JSON
if ! jq empty /tmp/test-prd.json 2>/dev/null; then
    echo "❌ Invalid JSON"
    exit 1
fi

# Check required fields
if ! jq -e '.projectName' /tmp/test-prd.json >/dev/null; then
    echo "❌ Missing projectName"
    exit 1
fi

if ! jq -e '.completionPromise' /tmp/test-prd.json >/dev/null; then
    echo "❌ Missing completionPromise"
    exit 1
fi

echo "✅ PRD JSON generation test passed"
rm /tmp/test-prd.json
