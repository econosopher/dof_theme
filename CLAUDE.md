# DoF Theme Project Settings

This is the project-specific configuration for the dof_theme project, which overrides and extends the global settings.

## Hooks

### PR Submission Hook
Before submitting a pull request to GitHub, automatically:
1. Run all examples to ensure they work correctly
2. Update the README if there were significant changes

```bash
# Run all examples first
cd examples && Rscript run_all_examples.R
EXAMPLES_EXIT_CODE=$?

if [ $EXAMPLES_EXIT_CODE -ne 0 ]; then
    echo "Examples failed to run. Please fix errors before committing."
    exit 1
fi

# Check if there are significant changes (more than 10 lines modified)
CHANGES=$(git diff --stat origin/main...HEAD | tail -1 | grep -o '[0-9]\+ insertions\|[0-9]\+ deletions' | head -1 | grep -o '[0-9]\+')
if [ "$CHANGES" -gt 10 ]; then
    echo "Significant changes detected ($CHANGES lines). Updating README..."
    
    # Generate README update based on recent changes
    echo "## Recent Changes" >> README_UPDATE.tmp
    echo "" >> README_UPDATE.tmp
    git log --oneline origin/main...HEAD >> README_UPDATE.tmp
    echo "" >> README_UPDATE.tmp
    
    # If README exists, backup and update
    if [ -f "README.md" ]; then
        cp README.md README.md.bak
        # Add recent changes section if it doesn't exist
        if ! grep -q "## Recent Changes" README.md; then
            echo "" >> README.md
            cat README_UPDATE.tmp >> README.md
        fi
    fi
    
    # Stage README changes and any new example outputs
    git add README.md
    git add examples/output/*.png
    rm README_UPDATE.tmp
    
    echo "README updated with recent changes and examples verified."
fi
```

## Project-Specific Settings

- **Auto-run examples**: Enabled for all commits and PR submissions
- **Example outputs**: Automatically staged if updated
- **README updates**: Include recent changes when significant modifications are made
- **Error handling**: Blocks commits if examples fail to run

## Inherited Settings

All global settings from the parent CLAUDE.md apply unless overridden above, including:
- No emojis in R output
- No cat() statements in example scripts
- No Claude/Anthropic references in documentation
- Smart GT-table style formatting preferences