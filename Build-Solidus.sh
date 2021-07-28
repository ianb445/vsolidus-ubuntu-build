#####################################################
# Compiling Solidus on Ubuntu 20.04 LTS
#
# Disclaimer: No warranty whatsover is provided or implied by these instructions. Use them entirely at your own risk 
# and always assume things may get broken or damaged beyond repair. This script has been provided on the basis that it has been useful to me in the past
# and may not work under any other circumstances. You have been warned.
#
# This is a combination of how-to and scripts, I do not recommend running this is an end-to-end script, but rather to copy and paste
# the sections you need with the variables. This is less likely to throw an error, in particular since you may be prompted to enter your SUDO password a few times
#
# Your primary source of information is found at https://github.com/VSolidus/solidus/blob/main/doc/build-unix.md It is important that you read this document 
# as the contents and information may change from time to time.
#
# The steps to follow are:
# 1. Create a user on your linux box with sudo permissions
# 2. Install the pre-requisites via apt
# 3. Clone the repo
# 4. Compile, build and install the Berkley DB
# 5. Compile, build and install Solidus
# 6. Add nodes and start the solidus daemon to begin building the block chain
# 
# I assume that anyone compiling code is comfortable with editing scripts and basic debugging.
#
# Set your variables here, YOU MUST CHANGE THIS STUFF to suit your deployment
username=solidus
userpath=/home/$username
# 1. Create a user on your linux box with sudo permissions
sudo adduser $username #adds the user and creates the home folder
#
#
#####################################
# 2. Install the pre-requisites 
#
echo 'Installing the pre-requisites, this will take a while and you may need to respond to prompts'
sleep 10
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y # Ensure your system is up to date with the latest versions of installed software
#
sudo apt install git # You need git to clone the repo
# From the Repo documentation https://github.com/VSolidus/solidus/blob/main/doc/build-unix.md
sudo apt-get install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 -y 
sudo apt-get install libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev -y 
sudo apt-get install libminiupnpc-dev -y # Needed if your server is behind a pnp enabled firewall
sudo apt-get install libzmq3-dev -y # Enables mq messaging
sudo apt-get install libqrencode-dev -y  # Enables encryption
#
# If you are going to install the GUI then you need the GT libraries as well. I recommend installing this, but it is not strictly necessary and adds load to your system
# your choice really
echo 'Installing the libraries for the GUI'
sleep 10
sudo apt-get install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler -y 
#
# ######################################
# 3. Clone the repo
#
# ensure we are in the installing user's home folder
echo 'Cloning the repo to the installing users folder'
cd ~
git clone https://github.com/VSolidus/solidus.git
cd solidus
echo 'Make all of the script files executable or they fail to run when building'
chmod +x $(find ./ -name '*.sh')
#
#
########################################
# 4. Compile and build the Berkley DB (Only required if you require a wallet)
#
# Note, this does not work on ARM64 architecture, because two of the scripts are reall old and do not recognise the architecture
# When you run this the script will provide you with a path to retrieve the config.guess and config.sub scripts, you need to manually install these
# and edit the install_db4.sh script to prevent it overwriting the new scripts with the old scripts from the tar file.
#
echo 'Build and install the database'
sudo ./contrib/install_db4.sh `pwd`
#
# Assuming the build went well, an absolute path to the DB installation files is provided by the install_db.sh. This pathing is required for the configuration of the build
#
#############################################
# 5. Configure and compile Solidus
#
# Note:  The https://github.com/VSolidus/solidus/blob/main/doc/build-unix.md does not run any of the scripts as root and this caused it to fail each time I tried to build
# Running things as a super-user (root) is generally considered a security risk.
#
sudo make clean # if you have previously tried to compile the code, this should clean out the pipes before trying again
./autogen.sh 
cd ~/solidus
currentpath=$(pwd)
export BDB_PREFIX=$currentpath
# This is line provided by the DB install script which you may need, I have repalced with with an assumed path, leave this as it is unless failure.
# The configure below, enables the upnp abilities and also sets the heapsize low to allow solidus to compile on machines with less than 2GB memory. It's slower, but 
# more likely to build 
./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --enable-upnp-default CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768"
sudo make
sudo make install
echo 'If everything worked, the solidus is now installed on your machine'
echo 'The binaries are located in /usr/local/bin'
#
sleep 10
#
############################################
# 6. Add nodes to the solidus.conf file for the user we created
#
#
sudo mkdir $userpath/.solidus
echo 'Creating solidus.conf file'
cat > solidus.conf <<- EOM
addnode=77.68.74.226
addnode=77.68.88.65
addnode=185.132.38.57
addnode=109.228.47.177
addnode=213.171.208.100
addnode=77.68.26.221
addnode=185.132.40.245
addnode=77.68.83.112
EOM
sleep 1
echo 'Copy the config file to the users .solidus folder'
sudo cp ./solidus.conf $userpath/.solidus
# Change ownership of the .solidus folder to the solidus user
sudo chown -R $username:$username $userpath
#
#
###############################################
# Now you need to run the software 
#
#
# Log into the system as your new user or sudo su - $username 
#
#
# run > solidusd to start the server, the log will output to the terminal and you should see it connectig to other nodes and retrieving the chain
# use <ctrl>-c to stop the server cleanly or from another session, you can issue a cli command: > solidus-cli stop 
#
#
# If you want to add the server to your startup there are a number of ways of doing this, the easiest is a contrab on boot.
#
# run > crontab -e 
# 
# select your editor, nano is generall the easiest
#
# add the following line to the crontab file
# @reboot /usr/local/bin/solidusd --daemon 
# 
# save and exit, reboot and test to see whether the daemon is started.
#####################################################
#
# Updating your software
#
#  The procedure is relatively straight forward
# login to the box as the user you used to build the app
# change to the ./solidus folder and run > git pull 
# this will download the latest changes, review them and decide whether to build or not
# then you need to run section 5 of the script again. Remember to stop any services in advance
#
######################################################
# 
# Running the GUI remotely
#
# You can run the GUI version is you have an Xwindows client installed on your desktop and have logged into your box via ssh with -x enabled 
# login with ssh eg: 
# > ssh username@myserver.com -x 
# > solidus-qt &
#
# Note: you cannot run solidusd and solidus-qt at the same time, it's one or the other,so if you have the daemon running, you need to stop it firt.

















