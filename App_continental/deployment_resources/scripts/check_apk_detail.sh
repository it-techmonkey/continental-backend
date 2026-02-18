#!/bin/bash
APK_FILE="build/app/outputs/flutter-apk/app-release.apk"
TEMP_DIR="/tmp/apk_16kb_detail_check"

rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
unzip -qo "$APK_FILE" -d "$TEMP_DIR"

# Find local readelf or from NDK
READELF_TOOL=$(find ~/Library/Android/sdk/ndk -name "llvm-readelf" 2>/dev/null | head -n 1)
[ -z "$READELF_TOOL" ] && READELF_TOOL="readelf"

echo "Using readelf: $READELF_TOOL"

error_count=0
total_so=0

for arch in arm64-v8a armeabi-v7a x86 x86_64; do
    echo "--- Architecture: $arch ---"
    files=$(find "$TEMP_DIR/lib/$arch" -name "*.so" 2>/dev/null)
    if [ -z "$files" ]; then
        echo "No libraries found."
        continue
    fi
    
    total=0
    aligned=0
    for f in $files; do
        total=$((total + 1))
        total_so=$((total_so + 1))
        # Get alignment from the first LOAD header
        align=$($READELF_TOOL -l "$f" 2>/dev/null | grep "LOAD" | head -1 | awk '{print $NF}')
        
        # Check for 16KB (0x4000) or 64KB (0x10000)
        if [ "$align" == "0x4000" ] || [ "$align" == "0x10000" ]; then
            aligned=$((aligned + 1))
        else
            echo "❌ $(basename $f) is $align"
            error_count=$((error_count + 1))
        fi
    done
    echo "Summary for $arch: $aligned / $total aligned"
done

echo ""
echo "📊 Final Verdict:"
if [ $error_count -eq 0 ] && [ $total_so -gt 0 ]; then
    echo "✅ SUCCESS: All $total_so libraries are 16KB/64KB aligned!"
    rm -rf "$TEMP_DIR"
    exit 0
else
    echo "❌ FAILED: Found $error_count libraries with incorrect alignment."
    rm -rf "$TEMP_DIR"
    exit 1
fi
