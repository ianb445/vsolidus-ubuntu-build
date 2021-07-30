# Vsolidus-ubuntu-build
A script to compile vsolidus internet currency on Ubuntu 20.04
This is a test script, with no guarantees, no error trapping and needs a great deal of work. I don't recommend running the script as it, rather cut and paste
the pieces you need and walk through it step by step.

The repo for vsolidus is found here: https://github.com/VSolidus/solidus

# Ubuntu on Raspberry PI 4

In order to build on a Raspberry PI a few changes to the Berkley DB build files need to be made (Only if building with a wallet, if not, follow the standard instructions).

The script, contains lines in section 4 which update the the two old files config.guess and config.sub as well as a small patch to the atomic.h file required to compile on Ubuntu 19.04 

Credit to: https://fsanmartin.co/running-a-bitcoin-node-on-ubuntu-19-10/ for information on how to install Bitcoin on Ubuntu 19.04

