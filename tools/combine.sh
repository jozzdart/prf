find lib/ -path "*/legacy/*" -prune -o -name "*.dart" -print -exec cat {} + > combined.txt
