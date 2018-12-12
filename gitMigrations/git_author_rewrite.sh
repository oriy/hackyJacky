#!/bin/sh

git filter-branch --env-filter '

OLD_EMAIL="'$1'"
CORRECT_NAME="'$2' '$3'"
CORRECT_EMAIL="'$4'"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --force --tag-name-filter cat -- --branches --tags
