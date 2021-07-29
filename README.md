# vsolidus-ubuntu-build
A script to compile vsolidus internet currency on Ubuntu 20.04
This is a test script, with no guarantees, no error trapping and needs a great deal of work. I don't recommend running the script as it, rather cut and paste
the pieces you need and walk through it step by step.

# Ubuntu on Raspberry PI 4

In order to build on a Raspberry PI you need to make a few changes to the Berkley DB build (Only if building with a wallet), if not, follow the standard instructions.

The issue with building the DB on a PI is that the version of the build does not recognise the architecture. This is controlled by two files:

./db4/db-4.8.30.NC/dist/config.guess and ./db4/db-4.8.30.NC/dist/config.sub, these two files need to be replaced with the latest versions and the  ./contrib/install_db4.sh needs to be modified to not overwrite the
updated config.guess and sub files. Basically, the install_db4.sh file, fetches the DB4 bundle from Oracle, untar's it to the ./db4 folder each time it is run and
it is this process which continously loads the old versions of .guess and .sub

install_db4.sh is not executable, so you need to change that. As per the script, I change all of the .sh scripts to executable with the following command, run from the ~/solidus folder

chmod +x $(find ./ -name '*.sh) # which searches for all .sh files under the current path and makes them executable

The latest versions are found at and are included in this repo as at the 29/07/21:

config.guess: 
http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD

config.sub: 
http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD

We need to stop the untaring of the file and then replace the two files with the latest versions:

edit the install_db4.sh file and comment out the following line, by adding a hash sign in front to prevent the tarball being untarred:

'# tar -xzvf ${BDB_VERSION}.tar.gz -C "$BDB_PREFIX"

copy config.guess and config.sub to ./db4/db-4.8.30.NC/dist folder, overwriting the exiting files

now run ./contrib/install_db4.sh `pwd` (seems to offer less grief when run with sudo), ie. sudo ./contrib/install_db4.sh `pwd`










