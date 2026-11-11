#!/bin/sh
# Fails if the flow-promises skill reaches outside its own folder.
set -u
skill=$(cd "$(dirname "$0")/../flow-promises" && pwd)
fail=0
# 1. Every relative markdown link resolves inside the skill.
for f in $(find "$skill" -name '*.md'); do
  dir=$(dirname "$f")
  grep -oE '\]\([^)#]+' "$f" | sed 's/^](//' | while read -r link; do
    case $link in http*|mailto:*) continue ;; esac
    target=$(cd "$dir" 2>/dev/null && realpath -q "$link" 2>/dev/null) || target=
    case $target in
      "$skill"/*) [ -e "$target" ] || { echo "BROKEN: $f -> $link"; echo x >>"$skill/../.fail"; } ;;
      *) echo "ESCAPES: $f -> $link"; echo x >>"$skill/../.fail" ;;
    esac
  done
done
[ -f "$skill/../.fail" ] && { fail=1; rm -f "$skill/../.fail"; }
# 2. No paths or names from the pstack tree (comments in LICENSE/PROVENANCE excepted).
hits=$(grep -rnE '\.\./\.\./|docs/harness|principle-|pstack|create-formal-verification-skill\]\(\.\.' "$skill" \
  --exclude=LICENSE --exclude=PROVENANCE.md 2>/dev/null | grep -v "https://github.com/bkase/plugins/")
[ -z "$hits" ] || { echo "PSTACK REFS:"; echo "$hits"; fail=1; }
# 3. Script paths the code uses at run time exist.
[ -x "$skill/statechart/scripts/statechart" ] || { echo "MISSING statechart runner"; fail=1; }
grep -q '"\$here/../statechart/scripts"' "$skill/scripts/check" || { echo "check: wrong statechart path"; fail=1; }
grep -q '"../statechart/references/render.md"' "$skill/scripts/render.mjs" || { echo "render.mjs: wrong render.md path"; fail=1; }
# 4. Exactly one SKILL.md.
n=$(find "$skill" -name SKILL.md | wc -l | tr -d ' ')
[ "$n" = 1 ] || { echo "Expected 1 SKILL.md, found $n"; fail=1; }
[ $fail = 0 ] && echo "standalone: OK"
exit $fail
