#!/bin/bash

#mac='08:EC:A9:23:22:60'
mac="$(cat macaddress)"
encontrado=false
sonar=true
ciclo=0

#Determinando el gateway para definir el rango
Gateway="$(ip route | awk '/default/ { print $3 }')"
Sub="-254/24"
Range=$Gateway$Sub
while true ; do

    echo "ciclo: " $ciclo
    if [ $ciclo -ne 100 ] && [ ! -z "$ip" ]; then
        echo $ip
        ping -c2 -i 0.4 $ip &> /dev/null
        if [ $? -eq 0 ]; then
            echo 'conectado'
            encontrado=true
            #esto es para que suene solo una ves cuando se conecta
            if [ "$sonar" = true ];then
                if hash mplayer 2>/dev/null; then
                    mplayer jorge.flac
                else
                    play jorge.flac
                fi
                sonar=false
            fi
            sleep 10
        else
            echo 'desconectado'
            encontrado=false
        fi
        ((ciclo++))
    #si no se detecto la ip de la mac o si ya pasaron 100 pruebas con la ip y verifica que no cambio
    else
        ciclo=0
        #obtenemos los datos con nmap, no siempre obtiene todas las conexiones...
        echo 'Obteniendo informacion de la red'
        sudo nmap -sPn $Range > listnmap
        cat listnmap
        echo 'Generando la lista de macs'
        cat listnmap | grep 'MAC Address' | awk '{print $3}' > macslist
        echo 'verificando si esta conectado...'
        while read m; do
            #Pregunta si es la mac del celu de 
            echo $m 
            if [ $m == $mac ]; then
                encontrado=true
                echo 'conectado jorge'
                #guardamos la ip , puede cambiar
                ip="$(cat listnmap | grep -B2 $mac | grep scan | awk '{print $5}')" 
                echo $ip
                #esto es para que suene solo una ves cuando se conecta
                if [ "$sonar" = true ];then
                    if hash mplayer 2>/dev/null; then
                        mplayer jorge.flac
                    else
                        play jorge.flac
                    fi
                    sonar=false
                    sleep 5
                fi
            fi
        done <macslist 
        rm macslist
    fi
    if [ "$encontrado" = false ];then
        sonar=true
    fi
done