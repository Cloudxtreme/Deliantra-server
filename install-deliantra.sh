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

#path to source download folder.
export _SRC="$HOME/src"
#path to install root folder
export PREFIX="$HOME/.local"

function main()
{
	mkdir "$_SRC"
	cd "_$SRC"
	install_prerequisites
	echo "$PATH"
	downgrade_perl
	echo "$PATH"
	#install_cpanm
	setup_cpan
	install_modules
	install_server
	installClient
	installEditor
}


#see the README file for a list of prerequisites. Prefer apt-get for installation on Debian-based systems.
function install_prerequisites()
{
    sudo apt-get update
#	sudo apt-get upgrade
	#server dependencies:
	install build-essential
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
	install autoconf
	install automake
	install autoconf-archive
	install_blitz
	
	#editor dependencies:
	install libgtk2.0-dev
	
	#client dependencies:
	
	#23	*** HINT: Debian/Ubuntu users might have some luck with:
	#24	*** apt-get install perl
#	libpango1.0-dev
# 	libglib2.0-dev
# 	libsdl1.2-dev
	#25	*** apt-get install
#	libsdl-mixer1.2-dev
# 	libsdl-image1.2-dev
	#26	*** apt-get install
#	libwww-perl
# 	libdb4.4-dev
	#27	*** apt-get install
#	libanyevent-perl

	install libpango1.0-dev
	install libsdl1.2-dev
	install libsdl-mixer1.2-dev
	install libsdl-image1.2-dev
	install libwww-perl
#	install libdb4.4-dev
	#we don't know if the following is really needed.
#	install libanyevent-perl
	
	
}

#Install using apt-get.
function install()
{
	echo
	echo installing "$@".
	sudo apt-get -y install $@
	if [ "$?" != 0 ]
	then
		echo Something went wrong when installing package "$@". >&2
		exit 1
	fi
	sleep_10
	
}

#Sleep for 10 seconds and clear the console.
function sleep_10()
{
	echo
#    sleep 10
	clear
	echo
	
}

#Download and install blitz++ library
function install_blitz()
{
	mkdir -v "$_SRC/blitz"
	cd "$_SRC/blitz"
	getAndExtractGzArchive https://sourceforge.net/projects/blitz/files/latest/download
	cd blitz-0.10
	
	./configure --prefix="$PREFIX"
	check_for_success $? "configuring Blitz++"
	
	make
	check_for_success $? "making Blitz++"
	
	make check
	check_for_success $? "checking Blitz++"
	
	make install
	check_for_success $? "installing Blitz++"
	
}

#Check status $1, on failure print an error that action $2 failed, report $status and exit.
function check_for_success()
{
	status="$1"
	action="$2"
	echo "$status"
	if [ "$status" != "0" ]
	then
	echo "Something went wrong when $action" >&2
	echo "status: $status" >&2
		exit 1
	fi
	sleep_10
	
}

#Download and gunzip a .tar.gz archive
function getAndExtractGzArchive()
{
	echo
	echo getAndExtractGzArchive "$@".
	wget -q -O - "$1" | tar -xzv
	if [ "$?" != 0 ]
	then
		echo Something went wrong when downloading or extracting archive "$@". >&2
		exit 1
	fi
	sleep_10
	
}

#Install a more compatible version of Perl.
function downgrade_perl()
{
	PERL_SOURCE=http://stableperl.schmorp.de/dist/latest.tar.gz
	mkdir -v "$_SRC/perl"
	cd "$_SRC/perl"
	getAndExtractGzArchive "$PERL_SOURCE"
    sleep_10
	cd stableperl-5.22.0-1.001
	./Configure -des -Dprefix="$PREFIX"
	check_for_success $? "configuring stableperl"
	make
	check_for_success $? "making stableperl"
	make test
	check_for_success $? "testing stableperl"
    make install
	check_for_success $? "installing stableperl"
#    echo $PATH
#    #export PA	TH=$HOME/localperl/bin:"$PATH"
#    echo $PATH
#    sleep_10

}

#Setup cpan. Someone will need to watch the console.
function setup_cpan()
{
	clear
	echo "$PATH"
	cpan
	
}

#install all the needed Perl modules. See README file.
function install_modules()
{

	#server dependencies:
    install_perlModule common::sense
    install_perlModule AnyEvent
    install_perlModule AnyEvent::AIO
    install_perlModule AnyEvent::BDB
    install_perlModule BDB
    install_perlModule Compress::LZF
    install_perlModule Coro
    install_perlModule Coro::EV
    install_perlModule Digest::MD5
    install_perlModule EV
    install_perlModule Guard
    install_perlModule IO::AIO
    install_perlModule JSON::XS
    install_perlModule AnyEvent::IRC
    install_perlModule Pod::POM
    install_perlModule Safe::Hole
    install_perlModule Storable
    install_perlModule URI
    install_perlModule YAML::XS
    install_perlModule CBOR::XS
	install_DeliantraPerl
	
	#editor dependencies:
	install_perlModule Glib
	install_perlModule Gtk2
	install_perlModule Object::Event
	install_perlModule AnyEvent::EditText
	
	#client dependencies:
	
#67	    PREREQ_PM => {
#68	       common::sense => 3.6,    #installed
#69	       BDB           => 1.83,   #installed
#70	       Deliantra     => 1.31,   #installed
#71	       Time::HiRes   => 0,      
#72	       EV            => 3.42,   #installed
#73	       Guard         => 1,      #installed
#74	       AnyEvent      => 4.331,  #installed
#75	       Compress::LZF => 3.41,   #installed
#76	       Pod::POM      => 0.27,   #installed
#77	       LWP           => 0,
#78	       JSON::XS      => 2.2222, #installed
#79	       IO::AIO       => 4,      #installed
#80	       AnyEvent::AIO => 1,      #installed
#81	       Coro          => 6,      #installed
#82	       Coro::EV      => 0,      #installed
#83	       Urlader       => 1,
#84	    },

	install_perlModule Time::HiRes
	install_perlModule LWP
	install_perlModule Urlader


}

