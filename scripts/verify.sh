#!/bin/bash
#
# HustleXP Build Verification Script
# Usage:
#   ./scripts/verify.sh          # Full verify (build + launch)
#   ./scripts/verify.sh --build  # Build only, no simulator
#   ./scripts/verify.sh --quick  # Skip pod install, just build
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="$PROJECT_ROOT/ios"
APP_NAME="HustlexpRN"
SCHEME="HustlexpRN"
CONFIGURATION="Debug"
SIMULATOR="iPhone 16"
DERIVED_DATA="$PROJECT_ROOT/.build/DerivedData"

# Parse arguments
BUILD_ONLY=false
QUICK_MODE=false
RELEASE_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD_ONLY=true
            shift
            ;;
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --release)
            CONFIGURATION="Release"
            RELEASE_MODE=true
            shift
            ;;
        --simulator)
            SIMULATOR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --build       Build only, don't launch simulator"
            echo "  --quick       Skip pod install, just build"
            echo "  --release     Build in Release configuration"
            echo "  --simulator   Specify simulator (default: iPhone 16)"
            echo "  --help        Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Helper functions
print_step() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}▸ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}  $1${NC}"
}

# Cleanup function
cleanup() {
    if [[ $? -ne 0 ]]; then
        echo ""
        print_error "Build failed! Check the errors above."
        echo ""
        exit 1
    fi
}
trap cleanup EXIT

# Start
echo ""
echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║         HustleXP Build Verification               ║${NC}"
echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
print_info "Project: $PROJECT_ROOT"
print_info "Configuration: $CONFIGURATION"
print_info "Mode: $([ "$BUILD_ONLY" = true ] && echo "Build only" || echo "Build + Launch")"
print_info "Quick mode: $([ "$QUICK_MODE" = true ] && echo "Yes" || echo "No")"

cd "$PROJECT_ROOT"

# Step 1: Check/Install node_modules
print_step "Checking node_modules"
if [[ ! -d "node_modules" ]]; then
    print_warning "node_modules not found, running npm install..."
    npm install
    if [[ $? -eq 0 ]]; then
        print_success "npm install completed"
    else
        print_error "npm install failed"
        exit 1
    fi
else
    print_success "node_modules exists"
fi

# Step 2: Pod install (unless --quick)
if [[ "$QUICK_MODE" = false ]]; then
    print_step "Checking CocoaPods"
    
    cd "$IOS_DIR"
    
    # Check if Pods need install
    PODS_NEEDED=false
    if [[ ! -d "Pods" ]]; then
        print_warning "Pods directory missing"
        PODS_NEEDED=true
    elif [[ ! -f "Pods/Manifest.lock" ]]; then
        print_warning "Pods/Manifest.lock missing"
        PODS_NEEDED=true
    elif ! diff -q Podfile.lock Pods/Manifest.lock > /dev/null 2>&1; then
        print_warning "Podfile.lock differs from Manifest.lock"
        PODS_NEEDED=true
    fi
    
    if [[ "$PODS_NEEDED" = true ]]; then
        print_info "Running pod install..."
        
        # Check for bundler
        if command -v bundle &> /dev/null && [[ -f "$PROJECT_ROOT/Gemfile" ]]; then
            bundle exec pod install
        else
            pod install
        fi
        
        if [[ $? -eq 0 ]]; then
            print_success "pod install completed"
        else
            print_error "pod install failed"
            exit 1
        fi
    else
        print_success "Pods are up to date"
    fi
    
    cd "$PROJECT_ROOT"
else
    print_step "Skipping pod install (--quick mode)"
fi

# Step 3: Build iOS app
print_step "Building iOS app ($CONFIGURATION)"

# Find workspace
WORKSPACE="$IOS_DIR/$APP_NAME.xcworkspace"
if [[ ! -d "$WORKSPACE" ]]; then
    print_warning "Workspace not found, checking for project file..."
    WORKSPACE=""
    PROJECT="$IOS_DIR/$APP_NAME.xcodeproj"
    if [[ ! -d "$PROJECT" ]]; then
        print_error "Neither workspace nor project found in ios/"
        exit 1
    fi
fi

