# Copy a file or stdin to the clipboard, without the trailing newline.
#   copy notes.txt    |    git diff | copy
copy() {
  if (( $# )); then
    printf '%s' "$(<"$1")" | pbcopy
  else
    printf '%s' "$(cat)" | pbcopy
  fi
}
