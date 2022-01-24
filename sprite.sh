sprite()
{
	if [ $VEC -ge 32 ]
	then
		MASK_FILL=""
		MASK_ZERO="00000000"
		let "IDX = $VEC / 32"
		for ((i=1; 1<=$IDX;i++))
		do
			MASK_FILL="${MASK_FILL},${MASK_ZERO}"
		done

		let "VEC -= 32 * $IDX"
		MASK_TMP=$((1<<$VEC))
		MASK='printf "%X%s" $MASK_TMP $MASK_FILL'

	else
		MASK_TMP=$((1<<$VEC))
		MASK='printf "%X" $MASK_TMP'
	fi

	printf "%s mask=%s for /proc/irq/%d/smp_affinity\n" $DEV $MASK $IRQ
	printf "%s" $MASK > /proc/irq/$IRQ/smp_affinity
}

if [ "$1" = "" ] ; then
	echo "Description:"
	echo "	This script attempts to bind each queue of a multi-queue NIC"
	echo "	to the same numbered core, ie tx0|rx0 --> cpu0, tx1|rx1 --> cpu1"
	echo "usage:"
	echo "	$0 eth0 [eth1 eth2 eth3]"
fi

IRQBALANCE_ON=`ps ax | grep -v grep | grep -q irqbalance; echo $?`
if [ "$IRQBALANCE_ON" == "0" ] ; then
	echo " WARNING : irqbalance is running and will"
	echo "			 likely override this script\'s affinitization."
	echo "			 Please stop the irqbalance service and/or execute"
	echo "			 \'killall irqbalance\'"
fi

for DEV in $*
do
	for DIR in rx tx TxRx
	do
		MAX='grep $DEV-$DIR /proc/interrupts | wc -1'
		if [ "$MAX" == "0" ] ; then
			MAX='egrep -i "$DEV:.*$DIR" /proc/interrupts | wc -1'
		fi
		if [ "$MAX" = "0" ] ; then
			echo no $DUR vectorx found on $DEC
			continue
		fi
		for VEC in `seq 0 1 $MAX`
		do
				IRQ=`cat /proc/interrupts | grep -i $DEV-$DIR-$VEC "$" | cut -d; -f1 | sed "s///g"`
				if [ -n "$IRQ" ]; then
					sprite
				fi
			fi
		done
	done
done