#!/bin/sh
# Regenerate patch/unified_diff.patch from upstream/<version>{,.patched}/.
# Usage: tools/mkpatch.sh [sailfish-version]
set -e
cd "$(dirname "$0")/.."
ver="${1:-5.2.0.17}"
target=usr/share/lipstick-jolla-home-qt5/switcher/SwitcherItem.qml

diff -u --label "a/$target" --label "b/$target" \
    "upstream/$ver/SwitcherItem.qml" "upstream/$ver.patched/SwitcherItem.qml" \
    > patch/unified_diff.patch || [ $? -eq 1 ]
echo "wrote patch/unified_diff.patch against $ver"
