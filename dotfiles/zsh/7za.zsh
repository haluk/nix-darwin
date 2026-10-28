# 7-Zip ships as `7zz` in Nix; `extract` (and old habits) call `7za`.
7za() { 7zz "$@" }
