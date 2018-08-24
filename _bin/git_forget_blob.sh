# https://ownyourbits.com/2017/01/18/completely-remove-a-file-from-a-git-repository-with-git-forget-blob/

function git-forget-blob()
{
  test -d .git || { echo "Need to be at base of a git repository" && return 1; }
  git repack -Aq
  ls .git/objects/pack/*.idx &>/dev/null || {
    echo "there is nothing to be forgotten in this repo" && return;
  }
  local BLOBS=( $( git verify-pack -v .git/objects/pack/*.idx | grep blob | awk '{ print $1 }' ) )
  for ref in ${BLOBS[@]}; do
    local FILE="$( git rev-list --objects --all | grep $ref | awk '{ print $2 }' )"
    [[ "$FILE" == "$1" ]] && break
    unset FILE
  done
  [[ "$FILE" == "" ]] && { echo "$1 not found in repo history" && return; }

  git tag | xargs git tag -d
  git branch -a | grep "remotes\/" | awk '{ print $1 }' | cut -f2 -d/ | while read r; do git remote rm $r 2>/dev/null; done
  git filter-branch --index-filter "git rm --cached --ignore-unmatch $FILE"
  rm -rf .git/refs/original/ .git/refs/remotes/ .git/*_HEAD .git/logs/
  (git for-each-ref --format="%(refname)" refs/original/ || echo :) | \
    xargs -n1 git update-ref -d
  git reflog expire --expire-unreachable=now --all
  git repack -q -A -d
  git gc --aggressive --prune=now
}
