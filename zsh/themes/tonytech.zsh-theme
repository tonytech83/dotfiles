# Define Colors
NEW_ORANGE='%F{214}'  # #FF9248
WHITE='%F{15}'
GRAY='%F{245}'
RED='%F{160}'  # #bd3220
GREEN='%F{40}'  # #4ce92d
LAVENDER='%F{141}'  # #B4BEFE
RESET='%f'

# Git Status Function
parse_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  branch=$(echo "$branch" | tr -s ' ')
  if [[ -n $branch ]]; then
    local git_status=""
    local ahead_behind=""
    local untracked=""
    local modified=""
    local staged=""
    local branch_status="≡"

    # Check if the branch is ahead or behind the remote
    local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [[ -n $upstream ]]; then
      local ahead=$(git rev-list --count HEAD ^"$upstream" 2>/dev/null)
      local behind=$(git rev-list --count "$upstream" ^HEAD 2>/dev/null)
      if [[ $ahead -gt 0 ]]; then
        ahead_behind="↑$ahead"
        branch_status=""
      fi
      if [[ $behind -gt 0 ]]; then
        ahead_behind="${ahead_behind}↓$behind"
        branch_status=""
      fi
    fi

    # Check for untracked files
    if [[ -n $(git ls-files --others --exclude-standard) ]]; then
      untracked_count=$(git ls-files --others --exclude-standard | wc -l)
      untracked=" ?$untracked_count"
    fi

    # Check for staged files
    if [[ -n $(git diff --cached --name-only) ]]; then
      staged_files=$(git diff --cached --name-only | wc -l)
      staged=" ~$staged_files"
    else
      # Check for modified files only if there are no staged files
      if [[ -n $(git status --porcelain | grep '^[ M]') ]]; then
        modified_files=$(git status --porcelain | grep '^[ M]' | wc -l)
        modified=" ~$modified_files"
      fi
    fi

    # Combine status indicators
    git_status="$branch_status $ahead_behind $staged $modified $untracked"
    git_status=$(echo "$git_status" | tr -s ' ')  # Remove extra spaces

    echo "%{$fg[white]%}on %{$fg_bold[red]%}$branch$git_status$RESET"
  fi
}

# Python Virtual Environment Detection
parse_python_venv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "$NEW_ORANGE[ $WHITEvenv$NEW_ORANGE ]$RESET"
  fi
}

# Function to calculate spacing
get_space () {
  local STR="$1$2"
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=$(( COLUMNS - LENGTH ))
  (( SPACES > 0 )) && printf '%*s' $SPACES
}

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}"
else
  _USERNAME="%{$fg_bold[green]%}%n"
  _LIBERTY="%{$fg[green]%}"
fi

# Precmd function for prompt formatting
bureau_precmd () {
  local LEFT="$GRAY┌─[ %~ ]"
  local GIT="$(parse_git_branch)"
  local RIGHT="%{$NEW_ORANGE%}[ $_USERNAME %{$WHITE%}at %{$LAVENDER%}%m %{$NEW_ORANGE%}]"
  local SPACES=$(get_space "$LEFT $GIT" "$RIGHT")
  print
  print -rP "$LEFT $GIT$SPACES$RIGHT"
}

# Apply the precmd hook
autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd

# Define Prompt
setopt PROMPT_SUBST
PROMPT='$GRAY└─$RESET$NEW_ORANGE$_LIBERTY $RESET'
