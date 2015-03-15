#!/bin/bash
#
#This script uses nvidia-smi utility to check the card temp.
#It also depends on version of NVIDIA driver so you may want to change "P0" (340.x drivers) to "MB" (319.x drivers) for example.
#You also need Perl. And hashcat. An a computer.
# 
#sudo check
if [ "$(id -u)" != "0" ]; then
            echo "Sorry, but this must be run on root privileges. Try 'sudo !!'"
                        exit 1
                        fi
#check for hashcat process
                        if [ "`ps aux | grep "cudahashcat\|cudaHashcat" | grep -v grep`" = "" ]; then
                            echo "Maybe you shuld start cudahashcat first?"
                            exit 1
                            fi
#User input for pause temperature
                                    echo ""
                                    echo "Ghetto solution for problem described here: https://hashcat.net/trac/ticket/61"
                                    echo "Made by dizzy_duck"
                                    echo "This script runs independently from hashcat process and is designed only to pause program at specifiec temperature."
                                    echo "Any additional options should be set within ./cudahashcat command."
                                    echo ""
                                    echo "Please specify at which temp I should pause hashcat." 
                                    echo "This must be below hashcat STOP temperature [90C is default]: "
                                        read MAXTEMP
                                    echo "Please spiecify for how long should I pause hashcat after reaching thresold:"
                                        read PAUSETIME
#PTSNUM=`ps aux | grep "cudahashcat\|cudaHashcat" | grep -v "grep" | cut -d"/" -f2-2|cut -d" " -f1`
PTSNUM=`ps aux | grep "cudahashcat\|cudaHashcat" | grep -v "grep" | cut -d"/" -f2-2| cut -d" " -f1`
export PTSNUM
echo "Hashcat is running on $PTSNUM terminal. Commands will be passed there."
while sleep 1 
     do
	TEMP=`nvidia-smi|grep P0|cut -d" " -f4-5|cut -d "C" -f1| cut -d" " -f2`
    if [ "$TEMP" -ge "$MAXTEMP" ]; then
        echo "Thresold reached, pausing for $PAUSETIME seconds"
        perl -e '$TIOCSTI = 0x5412; $tty = "/dev/pts/$ENV{PTSNUM}"; $char = "p"; open($fh, ">", $tty); ioctl($fh, $TIOCSTI, $char)'
        sleep $PAUSETIME
            echo "Resuming..."
            perl -e '$TIOCSTI = 0x5412; $tty = "/dev/pts/$ENV{PTSNUM}"; $char = "r"; open($fh, ">", $tty); ioctl($fh, $TIOCSTI, $char)'
    fi
    done

