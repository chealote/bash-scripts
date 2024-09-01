#!/bin/bash

#rsync -aP --exclude-from=ignorelist /home/$USER/ ${REMOTE}:/home/$USER/

#for folder in $(cat includefrom); do
#	rsync --delete -aP --exclude-from=${ignorelist_filepath} $folder $REMOTE_FOLDER
#done

#echo "Check the commented command before running the script"
#exit 1

LOCAL_FOLDER="/home/$USER/"
ignorelist_filepath="ignorelist"
read -p "local or remote? (l/r): " option

case $option in
	l)
		tmpfile=$(mktemp)

		ls /mnt/ | grep mnt_ > $tmpfile
		cat -n $tmpfile
		read -p "Which path?: " option
		folder=$(sed -n "${option}p" "$tmpfile")

		REMOTE_FOLDER="/mnt/$folder/home/"
		if [ ! -d $REMOTE_FOLDER ]; then
			echo "Folder doesn't exists: $REMOTE_FOLDER"
			exit 1
		fi
		;;
	*)
		read -p "remote IP: " ip
		REMOTE_FOLDER="${ip}:/home/$USER/"
		;;
esac

command="rsync --delete -aP --exclude-from=${ignorelist_filepath} $LOCAL_FOLDER $REMOTE_FOLDER"
echo $command
read -p "run command? (y/n): " option
case $option in
	y)
		eval "${command}"
		;;
	*)
		echo Ok
		;;
esac
