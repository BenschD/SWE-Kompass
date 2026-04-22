#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"
MVN="${MVN_CMD:-mvn}"
"$MVN" -pl bearing-demo -am install -DskipTests
"$MVN" -f "$HERE/bearing-demo/pom.xml" exec:java
