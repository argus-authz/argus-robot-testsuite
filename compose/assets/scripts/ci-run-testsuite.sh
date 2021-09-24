#!/bin/bash
set -ex

sh /scripts/setup-testsuite.sh
cd /home/test/argus-testsuite
REPORTS_DIR="/tmp/reports" ./run-testsuite.sh "$@"
