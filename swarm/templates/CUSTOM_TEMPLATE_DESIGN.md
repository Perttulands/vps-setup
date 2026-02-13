# Custom Template Design Notes

## Problem Analysis

Based on 6 runs of "custom" template tasks:
- **Avg duration**: 705 seconds (~12 minutes)
- **Max duration**: 1642 seconds (~27 minutes)
- **Success rate**: 20% (from template-scores.json: 2/10 successful)

**Diagnosis**: Scope creep - tasks expanding beyond original intent without clear boundaries.

## Solution: Time-Boxed Template with Guardrails

### Key Features Added

1. **Time Budgets** (addresses duration outliers)
   - Target: ~10 minutes
   - Alert: 20 minutes → report progress
   - Hard stop: 30 minutes → decompose into sub-tasks

2. **Scope Constraints** (prevents runaway tasks)
   - 5 explicit scope management rules
   - "Focus on core objective" principle
   - "No gold-plating" directive
   - Mandatory decomposition for >30 min tasks

3. **Progress Checkpoints** (early warning system)
   - 10-minute self-assessment
   - 20-minute required status report
   - 30-minute forced decomposition

4. **Flexibility Maintained** (still general-purpose)
   - Uses `{{DESCRIPTION}}` variable for any task type
   - Fallback file discovery if FILES not specified
   - Adapts to any test framework
   - Standard MCP Agent Mail reporting

### Design Principles

- **Structure over discipline** - Don't rely on agent self-control, enforce boundaries
- **Signal early** - Surface problems before they become expensive
- **Incremental value** - Partial progress beats perfect solutions that timeout
- **Clear decomposition path** - If task is too large, provide structured breakdown format

### Expected Impact

- **Reduced avg duration**: Target 10 min (vs current 12 min avg)
- **Eliminated outliers**: Hard stop at 30 min (vs current 27 min max)
- **Improved success rate**: Better scoping should increase from 20% baseline
- **Better observability**: Mandatory checkpoints provide progress visibility

### Template Validation

Tested via `test-custom-template.sh`:
- ✓ Variable substitution works
- ✓ All required sections present (Time Budget, Scope Rules, Checkpoints, Decomposition)
- ✓ Time references correct (10/20/30 minutes)
- ✓ Scope keywords present (STOP, decompose, checkpoint, report)
- ✓ Standard template structure maintained
- ✓ 137 lines (concise, not verbose)

### Usage

```bash
# Render template with variables
PROMPT=$(cat templates/custom.md | \
  sed "s/{{BEAD_ID}}/bd-xyz/g" | \
  sed "s|{{REPO_PATH}}|/path/to/repo|g" | \
  sed "s/{{FILES}}/file1.py, file2.py/g" | \
  sed "s/{{DESCRIPTION}}/Your task description here/g")

# Dispatch
./scripts/dispatch.sh bd-xyz /path/to/repo claude "$PROMPT"

# Monitor duration
watch -n 5 'jq .duration_seconds state/runs/bd-xyz.json'
```

### Monitoring Success

Track these metrics after deployment:
1. **Duration distribution**: Should see tighter clustering around 10 min
2. **Checkpoint usage**: Count tasks that hit 20-min or 30-min thresholds
3. **Decomposition rate**: How often do tasks trigger "SCOPE EXCEEDED"
4. **Success rate**: Should improve from 20% baseline

Compare against historical custom template runs to validate effectiveness.

### Next Steps

1. ✅ Template created and validated
2. ⏳ Deploy in production orchestrator runs
3. ⏳ Collect duration data from next 10+ custom tasks
4. ⏳ Compare to baseline (705s avg, 1642s max)
5. ⏳ Adjust time budgets if needed based on real-world data
6. ⏳ Consider adding budget overrides for known-complex tasks

### Related Files

- `templates/custom.md` - The template itself
- `test-custom-template.sh` - Validation script
- `state/template-scores.json` - Historical performance data
- `templates/README.md` - Updated with custom template docs
