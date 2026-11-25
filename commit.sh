#!/usr/bin/env bash
set -e

# move the generated files to temporary directory
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/stats.XXXXXX")
mv -v generated "$tmp_dir/generated"

# switch to generated branch
git checkout generated

# set up git
git config user.name "GitHub Actions"
git config user.email "actions@github.com"

# clean up
# git rm -rf --ignore-unmatch *
rm -rf *
mv -v "$tmp_dir"/generated/* .

# commit
git add --all

# `git commit` exits non-zero when there is nothing to commit, which would
# fail the job under `set -e` on days the stats did not change.
if git diff --cached --quiet; then
  echo "No changes to generated files."
  exit 0
fi

if [ -z "$SCHEDULED_ACTION" ]; then
  git commit -m "Update generated files: $GITHUB_SHA"
else
  git commit -m "Update generated files (scheduled)"
fi

git push origin generated
