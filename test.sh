#!/bin/bash
set -e
set -o pipefail

ERRORS=()

# find all executables and run `shellcheck`
for f in $(find . -type f -not -path '*.git*' -not -name "yubitouch.sh" | sort -u); do
  if file "$f" | grep --quiet shell; then {
      shellcheck "$f" && echo "[OK]: successfully linted $f"
    } || {
      # add to errors
      ERRORS+=("$f")
    }
  fi
done

if [ ${#ERRORS[@]} -eq 0 ]; then
  printf "No errors, hooray!\n"
else
  printf "These files failed shellcheck: %s\n" "${ERRORS[*]}"
  exit 1
fi
