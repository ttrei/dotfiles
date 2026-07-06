#!/usr/bin/env bash
set -euo pipefail

PRIMARY_OUTPUT="${PRIMARY_OUTPUT:-HDMI-A-2}"
SECONDARY_OUTPUT="${SECONDARY_OUTPUT:-HDMI-A-1}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: required command not found: $1" >&2
    exit 127
  }
}

outputs_json() {
  niri msg -j outputs
}

output_exists() {
  local name="$1" json="$2"
  jq -e --arg name "$name" 'has($name)' >/dev/null <<<"$json"
}

output_is_on() {
  local name="$1" json="$2"
  jq -e --arg name "$name" '.[$name].logical != null' >/dev/null <<<"$json"
}

need niri
need jq

json="$(outputs_json)"

for output in "$PRIMARY_OUTPUT" "$SECONDARY_OUTPUT"; do
  if ! output_exists "$output" "$json"; then
    echo "error: output not found in niri outputs: $output" >&2
    exit 1
  fi
done

if ! output_is_on "$PRIMARY_OUTPUT" "$json"; then
  echo "error: primary display is not on: $PRIMARY_OUTPUT" >&2
  exit 1
fi

if output_is_on "$SECONDARY_OUTPUT" "$json"; then
  echo "Turning off secondary display: $SECONDARY_OUTPUT"
  niri msg output "$SECONDARY_OUTPUT" off
else
  echo "Turning on secondary display: $SECONDARY_OUTPUT"
  niri msg output "$SECONDARY_OUTPUT" on
fi
