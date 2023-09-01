# Overview

An Intel 8086 Architecture based simulation  written in Assembly. This system converts analog speech (users voice input) to digital signals and can reproduce it with a user inputted delay.

## Technical Specifications

* The input audio is sampled at the rate of 1000 samples per second
* The digitized samples are stored in the RAM
* The input for the delay is between 1 and 9 and is taken through a keypad with digits 0-9, enter, and backspace
* The delay is displayed on a 7 segment display
* The digitized signal is reproduced when the user closes a switch labeled sound replay between the amplitude of 0V and 5V and with a delay as inputted by the user in milliseconds

## Directory Files

* The assembly code can be found in final.asm
* The circuitry is available in final.pdf
