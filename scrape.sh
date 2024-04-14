#!/bin/sh

APIKEY=

hhmm2m() {
	for i in "$@"; do
		h="$(echo "${i::-2}" | tr -cd '0-9')"
		m="$(echo "${i: -2}" | tr -cd '0-9')"
		echo $((10#$h*60+10#$m))
	done
}

m2hhmm() {
	for i in "$@"; do
		printf '%02d%02d\n' $((i/60)) $((i%60))
	done
}

randtimings() {
	start="$1"; end="$2"
	seq $start $end | shuf -n $(((end-start)/4)) | sort -n
}

fetchdata() {
	printf '%s\n' "$@" \
	| xargs -rn1 -P 50 sh -c \
		'printf "%s %s\n" "$1" "$(curl -H "AccountKey: '"$APIKEY"'" -s "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=$1" | tr "\n" " ")"' --
}

[ -e busstops ] || shuf -n 50 stops_num > busstops
busstops="$(cat busstops)"

[ -e timings ] || {
	randtimings $(hhmm2m 0600 0730)
	randtimings $(hhmm2m 0730 1000)
	randtimings $(hhmm2m 1000 1700)
	randtimings $(hhmm2m 1700 2000)
	randtimings $(hhmm2m 2000 2200)
} > timings

mkdir -p data

while IFS= read -r t; do
	sleepdur=$(($t-$(hhmm2m $(date '+%H%M'))))
	[ $sleepdur -lt 0 ] && continue
	[ $sleepdur -gt 10 ] && echo >&2 "!! sleepdur = ${sleepdur}m"
	echo >&2 "LTR $(m2hhmm $t)"
	sleep "$sleepdur"m
	t="$(hhmm2m $(date '+%H%M'))"
	echo >&2 "GET $(m2hhmm $t)"
	(
		fetchdata $busstops | xzcat -e -z > data/$t
		echo >&2 "GOT $(m2hhmm $t)"
	) #&
done < timings
