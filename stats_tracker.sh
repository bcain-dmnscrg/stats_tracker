#!/bin/bash

declare -a last_stats
declare -a new_stats

delay=$1
regex=$2

if [ -z "$delay" ]; then
    delay=2
fi
filter=""
if [ -n "$regex" ]; then
    raw_stats=`mysql -BN -e "show global status" | egrep "$regex" | sed 's/\(\w\w*\)\s\s*\(\w\w*\)/\1:\2/' | grep ':' | tr '\n' ' '`
else
    raw_stats=`mysql -BN -e "show global status" | sed 's/\(\w\w*\)\s\s*\(\w\w*\)/\1:\2/' | grep ':' | tr '\n' ' '`
fi

eval last_stats=($raw_stats)

while [ 1 ]; do
    echo "============================================================="
    echo "Sleeping for $delay seconds"
    echo "============================================================="
    sleep $delay
    printf "%-40s\t%15s\t%15s\t%15s\n" " " "Last value" "New value" "Diff"
    if [ -n "$regex" ]; then
        raw_stats=`mysql -BN -e "show global status" | egrep "$regex" | sed 's/\(\w\w*\)\s\s*\(\w\w*\)/\1:\2/' | grep ':' | tr '\n' ' '`
    else
        raw_stats=`mysql -BN -e "show global status" | sed 's/\(\w\w*\)\s\s*\(\w\w*\)/\1:\2/' | grep ':' | tr '\n' ' '`
    fi
    eval new_stats=($raw_stats)
    for index in `seq 1 ${#new_stats[@]}`; do
        old_keypair=${last_stats[$index-1]}
        new_keypair=${new_stats[$index-1]}
        key=${old_keypair%%:*}
        old_value=${old_keypair#*:}
        new_value=${new_keypair#*:}
        if [[ "$old_value" =~ ^-?[0-9]+[.]?[0-9]*$ ]]; then
            if [ 1 -eq `echo "$old_value != $new_value" | bc -l` ]; then
                diff=`echo "$new_value - $old_value" | bc -l`
                printf "%-40s\t%15s\t%15s\t%15s\n" $key $old_value $new_value $diff
            fi
        else
            if [ "$old_value" != "$new_value" ]; then
                printf "%-40s\t%15s\t%15s\n" $key $old_value $new_value
            fi
        fi
        last_stats[$index-1]="$new_keypair"
    done
done