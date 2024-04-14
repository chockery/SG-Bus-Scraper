#!/bin/sh

freqmult() {
	while read -r c s; do
		for i in $(seq 1 $c); do echo "$s"; done
	done
}

[ 0 -eq $# ] && set -- *
for f in "$@"; do
#	busnum="$(cut -f 2 "$f" | sort | uniq -c | sort -nr | freqmult | shuf -n1)"
#	[ -n "$busnum" ] || { echo >&2 "bad busnum $busnum"; exit 1; }
#	echo "$f: $busnum"

	set -o pipefail
	busnum="$(grep "^$f" ../filter | cut -d ' ' -f 2)" || continue

	sed -n '/^[0-9]*\t'"$busnum"'\t/p' "$f" > ../filteredstops/"$f"
done
