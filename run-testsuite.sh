
#!/bin/bash
#
# Copyright (c) Istituto Nazionale di Fisica Nucleare, 2018.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -ex

ROBOT_ARGS=${ROBOT_ARGS:-}
DEFAULT_EXCLUDES=${DEFAULT_EXCLUDES:-}
REPORTS_DIR=${REPORTS_DIR:-"reports"}
OUT_FILE=${OUT_FILE:-"output.xml"}
LOG_FILE=${LOG_FILE:-"log.html"}
REPORT_FILE=${REPORT_FILE:-"report.html"}
DEFAULT_ARGS="--pythonpath .:lib  -d ${REPORTS_DIR} -o ${OUT_FILE} -l ${LOG_FILE} -r ${REPORT_FILE}"

read -a ARGS <<< "${DEFAULT_ARGS} ${DEFAULT_EXCLUDES} ${ROBOT_ARGS}"
ARGS+=("$@")

robot "${ARGS[@]}" tests