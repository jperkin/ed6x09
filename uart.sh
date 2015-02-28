#!/bin/bash
#
# Shell script powered 16C550 UART.
#

#
# Pin assignments.
#
datapins=(2 3 4 5 6 7 8 9)
addrpins=(10 11 12)
pin_reset=13
pin_ioread=14
pin_iowrite=15
pin_clock=16
pin_enable=17

. $(dirname $0)/lib/gpio.sh

#
# Set initial pin configuration.  Data bus is bi-directional, so we set that up
# each time in read_data()/write_data().
#
for pin in $(seq 10 13); do
	pin_low ${pin}
done

for pin in $(seq 14 17); do
	pin_high ${pin}
done

#
# Read/write functions.
#
write_address()
{
	bits=$(hex2bin 3 $1 | rev)
	a=0
	for bit in $(echo ${bits} | fold -w 1); do
		pin_set ${addrpins[${a}]} ${bit}
		a=$((a + 1))
	done
}
read_data()
{
	for pin in ${datapins[@]}; do
		pin_input ${pin}
	done

	bits=""
	for pin in ${datapins[@]}; do
		bits="${bits}$(pin_read ${pin})"
	done

	echo "${bits}" | rev
}
write_data()
{
	for pin in ${datapins[@]}; do
		pin_output ${pin}
	done

	bits=$(hex2bin 8 $1 | rev)
	d=0
	for bit in $(echo ${bits} | fold -w 1); do
		pin_set ${datapins[${d}]} ${bit}
		d=$((d + 1))
	done
}
read_register()
{
	regaddr=$1; shift

	write_address ${regaddr}
	pin_low ${pin_ioread}
	read_data
	pin_high ${pin_ioread}
}
write_register()
{
	regaddr=$1; shift
	data=$1; shift

	write_address ${regaddr}
	write_data ${data}
	pin_low ${pin_iowrite}
	cyclepin ${pin_clock}
	pin_high ${pin_iowrite}
}

#
# Ok let's go.  Start by enabling and then initiating a reset.
#
pin_low ${pin_enable}
cyclepin ${pin_reset}

# Clear the Interrupt Enable Register.
write_register 0x1 0x0

# Clear the FIFO Control Register.
write_register 0x2 0x0

# Clear the Modem Control Register.  Set OP1/OP2 off (active low).
write_register 0x4 $(bin2hex 00001100)

# Set the Line Control Register to 8/N/1
write_register 0x3 $(bin2hex 10000011)

# Write a recognisable pattern to the Scratchpad Register
write_register 0x7 $(bin2hex 10010110)

#
# Now dump all of the register status.
#
regbits=$(read_register 0x0)
echo "RX/TX Holding Register = ${regbits}"

regbits=$(read_register 0x1)
echo "Intrpt Enable Register = ${regbits}"

regbits=$(read_register 0x2)
echo "Int Status/FIFO Cntrol = ${regbits}"

regbits=$(read_register 0x3)
echo "Line Control Register  = ${regbits}"

regbits=$(read_register 0x4)
echo "Modem Control Register = ${regbits}"

regbits=$(read_register 0x5)
echo "Line Status Register/R = ${regbits}"

regbits=$(read_register 0x6)
echo "Modem Status Registr/R = ${regbits}"

regbits=$(read_register 0x7)
echo "Scratchpad Register    = ${regbits}"
