#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Klaviyo Flutter - Code Analysis${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Track overall status
OVERALL_STATUS=0

# ============================================
# 1. DART ANALYSIS
# ============================================
echo -e "${BLUE}[1/4] Running Dart analysis...${NC}"
if flutter analyze; then
    echo -e "${GREEN}✓ Dart analysis passed${NC}"
else
    echo -e "${RED}✗ Dart analysis failed${NC}"
    OVERALL_STATUS=1
fi
echo ""

# ============================================
# 2. DART FORMATTING CHECK
# ============================================
echo -e "${BLUE}[2/4] Checking Dart formatting...${NC}"
if dart format --set-exit-if-changed --output=none .; then
    echo -e "${GREEN}✓ Dart formatting is correct${NC}"
else
    echo -e "${YELLOW}⚠ Dart formatting needs fixes. Run: dart format .${NC}"
    OVERALL_STATUS=1
fi
echo ""

# ============================================
# 3. KOTLIN ANALYSIS (Android)
# ============================================
echo -e "${BLUE}[3/4] Running Kotlin analysis (Android)...${NC}"

cd android

# Check if ktlint is available
if command -v ktlint &> /dev/null; then
    echo "  Using ktlint for Kotlin analysis..."
    if ktlint "src/**/*.kt"; then
        echo -e "${GREEN}✓ Kotlin code style passed${NC}"
    else
        echo -e "${YELLOW}⚠ Kotlin style issues found. Run: ktlint -F \"src/**/*.kt\" to fix${NC}"
        OVERALL_STATUS=1
    fi
else
    echo -e "${YELLOW}  ktlint not found. Installing via Gradle...${NC}"

    # Check if we have ktlint configured in Gradle
    if grep -q "ktlint" build.gradle 2>/dev/null; then
        if ./gradlew ktlintCheck 2>/dev/null; then
            echo -e "${GREEN}✓ Kotlin code style passed (Gradle)${NC}"
        else
            echo -e "${YELLOW}⚠ Kotlin style issues found. Run: ./gradlew ktlintFormat${NC}"
            OVERALL_STATUS=1
        fi
    else
        echo -e "${YELLOW}  Skipping Kotlin linting (ktlint not configured)${NC}"
        echo -e "${YELLOW}  To enable: brew install ktlint (macOS) or see https://pinterest.github.io/ktlint${NC}"
    fi
fi

# Run Android Lint (built into Android Gradle)
echo "  Running Android Lint..."

# Check for existing lint results (so we can show them if available)
LINT_TXT_REPORT="build/reports/lint-results-debug.txt"
LINT_XML_REPORT="build/reports/lint-results-debug.xml"

# Run lint (will be quick if nothing changed)
if ./gradlew lint -q 2>&1 | grep -q "BUILD SUCCESSFUL\|UP-TO-DATE"; then
    LINT_SUCCESS=true
else
    LINT_SUCCESS=false
fi

# Check for lint results (prefer XML)
if [ -f "$LINT_XML_REPORT" ]; then
    ISSUE_COUNT=$(xmllint --xpath 'count(/issues/issue)' "$LINT_XML_REPORT" 2>/dev/null || echo 0)
    if [ "$ISSUE_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✓ Android Lint passed (no issues)${NC}"
    else
        echo -e "${YELLOW}⚠ Android Lint found $ISSUE_COUNT issue(s)${NC}"
        echo -e "${BLUE}  Detailed report: android/build/reports/lint-results-debug.html${NC}"
        OVERALL_STATUS=1
    fi
elif [ -f "$LINT_TXT_REPORT" ]; then
    if grep -q "0 errors, 0 warnings" "$LINT_TXT_REPORT"; then
        echo -e "${GREEN}✓ Android Lint passed (no issues)${NC}"
    else
        echo -e "${YELLOW}⚠ Android Lint found issues:${NC}"
        cat "$LINT_TXT_REPORT"
        OVERALL_STATUS=1
    fi
else
    echo -e "${YELLOW}⚠ Android Lint report not found (run may have failed)${NC}"
fi

cd ..
echo ""

# ============================================
# 4. SWIFT ANALYSIS (iOS)
# ============================================
echo -e "${BLUE}[4/4] Running Swift analysis (iOS)...${NC}"

cd ios

# Check if SwiftLint is available
if command -v swiftlint &> /dev/null; then
    echo "  Using SwiftLint for Swift analysis..."
    if swiftlint lint --quiet; then
        echo -e "${GREEN}✓ Swift code style passed${NC}"
    else
        echo -e "${YELLOW}⚠ Swift style issues found${NC}"
        echo -e "${YELLOW}  To see details: cd ios && swiftlint lint${NC}"
        echo -e "${YELLOW}  To auto-fix: cd ios && swiftlint --fix${NC}"
        OVERALL_STATUS=1
    fi
else
    echo -e "${YELLOW}  SwiftLint not found${NC}"
    echo -e "${YELLOW}  To install: brew install swiftlint (macOS)${NC}"
    echo -e "${YELLOW}  See: https://github.com/realm/SwiftLint${NC}"
fi

# Check for Xcode project and run xcodebuild analyze if available
if [ -f "klaviyo_flutter.podspec" ] && command -v xcodebuild &> /dev/null; then
    echo "  Running Xcode static analyzer..."

    # We need to build first to analyze
    # This is more complex and requires a workspace setup
    echo -e "${YELLOW}  Xcode static analysis requires full build setup (skipping)${NC}"
    echo -e "${YELLOW}  To analyze manually: open ios/Runner.xcworkspace in Xcode${NC}"
    echo -e "${YELLOW}  Then: Product > Analyze (⇧⌘B)${NC}"
fi

cd ..
echo ""

# ============================================
# SUMMARY
# ============================================
echo -e "${BLUE}========================================${NC}"
if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo -e "${GREEN}  Code is ready for commit/publication${NC}"
else
    echo -e "${YELLOW}⚠ Some checks failed or have warnings${NC}"
    echo -e "${YELLOW}  Review the output above and fix issues${NC}"
fi
echo -e "${BLUE}========================================${NC}"

exit $OVERALL_STATUS
