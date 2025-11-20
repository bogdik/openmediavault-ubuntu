#!/bin/bash

REQ_VER="3007.7"
CUR_VER="$(dpkg-query -W -f='${Version}' salt-minion 2>/dev/null || echo)"

if dpkg --compare-versions "$CUR_VER" lt "$REQ_VER"; then
	echo "Version mins $REQ_VER - prepare commands…"
	BASE_DIR="/srv/salt/omv/deploy"

	for dir in "$BASE_DIR"/*; do
	    svc="$(basename "$dir")"

	    for file in "$dir"/*.sls; do
		[ -f "$file" ] || continue

		sed -i -E "/^monitor_${svc}_service:/,/^$/{
		    s/^([[:space:]]*)- name:/    - m_name:/;
		    s/^([[:space:]]*)- monit.monitor:/\1- name: monit.monitor/;

		}" "$file"
	    done
	done
    
else
	echo "No need chenges..."
fi
