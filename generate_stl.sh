#!/bin/bash

for t in wide long; do
	for d in $(seq 1 4); do
		if [ $t = "long" ]; then
			drawer_long="true";
		else
			drawer_long="false";
		fi
		file="switch_control_storage_${t}_${d}.stl";
		echo "generating $file";
		openscad -o $file -D "drawer_long=${drawer_long}" -D "drawers=${d}" switch_control_storage.scad >/dev/null 2>&1;
	done
done
