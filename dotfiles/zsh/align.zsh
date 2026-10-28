# Print a delimited file (or stdin) as aligned columns. The delimiter is
# whichever of tab , ; | appears most often in the first line.
#   align data.csv    |    pbpaste | align
align() {
  awk '
    NR == 1 {
      best = ","; max = 0
      n = split("\t,;|", cands, "")
      for (i = 1; i <= n; i++) {
        c = gsub(cands[i] == "|" ? "[|]" : cands[i], "&")
        if (c > max) { max = c; best = cands[i] }
      }
    }
    { lines[NR] = $0 }
    END {
      for (r = 1; r <= NR; r++) {
        nf = split(lines[r], f, best)
        for (i = 1; i <= nf; i++) if (length(f[i]) > w[i]) w[i] = length(f[i])
      }
      for (r = 1; r <= NR; r++) {
        nf = split(lines[r], f, best)
        out = ""
        for (i = 1; i < nf; i++) out = out sprintf("%-*s  ", w[i], f[i])
        print out f[nf]
      }
    }
  ' "${1:--}"
}
