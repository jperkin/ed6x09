# ed6x09

6309/6809 homebrew computer project.  My aim is to eventually build a minimal
system comprised of a 6309, EEPROM, RAM and UART.  Along the way I will be
documenting everything so that people can learn and perhaps build their own.

There are also some useful re-usable bits for if you want to do some simple
GPIO projects on a Raspberry Pi.

## gpio.sh

`lib/gpio.sh` provides some simple functions for accessing GPIO via bash.
Here's an example:

```bash
#!/bin/bash

# Load gpio functions
. $(dirname $0)/lib/gpio.sh

#
# You can immediately read and write pins, if they aren't configured they will
# be setup automatically for the requested mode.
#
pin_high 13     # Set pin13 high
pin_low 13      # Set pin13 low
pin_read 14     # Echo pin14 value to stdout

#
# Or you can do it manually.
#
pin_output 13   # Enable pin13 and set it as read/write
pin_input 14    # Enable pin14 and set it as read-only
pin_output 14   # Switch pin14 to read/write
pin_disable 14  # Unconfigure pin14

#
# Clock cycling functions.
#
cyclepin 14     # Set pin14 high then low
cyclepins 13 14 # set pin13 high, pin14 high, pin13 low, pin14 low

#
# Hex <=> Binary conversions.
#
bin2hex 101010  # => "0x2a"
hex2bin8 0x2a   # => "00101010"
hex2bin12 0x2a  # => "000000101010"
```
