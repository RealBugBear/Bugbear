#!/usr/bin/env bash
set -euo pipefail

export FIREBASE_USE_GENERATED_OPTIONS=true

flutter run -d chrome \
  --dart-define=FIREBASE_USE_GENERATED_OPTIONS=$FIREBASE_USE_GENERATED_OPTIONS
