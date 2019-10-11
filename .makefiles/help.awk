# Awk program for automatically generating help text from those ludicrous makefiles.
# See help.mk for details.
function len(a,    i, k) {
  for (i in a) k++
  return k
}

function join(a, sep) {
  result = ""
  if (sep == "")
    sep = SUBSEP
  for (item in a)
    result = result sep a[item]
  return result
}

function unjoin(a, text, sep) {
  if (sep == "")
    sep = SUBSEP
  split(substr(text, 2), a, sep)
}

function append(a, item) {
  a[len(a) + 1] = item
}

function extend(a, b) {
  for (item in b)
    append(a, b[item])
}

/^#> / {
  comments[++comments_counter] = substr($0, 4)
}

/^[^: \t]*:[^;]*;?/ {
  split($0, recipe_firstline, ":")
  target = recipe_firstline[1]

  width = length(target)
  max_width = (max_width > width) ? max_width : width

  if ( substr(lastline, 1, 2) == "#>" ) {
    target_docs[target] = join(comments, "#")
    delete comments
  }
}

!/^#>/ {
  if (len(comments) > 0) {
    extend(global_docs, comments)
    append(global_docs, "")
    delete comments
  }
}

{ lastline = $0 }

END {

  for (doc in global_docs)
    print global_docs[doc]

  printf "Targets:\n"

  for (target in target_docs) {
    unjoin(help, target_docs[target], "#")
    printf "  %-" max_width "s   %s\n", target, help[1]
    for (i = 2; i <= len(help); i++)
      printf "  %-" max_width "s   %s\n", "", help[i]
  }

}
