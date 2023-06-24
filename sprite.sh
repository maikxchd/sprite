#!/bin/bash

bind_queue_to_core() {
    local dev=$1
    local dir=$2
    local irq_vec

    max_irq=$(grep -Ei "$dev:.*$dir" /proc/interrupts | wc -l)
    if [ "$max_irq" -eq 0 ]; then
        echo "No $dir vectors found on $dev"
        return
    fi

    for ((vec = 0; vec < max_irq; vec++)); do
        irq=$(awk -v dev="$dev" -v dir="$dir" -v vec="$vec" '$0 ~ dev "-" dir "-" vec"$" {gsub(":", "", $1); print $1}' /proc/interrupts)
        if [ -n "$irq" ]; then
            mask=$((1 << (vec % 32)))
            mask_hex=$(printf "%X" $mask)
            mask_fill=$(printf "%0${vec/32}d" 0)
            full_mask="${mask_hex}${mask_fill}"
            printf "%s mask=%s for /proc/irq/%d/smp_affinity\n" "$dev" "$full_mask" "$irq"
            echo "$full_mask" > "/proc/irq/$irq/smp_affinity"
        fi
    done
}

if [ $# -eq 0 ]; then
    echo "Description:"
    echo "    This script attempts to bind each queue of a multi-queue NIC"
    echo "    to the same numbered core, i.e., tx0|rx0 --> cpu0, tx1|rx1 --> cpu1"
    echo "Usage:"
    echo "    $0 eth0 [eth1 eth2 eth3]"
    exit 1
fi

if pgrep irqbalance >/dev/null; then
    echo "WARNING: irqbalance is running and may override this script's affinitization."
    echo "         Please stop the irqbalance service and/or execute 'killall irqbalance'."
fi

for dev in "$@"; do
    for dir in rx tx TxRx; do
        bind_queue_to_core "$dev" "$dir"
    done
done
