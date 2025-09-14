#!/bin/bash

# ============================================================================
# Neovim Configuration Health Check Script
# ============================================================================

echo "======================================"
echo "  Neovim Configuration Health Check   "
echo "======================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Neovim version
echo "1. Checking Neovim version..."
nvim_version=$(nvim --version | head -n 1)
echo "   $nvim_version"
if nvim --version | grep -q "NVIM v0.[89]" || nvim --version | grep -q "NVIM v[1-9]"; then
    echo -e "   ${GREEN}✓ Version is up to date${NC}"
else
    echo -e "   ${YELLOW}⚠ Consider updating Neovim${NC}"
fi
echo

# Check required tools
echo "2. Checking required tools..."
tools=("git" "clang-format" "g++" "make")
for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
        echo -e "   ${GREEN}✓ $tool is installed${NC}"
    else
        echo -e "   ${RED}✗ $tool is not installed${NC}"
    fi
done
echo

# Check plugin installation
echo "3. Checking plugin installation..."
if [ -d "$HOME/.local/share/nvim/lazy" ]; then
    plugin_count=$(ls -1 "$HOME/.local/share/nvim/lazy" | wc -l)
    echo -e "   ${GREEN}✓ Lazy.nvim installed with $plugin_count plugins${NC}"
else
    echo -e "   ${RED}✗ Lazy.nvim not found${NC}"
fi
echo

# Check configuration files
echo "4. Checking configuration files..."
config_dir="$HOME/.config/nvim"
required_files=(
    "init.lua"
    "lua/core/options.lua"
    "lua/core/keymaps.lua"
    "lua/core/autocmds.lua"
    "lua/core/colors.lua"
    "lua/core/utils.lua"
    "lua/plugins/init.lua"
    ".clang-format"
)

for file in "${required_files[@]}"; do
    if [ -f "$config_dir/$file" ]; then
        echo -e "   ${GREEN}✓ $file exists${NC}"
    else
        echo -e "   ${RED}✗ $file missing${NC}"
    fi
done
echo

# Check snippets
echo "5. Checking C++ snippets..."
if [ -f "$config_dir/snippets/cpp.json" ] && [ -f "$config_dir/snippets/package.json" ]; then
    snippet_count=$(grep -c '"prefix"' "$config_dir/snippets/cpp.json" 2>/dev/null || echo "0")
    echo -e "   ${GREEN}✓ C++ snippets configured ($snippet_count snippets)${NC}"
else
    echo -e "   ${YELLOW}⚠ C++ snippets not fully configured${NC}"
fi
echo

# Performance test
echo "6. Running performance test..."
echo "   Testing startup time..."
startup_time=$(nvim --headless +quit 2>&1 | grep -o '[0-9.]*ms' | head -1)
if [ -n "$startup_time" ]; then
    echo "   Startup time: $startup_time"
else
    # Alternative method
    start=$(date +%s%N)
    nvim --headless +quit 2>/dev/null
    end=$(date +%s%N)
    elapsed=$((($end - $start) / 1000000))
    echo "   Startup time: ${elapsed}ms"
fi
echo

# Check for errors in Neovim
echo "7. Checking for configuration errors..."
error_check=$(nvim --headless -c ':checkhealth' -c ':quit' 2>&1 | grep -i "error" | head -5)
if [ -z "$error_check" ]; then
    echo -e "   ${GREEN}✓ No errors detected${NC}"
else
    echo -e "   ${YELLOW}⚠ Some issues detected (run :checkhealth in Neovim for details)${NC}"
fi
echo

# Memory usage check
echo "8. Checking memory usage..."
nvim_pid=$(pgrep nvim | head -1)
if [ -n "$nvim_pid" ]; then
    mem_usage=$(ps -o rss= -p $nvim_pid | awk '{print $1/1024 "MB"}')
    echo "   Current Neovim memory usage: $mem_usage"
else
    echo "   No running Neovim instance to measure"
fi
echo

# Summary
echo "======================================"
echo "           Summary Report             "
echo "======================================"
echo
echo "Configuration appears to be optimized for C++ development."
echo "Key features:"
echo "  • Lightweight configuration without LSP"
echo "  • Custom C++ formatting with .clang-format"
echo "  • Optimized completion and snippet support"
echo "  • Performance-focused plugin loading"
echo
echo "To test in Neovim, run:"
echo "  :checkhealth        - Full health check"
echo "  :Lazy               - Plugin manager"
echo "  :LuaSnipList        - List C++ snippets"
echo "  \\fi                 - Show format config"
echo
echo "======================================"