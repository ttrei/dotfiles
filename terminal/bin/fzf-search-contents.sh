#!/usr/bin/env sh

# https://github.com/junegunn/fzf#3-interactive-ripgrep-integration

# This is not ideal yet.
# I want to fuzzy-ripgrep through files and preview the matching lines within context.

# This may be relevan:
# https://github.com/DanielFGray/fzf-scripts/blob/master/igr

#INITIAL_QUERY=""
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
  fzf --bind "change:reload:$RG_PREFIX {q} || true" \
      --ansi --disabled --query "$INITIAL_QUERY" \
      --height=50% --layout=reverse

      #--preview 'bat {}'
