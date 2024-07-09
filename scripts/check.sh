#!/bin/bash
cd "$(dirname -- "$(dirname -- "$(readlink -f "$0")")")"

set -e

services=("shared" "manager" "orchestrator" "router" "shell")
skip_items=()

is_in_array() {
  local item="$1"
  shift
  local array=("$@")
  for element in "${array[@]}"; do
    if [[ "$element" == "$item" ]]; then
      return 0 # found
    fi
  done
  return 1 # not found
}

# Parse the arguments received and add it to a list of services to skip
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip)
      shift
      while [[ $# -gt 0 && $1 != --* ]]; do
        skip_items+=("$1")
        shift
      done
      ;;
    *)
      shift
      ;;
  esac
done

# Validate arguments
for item in "${skip_items[@]}"; do
  if ! is_in_array "$item" "${services[@]}"; then
    echo "'$item' is not a valid service to skip. Valid services:" "${services[@]}"
    exit 2
  fi
done

echo "Services to skip: " "${skip_items[@]}"

# Path is a bit different for the shared folder so it's easier to not for loop it
echo '=== shared ==='
! is_in_array "shared" "${skip_items[@]}" && (cd manager && pipenv run ../shared/scripts/check.sh) || echo "Skipped"

for dname in "${services[@]:1}"; do
    echo "=== $dname ==="
    ! is_in_array "$dname" "${skip_items[@]}" && (cd "$dname" && pipenv run ./scripts/check.sh) || echo "Skipped"
done

