#!/usr/bin/sh
installDir='/usr/share/sangfor/EasyConnect'
shortcutFile='/usr/share/applications/EasyConnect.desktop'


if [ ! -d "${installDir}" ]; then # check installation
	echo "fatal: ${installDir} not found, check your installation. Existing..."
	return 1 # file not exist
else 
	echo "found ${installDir}."
fi
if [ -e "${installDir}/RunEasyConnect.sh" ]; then # patch file already existed
	echo "warning: patch file ${installDir}/RunEasyConnect.sh found, already patched. Existing..."
	return 1 # file not exist
else 
	echo "patch file ${installDir}/RunEasyConnect.sh doesn't exist, not patched yet."
	# get user password
	echo "info: Permission required. "
	echo "Enter your password for sudo:"
	read key
	echo "copying file..."
	echo ${key}|sudo -S cp -R ./patch/* ${installDir}/
	
	if [ ! -e "${shortcutFile}" ]; then # check shortcut
        echo "fatal: ${shortcutFile} not found, check your installation."
        echo "Or you could just use ${installDir}/RunEasyConnect.sh. Existing..."
        return 1 # file not exist
    else 
        echo "found shortcut file ${shortcutFile}, updating..."
        # modifying .desktop file
        # replace '/' with '\/' for regular expression
        regInstallDir=$(echo $installDir|sed 's/\//\\\//g')
        echo ${key}|sudo -S sed  -i "s/${regInstallDir}\/EasyConnect --enable-transparent-visuals --disable-gpu/echo ${key}|sudo -S ${regInstallDir}\/RunEasyConnect.sh/g" $shortcutFile
    fi
fi

