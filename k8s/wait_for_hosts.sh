# List of hosts to check
hosts=("10.0.0.210" "10.0.0.220" "10.0.0.221")

# Function to check if a host is online
check_host() {
  local host=$1
  while true; do
    if ping -c 1 "$host" &> /dev/null; then
      echo "$host is online"
      break
    else
      echo "Waiting for $host to come online..."
      sleep 5
    fi
  done
}

# Loop through each host and check if it's online
for host in "${hosts[@]}"; do
  check_host "$host"
done

echo "All hosts are online."