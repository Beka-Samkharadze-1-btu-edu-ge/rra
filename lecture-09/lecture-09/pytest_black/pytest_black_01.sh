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
REPOSITORY_BRANCH_CODE="main"
REPOSITORY_PATH="REPO"

rm -rf $REPOSITORY_PATH || true
git clone git@github.com:${REPOSITORY_OWNER}/${REPOSITORY_NAME_CODE}.git $REPOSITORY_PATH

pushd $REPOSITORY_PATH

git switch $REPOSITORY_BRANCH_CODE

pytest --verbose --html=../pytest.html --self-contained-html || true
black --check --diff *.py | pygmentize -l diff -f html -O full,style=solarized-light -o ../black.html || true

popd

rm -rf $REPOSITORY_PATH || true
