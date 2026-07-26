#!/bin/bash
set -e

INPUT=/data/src/query.sql
EXTRACT=/data/src/active-query.sql
RESULT=/data/src/result.csv
ERRLOG=/data/output/query_error.log

if [[ ! -f "$INPUT" ]]; then
  echo "ERROR: $INPUT not found" >&2
  exit 2
fi

# verify markers existed at all (so student cannot delete them)
if ! grep -qE "^-- $SUBTASK BEGIN[[:space:]]*$" "$INPUT"; then
  echo "ERROR: missing '-- $SUBTASK BEGIN' marker" >&2
  exit 101
fi
if ! grep -qE "^-- $SUBTASK END[[:space:]]*$" "$INPUT"; then
  echo "ERROR: missing '-- $SUBTASK END' marker" >&2
  exit 102
fi

# extract only requested block into $EXTRACT
sed -n "/^-- $SUBTASK BEGIN[[:space:]]*$/,/^-- $SUBTASK END[[:space:]]*$/p" "$INPUT" \
| sed '1d;$d' \
> "$EXTRACT"

# optional check: empty? (user may have markers but no sql)
if [[ ! -s "$EXTRACT" ]]; then
  echo "ERROR: no SQL between BEGIN/END for $SUBTASK" >&2
  exit 103
fi

# now run ONLY that query.
# "Run/Uruchom" display path emits column-name headers; the grade path stays headerless.
# RUN_DISPLAY is set ONLY by the run-code compose; the grade compose never sets it, so the
# scored result.csv keeps the byte-identical --skip-column-names form below and the C++
# checkers are unaffected.
if [[ -n "${RUN_DISPLAY:-}" ]]; then
  # Drop --skip-column-names so mysql prints the result-set column labels (aliases from
  # `AS ...` included) as the first row. A sentinel line is prepended so the frontend can
  # detect header presence and stay backward-compatible with templates not yet re-ingested.
  # The sentinel is written only on query success — via a temp file so a failed query leaves
  # no partial header.
  if ! mysql --local-infile=1 \
        -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
        --batch --raw \
        < "$EXTRACT" > "$RESULT.tmp" \
        2> "$ERRLOG"
  then
    rm -f "$RESULT.tmp"
    echo "User query failed. See query_error.log for details."
    exit 100
  fi
  { printf '%s\n' '#__MATURA_COLNAMES__'; cat "$RESULT.tmp"; } > "$RESULT"
  rm -f "$RESULT.tmp"
elif ! mysql --local-infile=1 \
      -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
      --batch --raw --skip-column-names \
      < "$EXTRACT" > "$RESULT" \
      2> "$ERRLOG"
then
  echo "User query failed. See query_error.log for details."
  exit 100
fi

echo "Subtask $SUBTASK OK."
exit 0
