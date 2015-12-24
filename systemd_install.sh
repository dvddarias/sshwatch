#!/bin/bash
#---------------------------------EDIT HERE-----------------------------------------
name="sshwatch"
shot_desc="SSH config swapper."
desc="A daemon to swap the ~/.ssh/config file in correspondence with the network profile."

user="$(whoami)" #the user name that will run the script
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #get the bash script directory
script_path="$dir/$name"
#Uncomment this line to set the path of a configuration file
#script_config="$dir/config.json"

daemon_pwd="/usr/local/bin"
daemon_path="/usr/local/bin/$name"
daemon_config="/etc/$name"
daemon_opts=" "
#-----------------END OF EDIT UNLESS YOU KNOW WHAT YOU ARE DOING--------------------

if [[ $# -eq 1 && "$1" = "-u" ]]; then
    sudo systemctl stop "${name}.service"
    sudo systemctl disable "${name}.service"
    sudo rm "$daemon_path"
    sudo rm -rf "$daemon_config"
    sudo rm "/etc/systemd/system/${name}.service"
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
ExecStart=$daemon_path $daemon_opts
Restart=always

[Install]
WantedBy=multi-user.target
"

printf "$service" > "/tmp/${name}.service"

#copy the executable to local/bin
sudo cp "$script_path" "$daemon_path"
sudo chmod +x "$daemon_path"

#copy the configuration if it is declared
sudo mkdir -p "$daemon_config"
if [[ -n "${script_config}" ]]; then
    sudo cp "$script_config" "$daemon_config/${name}.config"
fi

#install the systemd service
sudo mv "/tmp/${name}.service" "/etc/systemd/system/${name}.service"
sudo systemctl enable "${name}.service"
sudo systemctl start "${name}.service"