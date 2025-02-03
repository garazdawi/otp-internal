#!/bin/bash

set -x

SHA=$1
BRANCH=$2
OTP_VERSION=$3
BASE_BRANCH=${BRANCH//-opu/}
REPO="erlang/otp-internal"

PULLS=$(gh api "/repos/${REPO}/commits/${SHA}/pulls" \
            | jq -c '[ .[] | select(.base.repo.full_name | contains("'"${REPO}"'")) ]')

TITLE="${BRANCH} PR (${OTP_VERSION})"

if [ "$(echo "${PULLS}" | jq 'length')" = "0" ]; then
    ## Create PR
    gh pr create --repo "${REPO}" --base "${BASE_BRANCH}" --head "${BRANCH}" \
        --title "${TITLE}" --body "A PR tracking the progress of ${BRANCH}."
elif [ "$(echo "${PULLS}" | jq 'length')" = "1" ]; then
    ## Update PR
    NO=$(echo "${PULLS}" | jq '.[].number')
    gh pr edit "${NO}" --repo "${REPO}" --title "${TITLE}"
    true
else
    # Something strange, found two PRs for this commit?
    echo "Found two PRs for this commit, this is very strange?"
    exit 1
fi