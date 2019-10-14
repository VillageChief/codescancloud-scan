#!/bin/bash

source "$(dirname "$0")/common.sh"

SCANNER_REPORT="${BITBUCKET_PIPE_STORAGE_DIR}/codescancloud-scan.log"

parse_environment_variables() {
  EXTRA_ARGS=${EXTRA_ARGS:=""}
  SONAR_TOKEN=${SONAR_TOKEN:?'SONAR_TOKEN variable missing.'}
  SONAR_ORGANIZATION=${SONAR_ORGANIZATION:?'SONAR_ORGANIZATION variable missing.'}
  BITBUCKET_CLONE_DIR=${BITBUCKET_CLONE_DIR:?'BITBUCKET_CLONE_DIR variable missing.'}
}

parse_environment_variables

IFS=$'\n' ALL_ARGS=( $(xargs -n1 <<<"${EXTRA_ARGS}") )

ALL_ARGS+=( "-Dsonar.host.url=https://app.codescan.io" )
ALL_ARGS+=( "-Dsonar.organization=${SONAR_ORGANIZATION}" )
ALL_ARGS+=( "-Dsonar.login=${SONAR_TOKEN}" )
ALL_ARGS+=( "-Dsonar.branch.name=${BITBUCKET_BRANCH}" )

if [[ "${BITBUCKET_PR_DESTINATION_BRANCH}" != "" ]]; then
	ALL_ARGS+=( "-Dsonar.branch.target=${BITBUCKET_PR_DESTINATION_BRANCH}" )
fi

if [[ "${DEBUG}" == "true" ]]; then
    ALL_ARGS+=( "-Dsonar.verbose=true" )
    debug "SONAR_SCANNER_OPTS: ${SONAR_SCANNER_OPTS}"
    debug "EXTRA_ARGS: ${EXTRA_ARGS}"
    debug "Final analysis parameters:\n${ALL_ARGS[@]}"
fi

(sonar-scanner "${ALL_ARGS[@]}" 2>&1 | tee "${SCANNER_REPORT}") || true

if grep -q "EXECUTION SUCCESS" "${SCANNER_REPORT}"
then
  success "CodeScanCloud analysis was successful."
else
  fail "CodeScanCloud analysis failed."
fi
