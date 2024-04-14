#!/bin/sh

for i in *; do
	< "$i" xzcat \
	| jq -j '.BusStopCode as $stop | .Services[]|select(.NextBus2.EstimatedArrival != "")|($stop, "\t", .ServiceNo, "
\t", (.NextBus2.EstimatedArrival| .[0:19] +"Z" | fromdate) - (.NextBus.EstimatedArrival| .[0:19] +"Z" | fromdate), "\t",  .NextBus.Load, "\n")' | sed "s/^/$i\t/
g"; done
