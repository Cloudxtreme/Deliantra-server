#!/bin/bash
#
#
# On the Linux Mint 18.1-cinnamon Live CD (x86):
#  Open a terminal
#  cd $HOME
#  xed install_deliantra.sh &
#  # copy and paste this code and save in $HOME
#  chmod u+x install_deliantra.sh
#  ./install_deliantra.sh
#  This will, and should, take several minutes.
#  When I tried it on a VirtualBox virtual machine
#  with a single processor and 4GB ram, it took 10m 29.596s real time.
#
#  sleep_10 adds 10 seconds of buffer time between every command.
#  Make it not sleep to speed up the process.
#
#
#
#  You will have to monitor the install process a little bit.
#  When CPAN installs the first module, you will have to run through its configuration.
#  The default should be good enough.
#
#

function sleep_10()
{
	echo
    sleep 5
	clear
	echo
}

function getAndExtractBZ2Archive()
{
	echo
	echo getAndExtractBZ2Archive "$@".
	wget -q -O - "$1" | tar -xjv
	if [ $? != 0 ]
	then
		echo Something went wrong when downloading or extracting archive "$@". >&2
		exit 1
	fi
	sleep_10
}

function getAndExtractGzArchive()
{
	echo
	echo getAndExtractGzArchive "$@".
	wget -q -O - "$1" | tar -xzv
	if [ $? != 0 ]
	then
		echo Something went wrong when downloading or extracting archive "$@". >&2
		exit 1
	fi
	sleep_10
}

function getFromSchmorpCVS()
{
	cvs -z3 -d :pserver:anonymous@cvs.schmorp.de/schmorpforge co -d $@
}

function install()
{
	echo
	echo installing "$@".
	sudo apt-get -y install $@
	if [ $? != 0 ]
	then
		echo Something went wrong when installing package "$@". >&2
		exit 1
	fi
	sleep_10
}
	
function install_cpanm()
{
	echo
	echo install_cpanm "$@".
	install cpanminus
	# cpan App::cpanminus 
	if [ $? != 0 ]
	then
	echo Something went wrong when installing cpanm. >&2
		exit 1
	fi
	sleep_10
}

function setup_cpan()
{
	clear
	echo $PATH
	cpan
}

function install_perlModule()
{
	echo
	echo Trying to install perl module "$@".
	cpan $1
	if [ $? -ne 0 ]
	then
		echo Installing perl module "$@" failed.
		echo Trying to force install perl module "$@".
		cpan -f "$1"
		if [ $? != 0 ]
		then
			echo Something went wrong when installing perl module "$@". >&2
			exit 1
		else
			echo Successfuly forced installation of perl module "$@".
		fi
	else
		echo Successfully installed perl module "$@".
	fi
	sleep_10
}

function downgrade_perl()
{
	PERL_SOURCE=http://stableperl.schmorp.de/dist/latest.tar.gz
	#stableperl at 	http://stableperl.schmorp.de/dist/latest.tar.gz should work.
	mkdir -v perl
	cd perl
	getAndExtractGzArchive $PERL_SOURCE
    sleep_10
	cd stableperl-5.22.0-1.001
	#cd perl-5.18.4
	./Configure -des -Dprefix=$HOME/.local/
    sleep_10
	make
    sleep_10
	#make test
    #sleep_10
    make install
    sleep_10
    echo $PATH
    #export PATH=$HOME/localperl/bin:"$PATH"
    echo $PATH
    sleep_10
}

function install_prerequisites()
{
    sudo apt-get update
	install cvs
    install gperf
    #install blitz++
    install optipng
    install pngnq
    install rsync
    install imagemagick
    install libglib2.0-dev
    install libpng12-dev
    install libpod-pom-perl
    install libsafe-hole-perl
    install libevent-perl
    install libdb5.3-dev
	install gcc
	install g++
}

function install_modules()
{
    install_perlModule common::sense
    install_perlModule AnyEvent
    install_perlModule AnyEvent::AIO
    install_perlModule AnyEvent::BDB
    install_perlModule BDB
    install_perlModule Compress::LZF
    install_perlModule Coro
    #The script quits here because building Coro fails.
    install_perlModule Coro::EV
    install_perlModule Deliantra
    install_perlModule Digest::MD5
    install_perlModule EV
    install_perlModule Guard
    install_perlModule IO::AIO
    install_perlModule JSON::XS
    install_perlModule AnyEvent::IRC
    install_perlModule Pod::POM
    install_perlModule Safe::Hole
    install_perlModule Storable
    #install_perlModule Time::HiRes
    install_perlModule URI
    install_perlModule YAML::XS
    install_perlModule CBOR::XS
}

function install_server()
{
	clear
    mkdir -v ~/Deliantra
    cd ~/Deliantra
    pwd
    sleep_10
	getFromSchmorpCVS server deliantra/server

    #getAndExtractBZ2Archive http://dist.schmorp.de/deliantra/deliantra-server-3.0.tar.bz2
    pwd
    cd server
    pwd
    sleep_10
    ./autogen.sh --prefix=$HOME/.local/
	#mkdir -v build
	#cd build
    ./configure
	if [ $? != 0 ]
	then
	echo Something went wrong when configuring Deliantra. >&2
		exit 1
	fi
    sleep_10
    make
	if [ $? != 0 ]
	then
	echo Something went wrong when making Deliantra. >&2
		exit 1
	fi
    sleep_10
    make test
	if [ $? != 0 ]
	then
	echo Something went wrong when testing Deliantra. >&2
		exit 1
	fi
	make install
	if [ $? != 0 ]
	then
	echo Something went wrong when testing Deliantra. >&2
		exit 1
	fi
    sleep_10
}

function main()
{
#rm -Rfv ~/Deliantra ~/perl ~/localperl

install_prerequisites
    echo $PATH
downgrade_perl
    echo $PATH
#install_cpanm
setup_cpan
install_modules
install_server

cd ~/Deliantra

getFromSchmorpCVS arch deliantra/arch
getFromSchmorpCVS maps deliantra/maps


#getAndExtractBZ2Archive http://dist.schmorp.de/deliantra/deliantra-maps-3.0.tar.bz2
#getAndExtractBZ2Archive http://dist.schmorp.de/deliantra/deliantra-arch-3.0.tar.bz2
}

time main


