#!/bin/bash

# set -x


regexV4="(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}"
regexV6="(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"

VERSION="null"
ONES="null"
ZEROES="null"
LENGTH="null"


# Colors for output
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_CYAN='\033[0;36m'
COLOR_NC='\033[0m' # No Color

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Function to convert IPv4 address to binary
ipv4_to_bin() {
    local in="$1"
    local length="8"

    touch .tmp

    IFS="."

    read -r -a octets <<< "$in"

    for part in "${octets[@]}"; do
        printf "%08d" "$(echo "$(bc <<< "obase=2;$part")")" >> .tmp
    done

    IP_BIN="$(cat .tmp)"

    rm .tmp
}

# Function to convert hexadecimal digit to binary
hex_to_binary() {
    case $1 in
        0) echo -n "0000" ;;
        1) echo -n "0001" ;;
        2) echo -n "0010" ;;
        3) echo -n "0011" ;;
        4) echo -n "0100" ;;
        5) echo -n "0101" ;;
        6) echo -n "0110" ;;
        7) echo -n "0111" ;;
        8) echo -n "1000" ;;
        9) echo -n "1001" ;;
        a|A) echo -n "1010" ;;
        b|B) echo -n "1011" ;;
        c|C) echo -n "1100" ;;
        d|D) echo -n "1101" ;;
        e|E) echo -n "1110" ;;
        f|F) echo -n "1111" ;;
        *) echo -n "" ;;
    esac
}

# Function to convert binary to hexadecimal digit
binary_to_hex() {
    case $1 in
        "0000") echo -n "0" ;;
        "0001") echo -n "1" ;;
        "0010") echo -n "2" ;;
        "0011") echo -n "3" ;;
        "0100") echo -n "4" ;;
        "0101") echo -n "5" ;;
        "0110") echo -n "6" ;;
        "0111") echo -n "7" ;;
        "1000") echo -n "8" ;;
        "1001") echo -n "9" ;;
        "1010") echo -n "a" ;;
        "1011") echo -n "b" ;;
        "1100") echo -n "c" ;;
        "1101") echo -n "d" ;;
        "1110") echo -n "e" ;;
        "1111") echo -n "f" ;;
        *) echo -n "" ;;
    esac
}

