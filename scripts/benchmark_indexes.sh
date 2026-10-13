#!/usr/bin/env bash
# Time key queries without and with the extra indexes from sql/04_indexes.sql.
# Prints a Markdown table (GitHub Actions also writes it to the job summary).
# Usage: MYSQL_HOST=127.0.0.1 MYSQL_USER=root MYSQL_PASSWORD=secret ./scripts/benchmark_indexes.sh
set -euo pipefail

HOST="${MYSQL_HOST:-127.0.0.1}"
USER="${MYSQL_USER:-root}"
PASS="${MYSQL_PASSWORD:-}"
MYSQL=(mysql -h "$HOST" -u "$USER" -D retail_sales --batch --skip-column-names)
[ -n "$PASS" ] && MYSQL+=(-p"$PASS")
RUNS="${RUNS:-5}"
QUERIES=(12_repeat_customer_rate 13_customer_cohort_retention 16_payment_method_mix 19_category_pairs_in_basket)

drop_indexes() {
  for idx in idx_sales_order idx_sales_customer_date idx_sales_date_store; do
    "${MYSQL[@]}" -e "DROP INDEX $idx ON fact_sales" 2>/dev/null || true
  done
  "${MYSQL[@]}" -e "DROP INDEX idx_product_category ON dim_product" 2>/dev/null || true
}

# median wall-clock time in milliseconds over $RUNS runs (after one warm-up run)
time_query() {
  local file="queries/$1.sql" times=()
  "${MYSQL[@]}" < "$file" > /dev/null
  for _ in $(seq "$RUNS"); do
    local s e
    s=$(date +%s%N); "${MYSQL[@]}" < "$file" > /dev/null; e=$(date +%s%N)
    times+=($(( (e - s) / 1000000 )))
  done
  printf '%s\n' "${times[@]}" | sort -n | awk '{a[NR]=$1} END {print a[int((NR+1)/2)]}'
}

declare -A before after
drop_indexes
for q in "${QUERIES[@]}"; do before[$q]=$(time_query "$q"); done
"${MYSQL[@]}" < sql/04_indexes.sql
for q in "${QUERIES[@]}"; do after[$q]=$(time_query "$q"); done

{
  echo "### Index benchmark (median of $RUNS runs, MySQL $("${MYSQL[@]}" -e 'SELECT VERSION()'))"
  echo ""
  echo "| Query | Without extra indexes (ms) | With indexes (ms) | Speed-up |"
  echo "|---|---:|---:|---:|"
  for q in "${QUERIES[@]}"; do
    b=${before[$q]}; a=${after[$q]}
    awk -v q="$q" -v b="$b" -v a="$a" 'BEGIN { printf "| %s | %d | %d | %.1fx |\n", q, b, a, (a > 0 ? b / a : 0) }'
  done
} | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"
