# PRD Builder Verification Checklist

## Core Components

### Skill Structure
- [ ] `skills/prd-builder/SKILL.md` exists
- [ ] Frontmatter correct (name, description, category, invocation)
- [ ] 6-phase workflow documented
- [ ] Story decomposition section complete
- [ ] PRD generation section complete
- [ ] Quality validation section complete
- [ ] Examples provided
- [ ] Integration with existing skills documented

### Templates
- [ ] `skills/prd-builder/templates/prd-schema.json` exists
- [ ] JSON schema valid
- [ ] All required fields defined
- [ ] Story template exists
- [ ] Acceptance criteria format documented

### Library Documentation
- [ ] `skills/prd-builder/lib/story-decomposer.md` exists
- [ ] 10 ISPI decomposition techniques documented
- [ ] Story atomicity checklist provided
- [ ] `skills/prd-builder/lib/prd-generator.md` exists
- [ ] Ralph JSON format specification complete
- [ ] `skills/prd-builder/lib/validator.md` exists
- [ ] Validation checks documented

## Commands

### Ralph Build Command
- [ ] `commands/ralph/ralph-build.md` exists
- [ ] Frontmatter correct
- [ ] Usage examples provided
- [ ] Integration documented

## Plugin Registration

### Manifest
- [ ] `.claude-plugin/plugin.json` updated
- [ ] Version incremented to 1.4.0
- [ ] `prd-builder` skill registered
- [ ] `ralph-build` command registered
- [ ] JSON valid

### Documentation
- [ ] `README.md` includes PRD Builder section
- [ ] `CHEATSHEET.md` includes ralph-build command
- [ ] `WORKFLOWS.md` includes Workflow 8 (PRD Creation)
- [ ] `README-FOR-DUMMIES.md` mentions PRD Builder

## Tests

### Unit Tests
- [ ] `tests/prd-builder/skill-structure.test.sh` exists and passes
- [ ] `tests/prd-builder/story-decomposition.test.sh` exists and passes
- [ ] `tests/prd-builder/prd-generation.test.sh` exists and passes
- [ ] `tests/prd-builder/validation.test.sh` exists and passes
- [ ] `tests/prd-builder/command.test.sh` exists and passes
- [ ] `tests/prd-builder/registration.test.sh` exists and passes

### Integration Tests
- [ ] `tests/prd-builder/integration.test.sh` exists and passes
- [ ] All 5 integration tests pass

### Test Fixtures
- [ ] Test fixtures in `tests/prd-builder/fixtures/` exist
- [ ] Sample feature spec provided

## Quality Standards

### Story Granularity
- [ ] Documentation specifies 2-5 minute tasks
- [ ] Acceptance criteria: 3-7 bullets guideline
- [ ] Test coverage: ≥85% requirement
- [ ] Story atomicity checklist provided

### PRD Quality
- [ ] JSON schema validation implemented
- [ ] Completion promise exact match: `<promise>COMPLETE</promise>`
- [ ] Dependency validation (no circular deps)
- [ ] Story count recommendations (3-20 ideal)

### Research Foundation
- [ ] Based on Anthropic's ralph-wiggum plugin
- [ ] Incorporates ISPI atomic user stories framework
- [ ] Follows GitHub Copilon agent guidance
- [ ] Implements LIDR Academy standards
- [ ] Includes ChatPRD best practices

## Git

### Commits
- [ ] Task 1: Skill structure committed
- [ ] Task 2: Story decomposer committed
- [ ] Task 3: PRD generator committed
- [ ] Task 4: Validator committed
- [ ] Task 5: Command committed
- [ ] Task 6: Registration committed
- [ ] Task 7: Tests committed
- [ ] All commits follow format: `feat: <description>`

### Branch
- [ ] Working on correct branch
- [ ] No uncommitted changes
- [ ] All tests passing before final commit

## Functionality

### End-to-End Flow
- [ ] Can trigger with `/ralph-build <feature>`
- [ ] Phase 1 (Discovery) asks questions
- [ ] Phase 2 (Design) proposes options
- [ ] Phase 3 (Spec) creates technical details
- [ ] Phase 4 (Decomposition) breaks into atomic stories
- [ ] Phase 5 (Generation) outputs valid JSON
- [ ] Phase 6 (Validation) checks quality
- [ ] Output saved to `scripts/ralph/prd.json`
- [ ] Generated PRD works with `/ralph-start`

### Quality Validation
- [ ] JSON schema validation works
- [ ] Story atomicity checks work
- [ ] Dependency validation catches circular deps
- [ ] Completion promise validation works
- [ ] Story count warnings work (< 3 or > 20)

## Final Checks

- [ ] All tests passing
- [ ] Documentation complete and accurate
- [ ] Examples provided
- [ ] Integration with existing skills verified
- [ ] Ready for production use
