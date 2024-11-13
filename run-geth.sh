#!/bin/bash

addresses=()
node_num=$1
enode_line=$2

while IFS= read -r line; do
    addresses+=("$line")
done < "node_address.txt"


run_geth_in_terminal() {
    local folder_name=$1
    local port=$2
    local enode_url=$3
    local network_id=$4
    local address=$5
    local authrpc_port=$6
    local http_port=$7

    echo $address
    # Define the command string
    local command="geth --datadir $folder_name \
        --port $port \
        --bootnodes $enode_url \
        --networkid $network_id \
        --unlock $address \
        --password password.txt \
        --authrpc.port $authrpc_port \
        --http \
        --http.port $http_port \
        --allow-insecure-unlock \
        --metrics \
        --metrics.influxdb \
        --metrics.expensive \
        --metrics.influxdb.endpoint 'http://0.0.0.0:8086' \
        --metrics.influxdb.username 'geth' \
        --metrics.influxdb.password 'choosepassword'"

    # If folder_name is "node1", add mining options
    if [[ "$folder_name" == "node1" ]]; then
        command="$command --mine --miner.etherbase $address"
    fi
    echo $command
    # Run the command in gnome-terminal
    gnome-terminal -- bash -c "$command; read -p 'Press Enter to exit'"
}


for((i=1;i<=node_num;i++))
do
    port=$((30306 + i))
    authrpc_port=$((8551 + i))
    http_port=$((8501 + i))

    run_geth_in_terminal "node$i" "$port" "$enode_line" "769599" "${addresses[i-1]}" "$authrpc_port" "$http_port"
done