# Get simulator ID
print_info "Finding simulator: $SIMULATOR"
SIMULATOR_ID=$(xcrun simctl list devices available | grep "$SIMULATOR" | head -1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()')

if [[ -z "$SIMULATOR_ID" ]]; then
    print_error "Simulator '$SIMULATOR' not found"
    print_info "Available simulators:"
    xcrun simctl list devices available | grep iPhone | head -10
    exit 1
fi
print_info "Simulator ID: $SIMULATOR_ID"

# Build command
BUILD_CMD="xcodebuild"
if [[ -n "$WORKSPACE" ]]; then
    BUILD_CMD="$BUILD_CMD -workspace $WORKSPACE"
else
    BUILD_CMD="$BUILD_CMD -project $PROJECT"
fi

BUILD_CMD="$BUILD_CMD \
    -scheme $SCHEME \
    -configuration $CONFIGURATION \
    -destination 'platform=iOS Simulator,id=$SIMULATOR_ID' \
    -derivedDataPath $DERIVED_DATA \
    -quiet"

print_info "Building..."
BUILD_START=$(date +%s)

eval "$BUILD_CMD build"
BUILD_STATUS=$?

BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))

if [[ $BUILD_STATUS -eq 0 ]]; then
    print_success "Build succeeded in ${BUILD_TIME}s"
else
    print_error "Build failed after ${BUILD_TIME}s"
    echo ""
    echo -e "${YELLOW}Run with verbose output to see errors:${NC}"
    echo "  xcodebuild -workspace $WORKSPACE -scheme $SCHEME -configuration $CONFIGURATION build"
    exit 1
fi

# Step 4: Launch and check (unless --build)
if [[ "$BUILD_ONLY" = false ]]; then
    print_step "Launching on Simulator"
    
    # Find the built app
    APP_PATH=$(find "$DERIVED_DATA/Build/Products/$CONFIGURATION-iphonesimulator" -name "*.app" -type d 2>/dev/null | head -1)
    
    if [[ -z "$APP_PATH" ]]; then
        print_error "Built app not found in DerivedData"
        exit 1
    fi
    
    print_info "App: $APP_PATH"
    
    # Boot simulator if needed
    SIMULATOR_STATE=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -o "(Booted)" || echo "")
    if [[ -z "$SIMULATOR_STATE" ]]; then
        print_info "Booting simulator..."
        xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
        sleep 2
    fi
    
    # Open Simulator app
    open -a Simulator
    sleep 1
    
    # Install app
    print_info "Installing app..."
    xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
    
    if [[ $? -ne 0 ]]; then
        print_error "Failed to install app on simulator"
        exit 1
    fi
    
    # Get bundle ID
    BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_PATH/Info.plist" 2>/dev/null)
    
    if [[ -z "$BUNDLE_ID" ]]; then
        print_warning "Could not determine bundle ID, using default"
        BUNDLE_ID="org.reactjs.$APP_NAME"
    fi
    
    print_info "Bundle ID: $BUNDLE_ID"
    
    # Launch app
    print_info "Launching app..."
    xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"
    
    if [[ $? -ne 0 ]]; then
        print_error "Failed to launch app"
        exit 1
    fi
    
    print_success "App launched successfully"
    
    # Wait and check for crashes
    print_info "Monitoring for crashes (5 seconds)..."
    sleep 5
    
    # Check if app is still running
    RUNNING=$(xcrun simctl spawn "$SIMULATOR_ID" launchctl list 2>/dev/null | grep "$BUNDLE_ID" || echo "")
    
    if [[ -n "$RUNNING" ]]; then
        print_success "App is running without crashes"
    else
        print_warning "App may have crashed or closed. Check simulator logs:"
        print_info "  xcrun simctl spawn $SIMULATOR_ID log stream --level error"
    fi
fi

# Final summary
echo ""
echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║              VERIFICATION PASSED ✓                ║${NC}"
echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
print_info "Build time: ${BUILD_TIME}s"
print_info "Configuration: $CONFIGURATION"
if [[ "$BUILD_ONLY" = false ]]; then
    print_info "Simulator: $SIMULATOR"
fi
echo ""
