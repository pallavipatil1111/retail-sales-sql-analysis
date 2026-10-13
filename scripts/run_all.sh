#!/usr/bin/env bash
# Build the database, load the data and run every analysis query.
# Usage (from the repository root):
#   MYSQL_HOST=127.0.0.1 MYSQL_USER=root MYSQL_PASSWORD=secret ./scripts/run_all.sh
# Results are written to results/<query>.csv
set -euo pipefail

HOST="${MYSQL_HOST:-127.0.0.1}"
USER="${MYSQL_USER:-root}"
PASS="${MYSQL_PASSWORD:-}"
MYSQL=(mysql --local-infile=1 -h "$HOST" -u "$USER")
[ -n "$PASS" ] && MYSQL+=(-p"$PASS")

[ -f data/fact_sales.csv ] || python3 data/generate_data.py

echo "Creating schema, loading data, views and indexes..."
for f in sql/01_schema.sql sql/02_load.sql sql/03_views.sql sql/04_indexes.sql; do
  echo "  $f"
  "${MYSQL[@]}" < "$f"
done

mkdir -p results
echo "Running analysis queries..."
for q in queries/*.sql; do
  name="$(basename "$q" .sql)"
  # --batch gives tab-separated output; convert tabs to commas for CSV
  "${MYSQL[@]}" --batch < "$q" | sed 's/\t/,/g' > "results/${name}.csv"
  printf '  %-42s %5s rows\n' "$name" "$(($(wc -l < "results/${name}.csv") - 1))"
done
echo "Done. Results are in results/"
