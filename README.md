STM32MP157C cmake template
----

[![dimtass](https://circleci.com/gh/dimtass/stm32mp1-cmake-template.svg?style=svg)](https://circleci.com/gh/dimtass/stm32mp1-cmake-template)

This is a CMake template to build a basic firmware for the Cortex-M4 MCU in the
STM32MP157C-DK2 development kit. The firmware can be built using any GCC toolchain
(e.g. Yocto). When the firmware is loaded in the MCU then if the Cortex-A CPU is
running Linux then a serial device with the name `/dev/ttyRPMSG0`, which you can
open and start sending data to the MCU and vice versa.

## Build
To build the firmware you need to clone the repo in any directory and then inside
that directrory run the command:

```sh
SRC=src_hal ./build.sh
```

The above command assumes that you have a toolchain in your `/opt` folder. In case,
you want to point to a specific toolchain path, then run:

```sh
TOOLCHAIN_DIR=/path/to/toolchain SRC=src_hal ./build.sh
```

Or you can edit the `build.sh` script and add your toolchain path.

It's better to use Docker to build the image. To do that run this command:
```sh
docker run --rm -it -v $(pwd):/tmp -w=/tmp dimtass/stm32-cde-image:latest -c "SRC=src_hal ./build.sh"
```

In order to remove any previous builds, then run:
```sh
docker run --rm -it -v $(pwd):/tmp -w=/tmp dimtass/stm32-cde-image:latest -c "CLEANBUILD=true SRC=src_hal ./build.sh"
```

## Loading the firmware to CM4
To load the firmware on the Cortex-M4 MCU you need to scp the firmware `.elf` file in the
`/lib/firmware` folder of the Linux instance of the STM32MP1. Then you also need to copy the
`fw_cortex_m4.sh` script on the `/home/root` (or anywhere you like) and then run this command
as root.
```sh
./fw_cortex_m4.sh start
```

To stop the firmware run:
```sh
./fw_cortex_m4.sh stop
```

> Note: The console of the STM32MP1 is routed in the micro-USB connector `STLINK CN11` which
in case of my Ubuntu shows up as `/dev/ttyACMx`.

When you copy the `./fw_cortex_m4.sh` you need also to enable the execution flag with:
```sh
chmod +x fw_cortex_m4.sh
```

If the firmware is loaded without problem you should see an output like this:
```sh
fw_cortex_m4.sh: fmw_name=stm32mp157c-cmake-template.elf
[  162.549297] remoteproc remoteproc0: powering up m4
[  162.588367] remoteproc remoteproc0: Booting fw image stm32mp157c-cmake-template.elf, size 704924
[  162.596199]  mlahb:m4@10000000#vdev0buffer: assigned reserved memory node vdev0buffer@10042000
[  162.607353] virtio_rpmsg_bus virtio0: rpmsg host is online
[  162.615159]  mlahb:m4@10000000#vdev0buffer: registered virtio0 (type 7)
[  162.620334] virtio_rpmsg_bus virtio0: creating channel rpmsg-tty-channel addr 0x0
[  162.622155] rpmsg_tty virtio0.rpmsg-tty-channel.-1.0: new channel: 0x400 -> 0x0 : ttyRPMSG0
[  162.633298] remoteproc remoteproc0: remote processor m4 is now up
[  162.648221] virtio_rpmsg_bus virtio0: creating channel rpmsg-tty-channel addr 0x1
[  162.671119] rpmsg_tty virtio0.rpmsg-tty-channel.-1.1: new channel: 0x401 -> 0x1 : ttyRPMSG1
 ```

This means that the firmware is loaded and the virtual tty port is mapped.

## Testing the firmware
When this example firmware loads then two new tty ports will be created in the Linux side,
which are `/dev/ttyRPMSG0` and `/dev/ttyRPMSG1`. Now to test that the firmware is working
properly run these commands on the Linux terminal.

```sh
stty -onlcr -echo -F /dev/ttyRPMSG0
cat /dev/ttyRPMSG0 &
stty -onlcr -echo -F /dev/ttyRPMSG1
cat /dev/ttyRPMSG1 &
echo "Hello Virtual UART0" >/dev/ttyRPMSG0
echo "Hello Virtual UART1" >/dev/ttyRPMSG1
```

You should see the same strings received back (echo).

## Debug serial port
The firmware also supports a debug UART on the CM4. This port is mapped to UART7 and the
Arduino connector pins. The pinmap is the following:

pin | Function
-|-
D0 | Rx
D1 | Tx

You can connect a USB-to-UART module to those pins and the GND and then open the tty port
on your host. The port supports 115200 baudrate. When the firmware loads on the CM4 then
you should see this messages:

```sh
[00000.008][INFO ]Cortex-M4 boot successful with STM32Cube FW version: v1.2.0
[00000.015][INFO ]Virtual UART0 OpenAMP-rpmsg channel creation
[00000.021][INFO ]Virtual UART1 OpenAMP-rpmsg channel creation
```

## Using the cmake template in Yocto
TBD

## Author
Dimitris Tassopoulos <dimtass@gmail.com>