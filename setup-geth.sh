#!/bin/bash

addresses=()
node_num=$1
create_new_account() {
    local folder_name="$1"
    output=$(geth --datadir "$folder_name" account new << EOF
123
123
EOF
)
    echo "New account created in $folder_name."

    address=$(echo "$output" | grep -oE '0x[[:xdigit:]]{40}')
    addresses+=("$address")
    echo "$address" >> "node_address.txt"
}

echo "123" > password.txt

echo "================================================"
echo "0. Deleting previous node directories"
for ((i=1; i<=node_num; i++))
do
    rm -rf "node$i"
done



echo "1. Creating 24 node directories and adding keystore"

for ((i=1; i<=node_num; i++))
do
    directory="node$i"
    keystore_path="$directory/keystore"

    mkdir -p "$directory"
    echo "Directory $i created."
    create_new_account "$directory"

done

echo "2. Setting up genesis file"
{
    head -n "21" "bak.genesis.json"
    for address in "${addresses[@]}"; do
        address="${address#0x}"
        echo "        \"$address\" : {\"balance\":\"10000000000000000000000000000000\"},"
    done
    tail -n +"$((22 + 1))" "bak.genesis.json"
} > temp.txt && mv temp.txt "genesis.json"

new_value="0x0000000000000000000000000000000000000000000000000000000000000000${addresses[0]#0x}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
sed -i "s/\"extradata\": \"[^\"]*\"/\"extradata\": \"$new_value\"/" "genesis.json"

for((i=1;i<=node_num;i++))
do
    geth --datadir "node$i" init "genesis.json"
done

echo "3. Initializing boot node"
bootnode -genkey boot.key
sleep 2
bootnode -nodekey boot.key -addr :30305
