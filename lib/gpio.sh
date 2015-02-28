#!/bin/bash
#
# Set of helper functions and definitions for accessing /sys/class/gpio
# via shell scripts.
#

GPIO=/sys/class/gpio

#
# Sanity checks, we require some utils which aren't installed by default,
# and of course need to be able to write to the gpio driver.
#
if [ ! -x /usr/bin/dc ]; then
	echo "ERROR: Please 'apt-get install dc'" >&2
	exit 1
fi
if [ ! -w /sys/class/gpio ]; then
	echo "ERROR: Cannot write to /sys/class/gpio" >&2
	exit 1
fi

#
# Configuring pins for reading or writing.
#
pin_enable()
{
	pin=$1; shift
	direction=$1; shift

	if [ ! -d ${GPIO}/gpio${pin} ]; then
		echo ${pin} >${GPIO}/export
	fi

	echo ${direction} >${GPIO}/gpio${pin}/direction
}
pin_input()
{
	pin_enable $1 in
}
pin_output()
{
	pin_enable $1 out
}
pin_disable()
{
	pin=$1; shift

	if [ -d ${GPIO}/gpio${pin} ]; then
		echo ${pin} >${GPIO}/unexport
	fi
}

#
# Reading and writing a pin.
#
pin_read()
{
	pin=$1; shift

	pin_input ${pin}

	echo $(<${GPIO}/gpio${pin}/value)
}
pin_set()
{
	pin=$1; shift
	val=$1; shift

	if [ ! -f ${GPIO}/gpio${pin}/value ]; then
		pin_output ${pin}
	fi

	echo ${val} >${GPIO}/gpio${pin}/value
}
pin_high()
{
	pin_set $1 1
}
pin_low()
{
	pin_set $1 0
}

#
# Clock cycles
#
cyclepin()
{
	pin=$1; shift

	pin_high ${pin}
	pin_low ${pin}
}
# For multiple clocks, e.g. 6x09 CPUs
cyclepins()
{
	for pin in "$@"; do
		pin_high ${pin}
	done
	for pin in "$@"; do
		pin_low ${pin}
	done
}

#
# Format conversions.
#
bin2hex()
{
	bin=$1; shift

	printf "0x%x\n" $(echo "2 i ${bin} p" | dc);
}
hex2bin()
{
	if [ $# -eq 1 ]; then
		bits=""
		hex=$1; shift
	else
		bits=$1; shift
		hex=$1; shift
	fi

	# dc(1) requires hex to be uppercase.
	hex=$(echo ${hex} | tr a-z A-Z)

	printf "%0${bits}d\n" $(echo "16 i 2 o ${hex} p" | dc);
}
hex2bin12()
{
	hex2bin 12 $1
}
hex2bin8()
{
	hex2bin 8 $1
}
hex2bin3()
{
	hex2bin 3 $1
}
