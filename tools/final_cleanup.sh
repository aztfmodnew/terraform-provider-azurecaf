#!/bin/bash

# Final Cleanup - Keep only essential files and recent reports/logs
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "🧹 Final cleanup of logs and reports..."

# Keep only the 2 most recent logs and reports
echo "📋 Keeping 2 most recent logs..."
ls -t enhanced_sync_log_*.log | tail -n +3 | xargs rm -f

echo "📊 Keeping 2 most recent reports..."  
ls -t enhanced_sync_report_*.md | tail -n +3 | xargs rm -f

# Remove the advanced cleanup script itself as it's no longer needed
rm -f advanced_cleanup.sh

echo ""
echo "✅ Final state of tools directory:"
echo "================================================"
for file in *.sh *.md; do
    [ -f "$file" ] && echo "  📄 $file"
done

echo ""
echo "📋 Recent logs/reports (kept):"
ls -t enhanced_sync_*{log,md} 2>/dev/null | head -4

echo ""
echo "🎉 Tools directory is now fully optimized!"
