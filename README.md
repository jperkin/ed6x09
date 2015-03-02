# ed6x09

6309/6809 homebrew computer project.  My aim is to eventually build a minimal
system comprised of a 6309, EEPROM, RAM and UART.  Along the way I will be
documenting everything so that people can learn and perhaps build their own.

There are also some useful re-usable bits for if you want to do some simple
GPIO projects on a Raspberry Pi.

## gpio.sh

`lib/gpio.sh` provides some simple functions for accessing GPIO via bash.
Here's the API:

```bash
#!/bin/bash

# Load gpio functions
. $(dirname $0)/lib/gpio.sh

#
# You can immediately read and write pins, if they aren't configured they will
# be setup automatically for the requested mode.
#
pin_high 13         # Set pin13 high
pin_low 13          # Set pin13 low
pin_read 14         # Echo pin14 value to stdout
pin_set 13 1        # Set pin13 high (useful for variables)

#
# Or you can do it manually.
#
pin_output 13       # Enable pin13 and set it as read/write
pin_input 14        # Enable pin14 and set it as read-only
pin_output 14       # Switch pin14 to read/write
pin_disable 14      # Unconfigure pin14

#
# Clock cycling functions.
#
cyclepin 14         # Set pin14 high then low
cyclepins 13 14     # Set pin13 high, pin14 high, pin13 low, pin14 low

#
# Hex <=> Binary conversions.
#
bin2hex 101010      # Print at default precision: "0x2a"
hex2bin 0x2a        # Print at default precision: "101010"
hex2bin 8 0x2a      # Pad to specific precision: "00101010"
hex2bin 3 0x2a      # Truncate to specific precision: "010"
```

Here's an example writing to an 8-bit data bus at a specific 3-bit address.

```bash
#!/bin/bash

. $(dirname $0)/lib/gpio.sh

# Address and data to write from the command line
address=$1; shift
databyte=$1; shift

#
# Set up our data and address pins.  We normally need to configure a clock pin
# to clock in the data and possibly a pin to enable data writes, but we have
# ommitted such details in this example to keep things simple.
#
datapins=(2 3 4 5 6 7 8 9)
addrpins=(10 11 12)

#
# Write to our address and data pins.  We use 'rev' to reverse the bits as we
# write from Least Significant Byte (LSB) to Most Significant Byte (MSB), and
# we use a fold(1) trick to split the bit string into individual bits.
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
write_data()
{
        bits=$(hex2bin 8 $1 | rev)
        d=0
        for bit in $(echo ${bits} | fold -w 1); do
                pin_set ${datapins[${d}]} ${bit}
                d=$((d + 1))
        done
}

# Set the requested address.
write_address ${address}

# Write the data.
write_data ${databyte}
```

```console
$ ./write_to_address 0x2 0xff
```
