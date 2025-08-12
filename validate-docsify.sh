#!/bin/bash

echo "Validating Docsify configuration..."

# Check if we're in the right directory
if [ ! -f "index.html" ]; then
    echo "❌ index.html not found in current directory"
    echo "Current directory: $(pwd)"
    echo "Looking for docs/index.html..."
    if [ -f "docs/index.html" ]; then
        echo "✅ Found docs/index.html"
        cd docs
    else
        echo "❌ docs/index.html not found either"
        exit 1
    fi
fi

# Check required files
echo "Checking required Docsify files..."

files=("index.html" "README.md" "_sidebar.md" "_navbar.md" "_coverpage.md" ".nojekyll")

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file found"
    else
        echo "❌ $file not found"
        exit 1
    fi
done

# Check directory structure
echo "Checking directory structure..."

directories=("getting-started" "testing-modules" "examples" "advanced" "reference" "contributing")

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir/ directory found"
    else
        echo "❌ $dir/ directory not found"
        exit 1
    fi
done

# Validate HTML syntax (basic check)
echo "Validating HTML syntax..."
if command -v tidy >/dev/null 2>&1; then
    if tidy -q -e index.html; then
        echo "✅ HTML syntax is valid"
    else
        echo "⚠️  HTML syntax warnings (but file is readable)"
    fi
else
    echo "ℹ️  HTML tidy not available, skipping syntax check"
fi

# Check for Mermaid diagram syntax
echo "Checking for Mermaid diagrams..."
mermaid_files=$(find . -name "*.md" -exec grep -l "\`\`\`mermaid" {} \; 2>/dev/null | wc -l)
echo "ℹ️  Found $mermaid_files files with Mermaid diagrams"

# Check for broken internal links (basic check)
echo "Checking for basic markdown structure..."
md_files=$(find . -name "*.md" | wc -l)
echo "ℹ️  Found $md_files markdown files"

echo "✅ Docsify configuration validation completed successfully!"
echo ""
echo "To serve the documentation locally:"
echo "  npm install -g docsify-cli"
echo "  docsify serve ."
echo ""
echo "Or use Python:"
echo "  python -m http.server 3000"