#Use CPAN to install the named Perl module.
function install_perlModule()
{
	echo
	echo Trying to install perl module "$@".
	cpan "$1"
	if [ "$?" -ne 0 ]
	then
		echo Installing perl module "$@" failed.
		echo Trying to force install perl module "$@".
		cpan -f "$1"
		if [ "$?" != 0 ]
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

#install the most recent Deliantra Perl module.
function install_DeliantraPerl()
{
	mkdir -v "$_SRC/DeliantraPL"
	cd "$_SRC/DeliantraPL"
	getFromSchmorpCVS DeliantraPL deliantra/Deliantra
	cd DeliantraPL
	perl Makefile.PL
	check_for_success $? "configuring the Deliantra Perl module"
	make
	check_for_success $? "making the Deliantra Perl module"
#	make check
#	check_for_success $? "checking the Deliantra Perl module"
	make test
	check_for_success $? "testing the Deliantra Perl module"
	make install
	check_for_success $? "installing the Deliantra Perl module"
	
}

#Get sources from the Schmorp CVS.
function getFromSchmorpCVS()
{
	cvs -z3 -d :pserver:anonymous@cvs.schmorp.de/schmorpforge co -d "$1" "$2"
	
}

#Install the Deliantra server.
function install_server()
{
	clear
    mkdir -v "$_SRC/deliantra"
	
	cd "$_SRC/deliantra"

	getFromSchmorpCVS maps deliantra/maps
	getFromSchmorpCVS arch deliantra/arch
	getFromSchmorpCVS server deliantra/server

    pwd
    cd server
	
	#Point $_SRC/deliantra/server/lib/arch to $_SRC/deliantra/arch
	#We will need this link later.
    ln -s "$_SRC/deliantra/arch" "$_SRC/deliantra/server/lib/arch"

	#autogen.sh is provided to do the autostuff, including run the ./configure script
	
	#Help ./configure find the Blitz++ library.
	export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig/"
	echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
	
	#Make sure make does not expect to find include/Makefile.in
	echo Removing references to include/Makefile.in:
	#xed Makefile.am
	sed 's/include\/Makefile.in//g' Makefile.am > Makefile.am.tmp
	mv -v Makefile.am.tmp Makefile.am
	#xed Makefile.am
	sleep_10

	./autogen.sh --prefix="$PREFIX"
	check_for_success $? "configuring deliantra-server"
	#initial compile, quit on failure.
    make
	check_for_success $? "making deliantra-server"
	
	#install everything, quit on failure
	make install
	check_for_success $? "installing deliantra-server"
	cd "$_SRC"
	ln -s "$_SRC/deliantra/server/maps" "$PREFIX/share/deliantra-server/maps"
	
	echo "CROSSFIRE_LIBDIR=$PREFIX/share/deliantra-server/ $PREFIX/bin/deliantra-server" > "$PREFIX/bin/startserver"
	chmod a+x "$PREFIX/bin/startServer"
	
	#celebrate because we are done!
}
#get, compile, and install the client.
function installClient()
{
	cd "$_SRC/deliantra"
	getFromSchmorpCVS client deliantra/Deliantra-Client
	cd client
	pwd
	perl Makefile.PL
	check_for_success $? "configuring deliantra-client"
	make
	check_for_success $? "making deliantra-client"
#	make check
#	check_for_success $? "checking deliantra-client"
	make test
	check_for_success $? "testing deliantra-client"
	make install
	check_for_success $? "installing deliantra-client"
	
}
#get, compile, and install the map editor.
function installEditor()
{
	cd "$_SRC/deliantra"
	getFromSchmorpCVS editor deliantra/gde
	cd editor
	
	perl Makefile.PL
	check_for_success $? "configuring editor"
	make
	check_for_success $? "making editor"
#	make check
#	check_for_success $? "checking editor"
	make test
	check_for_success $? "testing editor"
	make install
	check_for_success $? "installing editor"
	echo "DELIANTRA_LIBDIR=$PREFIX/share/deliantra $PREFIX/bin/gde" > "$PREFIX/bin/starteditor"
	chmod a+x "$PREFIX/bin/starteditor"
	
}

###########################################
#function getMissingM4Macros()
#{
#	wget --output-document=ax_cxx_compile_stdcxx_11.m4 http://git.savannah.gnu.org/gitweb/?p=autoconf-archive.git;a=blob_plain;f=m4/ax_cxx_compile_stdcxx_11.m4
#	find . | grep m4
#	wget --output-document=ax_cxx_compile_stdcxx.m4 http://git.savannah.gnu.org/gitweb/?p=autoconf-archive.git;a=blob_plain;f=m4/ax_cxx_compile_stdcxx.m4
#	find . | grep m4
#	
#}
#
#function getAndExtractBZ2Archive()
#{
#	echo
#	echo getAndExtractBZ2Archive "$@".
#	wget -q -O - "$1" | tar -xjv
#	if [ $? != 0 ]
#	then
#		echo Something went wrong when downloading or extracting archive "$@". >&2
#		exit 1
#	fi
#	sleep_10
#}
#	
#function install_cpanm()
#{
#	echo
#	echo install_cpanm "$@".
#	install cpanminus
#	# cpan App::cpanminus 
#	if [ $? != 0 ]
#	then
#	echo Something went wrong when installing cpanm. >&2
#		exit 1
#	fi
#	sleep_10
#}
#

time main