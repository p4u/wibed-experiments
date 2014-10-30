#!/bin/bash
OUTPUT="overlays"
[ ! -d "$OUTPUT" ] && mkdir $OUTPUT

for dir in $(ls -d */); do
	dir=${dir%/}
	[ "$dir" == "$OUTPUT" ] && continue 
	echo "Creating overlay $dir"
	( cd $dir ; tar czf ../$OUTPUT/${dir}.tar.gz * )
done

echo "Overlays created in directory $OUTPUT"

