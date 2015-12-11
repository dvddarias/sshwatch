#!/bin/bash
name="sshwatch"
shot_desc="SSH config swapper."
desc="A daemon to swap the ~/.ssh/config file in correspondence with the network profile."

user="$(whoami)" #the user name that will run the script
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #get the bash script directory

script_path="$dir/$name"
run_path="/usr/local/bin/$name"
daemon_pwd="/usr/local/bin"
opts="none"

if [[ $# -eq 1 && "$1" = "-u" ]]; then
	sudo systemctl stop "$name"
	sudo rm "/etc/systemd/${name}.service"
	sudo rm "${run_path}/${name}"
	exit
fi

service="[Unit]
Description=$desc
After=syslog.target
After=network.target

[Service]
Type=simple
User=$user
WorkingDirectory=$daemon_pwd
ExecStart=${run_path} $opts
Restart=always

[Install]
WantedBy=multi-user.target
"

printf "$service" > "/tmp/${name}.service"

#copy the executable to local/bin
sudo cp "$script_path" "${run_path}"
sudo chmod +x "${run_path}"

#install the systemd service
sudo mv "/tmp/${name}.service" "/etc/systemd/${name}.service"
sudo systemctl start "$name"
