#!/bin/bash

#description: this script fix EasyConnect on linux
#author: du33169

installDir='/usr/share/sangfor/EasyConnect'
regInstallDir=$(echo $installDir|sed 's/\//\\\//g')	# replace '/' with '\/' for regular expression
shortcutFile='/usr/share/applications/EasyConnect.desktop'

colored_echo()# $1 for color, $2 for text
{
	case $1 in
		"yellow")	echo -e "\033[33m$2\033[0m"		;;
		"red")		echo -e "\033[31m$2\033[0m"		;;
		"blue")		echo -e "\033[34m$2\033[0m"		;;
		*)			echo "$2"						;;
	esac
}
check_result()#$1=$?, $2=failed_text $3=success_text,
{
	if test $1 -ne 0 ; then 
		colored_echo red "$2"
		return 0 #true
	else 
		echo "$3"
		return 1 #false
	fi
}
check_installation()
{
	if [ ! -d "${installDir}" ]; then 
		# file not exist
		colored_echo red "fatal: ${installDir} not found, check your EasyConnect installation. Exiting..."
		exit 1 
	else 
		echo "found ${installDir}."
	fi
}

check_patch()
{
	if [ -e "${installDir}/RunEasyConnect.sh" ]; then 
		#patch file already existed
		echo "patch file ${installDir}/RunEasyConnect.sh found. Patched."
		return 1
	else #file not exist
		echo "patch file ${installDir}/RunEasyConnect.sh not found. Not patched."
		return 0
	fi
}

askpass()# $1 for color, $2 for prompt
{
	sudo -K #delete cached password
	colored_echo "$1" "$2"
	echo "Enter your password for sudo:(not display on screen for safety concern)"
	read -s key
	echo "got your password."
}

dump_patch()# $1=key
{
	key=$1
	#make executale
	chmod +x ./patch/RunEasyConnect.sh
	# #create symbol link
	# for so in 'pango' 'pangocairo' 'pangoft' ; do
	# 	ln -s lib${so}-1.0.so.0.4200.3 lib${so}-1.0.so.0
	# done
	#copy file
	echo "copying file..."
	cp ./patch/RunEasyConnect.sh ./RunEasyConnect.sh.bak
	sed  -i "s/key=.*$/key=${key}/g" ./patch/RunEasyConnect.sh
	echo ${key}|sudo -S cp -R ./patch/* ${installDir}/ 2>/dev/null
	copyResult=$?
	mv ./RunEasyConnect.sh.bak ./patch/RunEasyConnect.sh
	if check_result $copyResult "fatal: copy file failed. Check your password and retry. Exiting..." "Copied." ; then
		exit 1
	fi

	
	#edit shortcut
	if [ ! -e "${shortcutFile}" ]; then
		# file not exist
		colored_echo red "fatal: ${shortcutFile} not found, check your installation."
		echo "Or you could just use ${installDir}/RunEasyConnect.sh. Exiting..."
		exit 1 
	else 
		echo "found shortcut file ${shortcutFile}, updating..."
		# modifying .desktop file
		echo ${key}|sudo -S sed  -i "s/Exec=.*$/Exec=${regInstallDir}\/RunEasyConnect.sh/g" $shortcutFile 2>/dev/null
		if check_result $? "fatal: modification failed. Check your password/installation and retry. Exiting..." "Edited."; then 
			exit 1
		fi
	fi
	return 0
}
remove_patch()# $1=key
{
	key=$1
	for file in `ls ./patch`; do
		echo ${key}|sudo -S rm ${installDir}/${file} 2>/dev/null
		if check_result $? "fatal: deleted failed. Check your password/installation and retry. Exiting..." "deleted ${file}"; then 
			exit 1
		fi
	done
	echo ${key}|sudo -S sed  -i "s/Exec=.*$/Exec=${regInstallDir}\/EasyConnect/g" $shortcutFile 2>/dev/null
	if check_result $? "fatal: edit failed. Check your password/installation and retry. Exiting..." "shortcut recovered."; then 
		exit 1
	fi
	return 0
}

# main process
if [[ -n "$1" && "$1" != "uninstall" ]] ; then 
	echo "unrecognized param $1, Exiting..."
	exit 1
fi
check_installation
check_patch
patched=$?
if [ -z "$1" ] ; then 
	if [ $patched == 1 ]; then # patched
		colored_echo yellow "warning: already patched. Will OVERRIDE."
	fi
	askpass yellow "warning: sudo password required. Will written into RunEasyConnect.sh in PLAINTEXT, Ctrl+C if unacceptable."
	dump_patch $key
	check_result $? "error ocurred during install process, Exiting..." "patch installed. Please run EasyConnect from launcher and enjoy."
	
elif [ "$1" = "uninstall" ] ; then
	if [ $patched == 0 ]; then # not patched
		colored_echo red "fatal: not patched. Nothing to uninstall, Exiting..."
	else
		askpass blue "notice: access required."
		remove_patch $key
		check_result $? "error ocurred during uninstall process, Exiting..." "patch uninstalled."
	fi
fi