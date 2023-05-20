#!/usr/bin/env bash
set -xefuo pipefail
git config --global 'init.defaultBranch' 'master'
# git config --global 'format.signoff' 'true'
# git config --global "user.signingkey" "$(gpg --list-signatures --with-colons | grep 'sig' | grep "$(git config --global 'user.email')" | head -n 1 | cut -d':' -f5)"
git config --global 'core.autocrlf' 'false'
# git config --global 'core.attributesfile' '.gitattributes'
git config --global 'push.recursesubmodules' 'on-demand'
git config --global 'pull.rebase' 'true'
git config --global 'rebase.autostash' 'true'
git config --global 'status.submodulesummary' 'true'
# git config --global 'commit.gpgsign' 'true'
git config --global 'interactive.difffilter' 'delta --color-only --features'
git config --global 'pager.diff' '([[ -x $(command -v delta) ]] && delta || less --tab=2 -RFX)'
git config --global 'pager.grep' '([[ -x $(command -v delta) ]] && delta || less -RFX)'
git config --global 'pager.blame' '([[ -x $(command -v delta) ]] && delta || less -RFX)'
git config --global 'pager.log' '([[ -x $(command -v delta) ]] && delta || less -RFX)'
git config --global 'pager.reflog' '([[ -x $(command -v delta) ]] && delta || less -RFX)'
git config --global 'pager.show' '([[ -x $(command -v delta) ]] && delta || less -RFX)'
git config --global 'diff.submodule' 'log'
git config --global 'diff.tool' 'difftastic'
git config --global 'diff.image.command' 'compare $2 $1 png:- | montage -geometry +4+4 $2 - $1 png:- | display -title "$1"'
git config --global 'diff.difftastic.command' 'difft'
git config --global 'diff.difftastic.binary' 'true'
git config --global 'difftool.prompt' 'false'
git config --global 'difftool.difftastic.cmd' 'difft $LOCAL $REMOTE'
git config --global 'difftool.delta.cmd' 'diff -u --unified=3 --ignore-case -w $LOCAL $REMOTE | delta'
git config --global 'delta.features' 'side-by-side line-numbers decorations'
git config --global 'delta.whitespace-error-style' '22 reverse'
git config --global 'delta.decorations.commit-decoration-style' 'bold yellow box ul'
git config --global 'delta.decorations.file-style' 'bold yellow ul'
git config --global 'delta.decorations.file-decoration-style' 'none'
git config --global 'delta.decorations.commit-style' 'raw'
git config --global 'delta.decorations.hunk-header-decoration-style' 'blue box'
git config --global 'delta.decorations.hunk-header-file-style' 'red'
git config --global 'delta.decorations.hunk-header-line-number-style' '#067a00'
git config --global 'delta.decorations.hunk-header-style' 'file line-number syntax'
git config --global 'delta.interactive.keep-plus-minus-markers' 'false'
git config --global 'gui.editor' 'code -w'
git config --global 'fetch.prune' 'true'
git config --global 'merge.log' 'true'
git config --global 'merge.tool' 'code'
git config --global 'mergetool.code.cmd' 'code --wait --merge $REMOTE $LOCAL $BASE $MERGED'
git config --global 'alias.view-contributors' 'shortlog -e -s -n'
git config --global 'alias.upstream' 'remote get-url origin'
git config --global 'alias.root' 'rev-parse --show-toplevel'
git config --global 'alias.scope' 'rev-parse --show-prefix'
git config --global 'alias.url' 'ls-remote --get-url'
git config --global 'alias.aliases' 'config --get-regexp alias'
git config --global 'alias.spush' 'push --recurse-submodules=on-demand'
git config --global 'alias.sfetch' 'submodule foreach --recursive git fetch'
git config --global 'alias.supdate' 'submodule update --remote --merge'
git config --global 'alias.default-branch' 'rev-parse --abbrev-ref HEAD'
git config --global 'alias.current-branch' '!git for-each-ref --format="%(upstream:short)" $(git symbolic-ref -q HEAD)'
git config --global 'alias.branch-prune' '!git fetch -p && for b in $(git for-each-ref --format="%(if:equals=[gone])%(upstream:track)%(then)%(refname:short)%(end)" refs/heads); do git branch -d $b; done'
git config --global 'alias.ca' 'commit --signoff --gpg-sign --amend --reuse-message=HEAD'
git config --global 'alias.c' 'commit --signoff --gpg-sign'
git config --global 'alias.commit-summary' 'log --color --graph --pretty=format:"%C(red)%h%C(reset) %s %C(bold blue)[%an](mailto:%ae)%C(reset) %C(green)%C(bold)%cr" --abbrev-commit'
git config --global 'alias.head-hash' 'rev-parse HEAD'
git config --global 'alias.latest-commit' 'log -1 HEAD --stat'
git config --global 'alias.untracked' 'ls-files --others --exclude-standard'
git config --global 'alias.tracked' '!git ls-tree -r $(git symbolic-ref --quiet --short HEAD || git rev-parse HEAD) --name-only'
git config --global 'alias.tags' 'for-each-ref --format="%(refname:short) (%(committerdate:relative))" --sort=committerdate refs/tags'
git config --global 'alias.latest-tag' '!git describe --tags $(git rev-list --tags --max-count=1 2>/dev/null) 2>/dev/null'
git config --global 'alias.release-notes' 'log --color --pretty=format:"* %C(red)%h%C(reset) %s %C(bold blue)[%an](mailto:%ae)%C(reset)" --abbrev-commit --dense --no-merges'
git config --global 'alias.staged' 'diff --name-only --staged'
git config --global 'alias.difft' 'difftool --tool difftastic'
git config --global 'alias.diffd' 'difftool --tool delta'
git config --global 'alias.not-staged' 'diff-files --name-only -B -R -M'
git config --global 'alias.all-changes' 'diff --name-only HEAD'
git config --global 'alias.ui' '!f() { cd "$(git rev-parse --show-toplevel)" && gitui; }; f'
git config --global 'alias.zip' '!git archive --format=zip --output=$(basename -s.git $(git remote get-url origin))-$(git describe --abbrev=0).zip $(git describe --abbrev=0)'
git config --global 'alias.tar' '!git archive --format=tar --output=$(basename -s.git $(git remote get-url origin))-$(git describe --abbrev=0).zip $(git describe --abbrev=0)'
git config --global 'alias.conflicts' '! $EDITOR $(git diff --name-only --diff-filter=U)'
git config --global 'alias.issues' '! gh issue list --assignee "@me"'
git config --global 'alias.changes' 'diff-index --name-only -B -R -M -C HEAD'
git config --global 'alias.rel-changes' 'ls-files -m -o --exclude-standard'
git config --global 'alias.ignored' 'ls-files --others --ignored --exclude-standard'
git config --global 'alias.modified-files' 'diff --name-only'
git config --global 'alias.restage' '!git add $(git diff --name-only)'
git config --global 'alias.stage-all' '!git add $(git diff --name-only HEAD)'
git config --global "alias.next-patch-release" '!git describe --tags $(git rev-list --tags --max-count=1 2>/dev/null) 2>/dev/null'"| awk -F. '{gsub(\"v\",\"\",\$1);printf \"%s.%s.%s\", \$1,\$2,\$3+1}END {if (NR==0){print \"0.0.1\"}}'"
git config --global "alias.next-minor-release" '!git describe --tags $(git rev-list --tags --max-count=1 2>/dev/null) 2>/dev/null'"| awk -F. '{gsub(\"v\",\"\",\$1);printf \"%s.%s.0\", \$1,\$2+1}END {if (NR==0){print \"0.0.1\"}}'"
git config --global "alias.next-major-release" '!git describe --tags $(git rev-list --tags --max-count=1 2>/dev/null) 2>/dev/null'"| awk -F. '{gsub(\"v\",\"\",\$1);printf \"%s.0.0\", \$1+1}END {if (NR==0){print \"0.0.1\"}}'"
git config --global 'alias.fa' '!f() { cd "$(git rev-parse --show-toplevel)" && git ls-files -m -o --exclude-standard | fzf -0 --print0 --multi --reverse --height=40% --tabstop=2 --prompt=" │ " --color="prompt:0,hl:178,hl+:178" --preview-window="right:60%" --height="80%" --bind="tab:ignore" --bind="shift-tab:ignore" --bind="ctrl-t:ignore" --bind="ctrl-g:ignore" --bind="right:toggle+down" --bind="left:toggle+up" --bind="ctrl-space:select-all" --bind="alt-space:deselect-all" --preview="git difftool --tool=delta  {}" | xargs -0 -t -o -I {} git add "{}";  }; f'