# Function to convert IPv6 address to binary
ipv6_to_binary() {
    local address=$1
    local binary=""
    local block
    local i

    # Splitting the IPv6 address into 8 blocks
    IFS=':' read -ra blocks <<< "$address"

    # Converting each block to binary and appending to the result
    for block in "${blocks[@]}"; do
        # Prepending zeros to ensure each block is 4 hexadecimal digits long
        block=$(printf "%04s" "$block")

        # Converting each hexadecimal digit to binary
        for ((i = 0; i < ${#block}; i++)); do
            binary="$binary$(hex_to_binary "${block:i:1}")"
        done
    done

    IP_BIN="$binary"
}

# Function to convert binary IPv6 address to hexadecimal
binary_ipv6_to_hex() {
    local binary_address=$1
    local hex_address=""
    local i=0
    local c=0

    # Dividing binary address into 16 blocks (4 bits each)
    while [ $i -lt ${#binary_address} ]; do
        # Extracting each 4-bit block
        block=${binary_address:$i:4}
        # Converting the block to hexadecimal
        hex_block=$(binary_to_hex "$block")
        hex_address="$hex_address$hex_block"
        i=$((i+4))
        c=$((c+1))

        if (( c % 4 == 0 )); then
            hex_address="$hex_address:"
        fi
    done

    if [ "${hex_address: -1}" == ":" ]; then
        hex_address="${hex_address%?}"  # Remove the last character
    fi

    IP_HEX_OUT="$hex_address"
}

# Function to compute NetIP in binary
get_ipv6_netip() {
    main_string="$1"
    other_string="$2"

    if [ ${#main_string} -ne ${#other_string} ]; then
        echo "Error: Strings must be of equal length"
        exit 1
    fi

    touch .tmp

    for (( i=0; i<${#main_string}; i++ )); do
        if [ "${main_string:$i:1}" -eq 1 ]; then
            printf "%s" "${other_string:$i:1}" >> .tmp
        else
            printf "0" >> .tmp
        fi
    done

    echo -e "Your NetIP in Binary: \t $(cat .tmp)"

    binary_ipv6_to_hex "$(cat .tmp)"

    rm .tmp
}

# Function to expand compressed IPv6 address
expand_ipv6() {
    local ip=$1
    local expanded_ip=""
    local count_colons=$(echo "$ip" | grep -o ":" | wc -l)
    local missing_blocks=$(( 9 - count_colons ))

    if [[ $missing_blocks -gt 0 ]]; then
        local padding=""
        for ((i=1; i<$missing_blocks; i++)); do
            padding+=":0000"
        done
        expanded_ip=$(echo "$ip" | sed "s/::/$padding:/")
    else
        expanded_ip=$(echo "$ip" | sed 's/::/:0000:/')
    fi

    echo "$expanded_ip"
}

# Function to fill IPv6 blocks with leading zeros
fill_ipv6() {
    local ipv6="$1"

    IFS=':' read -r -a parts <<< "$ipv6"

    for ((i=0; i<${#parts[@]}; i++)); do
        # Add leading zeros to make the length 4 characters
        parts[$i]=$(printf "%04s" ${parts[$i]})
    done

    # Join the parts back together with ":" separator
    ipv6=$(IFS=':'; echo "${parts[*]}")

    # Return the padded IPv6 address
    echo "$ipv6" | sed 's/ /0/g'
}

# Function to calculate host count based on IPv4 or IPv6 and CIDR
get_host_count() {
    if [[ "$1" = "v4" ]]; then
        MAX_CIDR="32"
    elif [[ "$1" = "v6" ]]; then
        MAX_CIDR="128"
    fi

    let HOST_COUNT="$MAX_CIDR - $INPUT_CIDR"
    HOST_COUNT="2^$HOST_COUNT"
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Main script
echo -e "${COLOR_GREEN}Subnet Calc, please enter your IPv4 or IPv6 address:${COLOR_NC}"
read -p "$ " INPUT

# Validate whether the input is IPv4 or IPv6
if [[ $INPUT =~ $regexV4 ]]; then
    echo -e "${COLOR_GREEN}Valid IPv4${COLOR_NC}"
    VERSION="4"
elif [[ $INPUT =~ $regexV6 ]]; then
    echo -e "${COLOR_GREEN}Valid IPv6${COLOR_NC}"
    VERSION="6"
else
    echo -e "${COLOR_RED}Invalid IP${COLOR_NC}"
    exit 1
fi

echo
echo -e "${COLOR_CYAN}Please enter your subnet in CIDR Notation${COLOR_NC}"

read -p "$ " INPUT_CIDR

# Extract CIDR notation from user input
INPUT_CIDR="$(echo "$INPUT_CIDR" | cut -d '/' -f2-)"

# Process IPv4 or IPv6 input based on version and CIDR notation
if [[ $VERSION -eq "4" ]] && [[ $INPUT_CIDR -gt 0 ]] && [[ $INPUT_CIDR -lt 32 ]]; then
    echo -e "${COLOR_GREEN}Valid IPv4 CIDR${COLOR_NC}"
    LENGTH=32
    ONES=$INPUT_CIDR
    ZEROES=$((LENGTH - ONES))
    STRING=$(printf '1%.0s' $(seq 1 $ONES) && printf '0%.0s' $(seq 1 $ZEROES))
    get_host_count "$v4"
    ipv4_to_bin "$INPUT"

elif [[ $VERSION -eq "6" ]] && [[ $INPUT_CIDR -gt 0 ]] && [[ $INPUT_CIDR -lt 128 ]]; then
    INPUT="$(expand_ipv6 $INPUT)"
    INPUT="$(fill_ipv6 $INPUT)"
    echo -e "${COLOR_GREEN}Valid IPv6 CIDR${COLOR_NC}"
    LENGTH=128
    ONES=$INPUT_CIDR
    ZEROES=$((LENGTH - ONES))
    STRING=$(printf '1%.0s' $(seq 1 $ONES) && printf '0%.0s' $(seq 1 $ZEROES))
    get_host_count "v6"
    ipv6_to_binary "$INPUT"

else
    echo -e "${COLOR_RED}Invalid CIDR${COLOR_NC}"
    exit 1
fi

# Output results
echo
echo -e "${COLOR_YELLOW}Your CIDR: /$INPUT_CIDR${COLOR_NC}"
echo -e "${COLOR_YELLOW}Your CIDR in Binary : \t $STRING${COLOR_NC}"
echo -e "${COLOR_YELLOW}Your IP in Binary   : \t $IP_BIN${COLOR_NC}"
echo

get_ipv6_netip $STRING $IP_BIN

echo -e "${COLOR_YELLOW}Your NetIP          : \t $IP_HEX_OUT${COLOR}"
