#!/bin/bash

#inicio de variables
encontrado=false
sonar=true
ciclo=0

#verifica que haya una mac y archivo de sonido en el archivo
echo "Verificando archivo de configuracion..."
touch conf
while true; do
    mac="$(more conf | cut -d' ' -f1)"
    sonido="$(more conf | cut -d' ' -f2)"
    if [ ! -z "$mac" ] && [ ! -z "$sonido" ]; then
        break
    else
        echo "coloque el nro de mac en el archivo macaddress y el archivo de sonido"
        echo "forma: "
        echo "06:EC:C9:23:24:60 saludo.flac"
        sleep 20
    fi
done
more conf

#para iterar si hay mas de una mas y sonido
#for i in "${macs[@]}"; do echo "$i"; done

#Determinando el gateway para definir el rango
echo "Detectando gateway..."
Gateway="$(ip route | awk '/default/ { print $3 }')"
Sub="-254/24"
Range=$Gateway$Sub
echo $Gateway
while true ; do

    echo "ciclo: " $ciclo
    if [ $ciclo -ne 1000 ] && [ ! -z "$ip" ]; then
        echo "ping "$ip
        ping -c2 -i 0.4 $ip &> /dev/null
        if [ $? -eq 0 ]; then
            echo 'conectado'
            encontrado=true
            #esto es para que suene solo una ves cuando se conecta
            if [ "$sonar" = true ];then
                if hash mplayer 2>/dev/null; then
                    mplayer $sonido
                else
                    play $sonido
                fi
                sonar=false
            fi
            sleep 10
        else
            echo 'desconectado'
            encontrado=false
        fi
        ((ciclo++))
    #si no se detecto la ip de la mac o si ya pasaron 1000 pruebas con la ip y verifica que no cambio
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
                        mplayer $sonido
                    else
                        play $sonido
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