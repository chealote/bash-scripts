#!/bin/bash

wait_seconds="60"
ignorelist_filepath="$HOME/ignorelist"
local_folder="$HOME/"
remote_folder="$local_folder"
valid_ip_regex="192\.168\.0\.[0-9]{2}"

# can be a list of ips separated by space
known_ips=""

function build_send_files_cmd {
	ip="$1"
	command="rsync --delete -aP \
		--exclude-from=\"${ignorelist_filepath}\" \
		\"${local_folder}\" \
		\"${ip}:${remote_folder}\""
	echo $command
}

# arg1: remote IP
# arg2: seconds to wait before running the cmd
function send_files {
	command=$(build_send_files_cmd "$1")
	wait_seconds="$2"
	echo "Running this command in ${wait_seconds} seconds"
	echo "$command"
	sleep $wait_seconds

	eval "$command"
}

function get_remote_ips {
	local_ip=$(ip r | grep -Eo $valid_ip_regex | head -n 1)
	remote_ips=""
	for ip in $known_ips; do
		if [ "$ip" = "$local_ip" ]; then
			continue
		fi
		remote_ips="$remote_ips $ip"
	done
	echo $remote_ips
}

function send_file_once {
	commands=""
	remote_ips=$(get_remote_ips)
	for ip in $remote_ips; do
		command=$(build_send_files_cmd "$ip")
		echo "Command: $command"
		commands="$commands;$command"
	done

	read -p "Run those commands? (y/n) " option
	if [ "$option" = "y" ]; then
		IFS=";"
		for command in $commands; do
			echo "Running: $command"
			eval "$command"
		done
	fi
	exit
}

function simple_valid_ip {
	ip="$1"
	match=$(echo "$ip" | grep -Eo $valid_ip_regex | head -n 1 | wc -l)
	if [ $match -gt 0 ]; then
		echo 0
	else
		echo 1
	fi
}

if [ "$known_ips" = "" ]; then
	read -p "local IPs, separated by space: " known_ips
fi

for ip in $known_ips; do
	valid=$(simple_valid_ip "$ip")
	if [ $valid -eq 0 ]; then
		if [ "$1" = "-o" ]; then
			send_file_once
		fi
		send_files "$ip" "$wait_seconds"
	else
		echo "${ip}: not a valid IP for regex: ${valid_ip_regex}"
	fi
done

# if [ "$1" = "-o" ]; then
# 	send_file_once
# fi
# 
# remote_ips=$(get_remote_ips)
# while true; do
# 	for ip in $remote_ips; do
# 		
# 	done
# done
