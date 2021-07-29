# Vsolidus-ubuntu-build
A script to compile vsolidus internet currency on Ubuntu 20.04
This is a test script, with no guarantees, no error trapping and needs a great deal of work. I don't recommend running the script as it, rather cut and paste
the pieces you need and walk through it step by step.

The repo for vsolidus is found here: https://github.com/VSolidus/solidus

# Ubuntu on Raspberry PI 4

In order to build on a Raspberry PI you need to make a few changes to the Berkley DB build (Only if building with a wallet), if not, follow the standard instructions.

The issue with building the DB on a PI is that the version of the build does not recognise the architecture. This is controlled by two files:

./db4/db-4.8.30.NC/dist/config.guess and ./db4/db-4.8.30.NC/dist/config.sub, these two files need to be replaced with the latest versions and the  ./contrib/install_db4.sh needs to be modified to not overwrite the
updated config.guess and sub files. Basically, the install_db4.sh file, fetches the DB4 bundle from Oracle, untar's it to the ./db4 folder each time it is run and
it is this process which continously loads the old versions of .guess and .sub

install_db4.sh is not executable, so you need to change that. As per the script, I change all of the .sh scripts to executable with the following command, run from the ~/solidus folder

chmod +x $(find ./ -name '*.sh) # which searches for all .sh files under the current path and makes them executable

nano ./contrib/install_db4.sh

Find the line: 'cd "${BDB_PREFIX}/${BDB_VERSION}/" '

paste the following below that:

'# Download the latest config.guess and config.sub files
<p>
curl https://git.savannah.gnu.org/cgit/config.git/plain/config.guess > ./dist/config.guess
<p>
curl https://git.savannah.gnu.org/cgit/config.git/plain/config.sub > ./dist/config.sub
<p>
chmod +x ./dist/config.*

Save and exit and then run "./contrib/install_db4.sh `pwd`"




