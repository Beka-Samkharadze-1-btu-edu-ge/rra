#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${BASH_TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi

cd "$(dirname "$0")"

REPOSITORY_OWNER="btu-mit-08-2023"
REPOSITORY_NAME_CODE="l09"
REPOSITORY_NAME_REPORT="l09-ci"
REPOSITORY_BRANCH_CODE="main"
REPOSITORY_BRANCH_REPORT="main"
REPOSITORY_PATH_CODE=$(mktemp --directory)
REPOSITORY_PATH_REPORT=$(mktemp --directory)
PYTEST_REPORT_PATH=$(mktemp)
BLACK_REPORT_PATH=$(mktemp)
PYTEST_RESULT=0
BLACK_RESULT=0

git clone git@github.com:${REPOSITORY_OWNER}/${REPOSITORY_NAME_CODE}.git $REPOSITORY_PATH_CODE
pushd $REPOSITORY_PATH_CODE
git switch $REPOSITORY_BRANCH_CODE
COMMIT_HASH=$(git rev-parse HEAD)

if pytest --verbose --html=$PYTEST_REPORT_PATH --self-contained-html
then
    echo "PYTEST SUCCEEDED $?"
    PYTEST_RESULT=$?
else
    echo "PYTEST FAILED $?"
    PYTEST_RESULT=$?
fi

if black --check --diff *.py | pygmentize -l diff -f html -O full,style=solarized-light -o $BLACK_REPORT_PATH
then
    echo "BLACK SUCCEEDED $?"
    BLACK_RESULT=$?
else
    echo "BLACK FAILED $?"
    BLACK_RESULT=$?
fi

popd
git clone git@github.com:${REPOSITORY_OWNER}/${REPOSITORY_NAME_REPORT}.git $REPOSITORY_PATH_REPORT
pushd $REPOSITORY_PATH_REPORT
git switch $REPOSITORY_BRANCH_REPORT
mkdir --parents $COMMIT_HASH
mv $PYTEST_REPORT_PATH "$COMMIT_HASH/pytest.html"
mv $BLACK_REPORT_PATH "$COMMIT_HASH/black.html"
git add $COMMIT_HASH
git commit -m "$COMMIT_HASH report."
git push
popd
rm -rf $REPOSITORY_PATH_CODE
rm -rf $REPOSITORY_PATH_REPORT
rm -rf $PYTEST_REPORT_PATH
rm -rf $BLACK_REPORT_PATH
