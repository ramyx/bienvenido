#!/bin/bash

#mac='CC:61:E5:10:DF:1A'
#macmin='cc:61:e5:10:df:1a'
mac='08:EC:A9:23:22:60'
#macmin='08:ec:a9:23:22:60' #la mac puede estar con minuscula en arp
encontrado=false
sonar=true

while true ; do
    encontrado=false
    #limpiamos la cache de arp
    #sudo ip -s -s neigh flush all

    #este codigo se usaba para cachear la mac en arp pero no se usa mas, se conserva por si acaso
    # echo 'escaneando ips...'
    # nmap -sn 192.168.0.1-254/24 | egrep "scan report" | awk '{print $5}' > ipslist

    # echo 'haciendo conexion con ips encontradas...'
    # while read ip
    # do
    #     echo $ip
    #     ping -c 1 -t 1 "$ip" > /dev/null 2>&1
    # done <ipslist

    #obtenemos las ips con nmap (no siempre obtiene todas...)
    sudo nmap -sPn 192.168.1.1-254/24 | grep 'MAC Address' | awk '{print $3}' > macslist
    echo 'verificando si esta conectado...'
    while read m; do
        #Pregunta si es la mac del celu de 
        echo $m 
        if [ $m == $mac ]; then
            encontrado=true
            echo $m
            echo 'conectado jorge'
            if [ "$sonar" = true ];then
                #sudo ip -s -s neigh flush all
                if hash mplayer 2>/dev/null; then
                    mplayer jorge.flac
                else
                    play jorge.flac
                fi
                sonar=false
            fi
            sleep 10
        fi
        sleep 1
    done <macslist

    # echo 'obteniendo macs address..'
    # while true; do
    #     arp -a | grep ether | cut -d' ' -f4 | awk '{print toupper($0)}' > macslist
    #     if [ -s macslist ]; then
    #         break
    #     fi
    # done
    # cat macslist

    # echo 'verificando si esta conectado...'
    # while read m; do
    #     #Pregunta si es la mac del celu
    #     echo $m 
    #     if [ $m == $mac ] && [ "$encontrado" = false ]; then
    #         encontrado=true
    #         echo $m
    #         echo 'conectado jorge'
    #         if [ "$sonar" = true ];then
    #             if hash mplayer 2>/dev/null; then
    #                 mplayer jorge.flac
    #             else
    #                 play jorge.flac
    #             fi
    #             sonar=false
    #         fi
    #     fi
    #     sleep 1
    # done <macslist    

    if [ "$encontrado" = false ];then
         sonar=true
    fi

    #rm ipslist
    rm macslist
done