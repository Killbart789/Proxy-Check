#!/bin/bash

# PTC Options
PTC_UA="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.104 Safari/537.36"
PTC_URL="https://sso.pokemon.com/sso/login?service=https%3A%2F%2Fclub.pokemon.com%2Fus%2Fpokemon-trainer-club%2Fcaslogin"

# RPC Options
RPC_UA="User-Agent: Niantic App"
RPC_URL="https://pgorelease.nianticlabs.com/plfe/rpc"

# Colours
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

# Start
echo "Proxy Check"
echo "----------------\n"

# Read Proxies from stdin
while read line
do
    host=$(echo $line | cut -f1 -d:)
    port=$(echo $line | cut -f2 -d:)
    username=$(echo $line | cut -f3 -d:)
    password=$(echo $line | cut -f4 -d:)

    # PTC Check
    PTC_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -x "$host:$port" -U "$username:$password" -H "$PTC_UA" -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' "$PTC_URL" -m 15)

    # RPC Check
    RPC_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -x "$host:$port" -U "$username:$password" -X POST -H "$RPC_UA" -H 'Accept-Language: en-us' -H 'Content-Type: application/x-www-form-urlencoded' --data '' "$RPC_URL" -m 15)

    # Check proxy
    if echo "$PTC_CHECK" | grep -ioEq "200" && echo "$RPC_CHECK" | grep -ioEq "200"
    then 
        echo "${green}[OK]${reset} $host appears to be ok."
    elif echo "$PTC_CHECK" | grep -ioEq "000" && echo "$RPC_CHECK" | grep -ioEq "000"
    then
        echo "${yellow}[HANG]${reset} $host appears to be have timed out."
    else
        echo "${red}[FAIL]${reset} $host appears to be banned! PTC: [${yellow}$PTC_CHECK${reset}] RPC: [${yellow}$RPC_CHECK${reset}]"
    fi

done < "${1:-/dev/stdin}"
