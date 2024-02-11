#!/bin/bash

# Function to convert xml to json using xml2json and jq
xml_to_json() {
  local xml_file="$1"
  xml2json < "$xml_file" | jq -c .
}

# Function to convert csv to json using csvjson and jq
csv_to_json() {
  local csv_file="$1"
  csvjson < "$csv_file" | jq -c .
}

# Function to format df output to json
df_to_json() {
  awk 'NR>1 {print "{\"target\":\""$1"\", \"size\":\""$2"\", \"used\":\""$3"\", \"available\":\""$4"\", \"used_percent\":\""$5"\", \"filesystem_type\":\""$6"\"}"}' "$1" | jq -s -c .
}

# Function to format free output to json
free_to_json() {
  awk 'NR>1 {print "{\"type\":\""$1"\", \"total\":\""$2"\", \"used\":\""$3"\", \"free\":\""$4"\", \"shared\":\""$5"\", \"buff_cache\":\""$6"\", \"available\":\""$7"\"}"}' "$1" | jq -s -c .
}

sysinfo_dir="/path/to/sysinfo_dir"
json_output="$sysinfo_dir/dmidecode.json"
output_name="sysinfo_$(date +%Y-%m-%d_%H-%M-%S).json"
destination="/home/ars/documents/arsh/$output_name"

# Create sysinfo_dir if it doesn't exist
mkdir -p "$sysinfo_dir"

# Combine all files into a single JSON document
cat <<EOF > "$sysinfo_dir/combined.json"
{
  "lshw": $(xml_to_json "$sysinfo_dir/lshw.xml"),
  "lscpu": $(jq -c . < "$sysinfo_dir/lscpu.json"),
  "lsblk": $(jq -c . < "$sysinfo_dir/lsblk.json"),
  "lspci": $(csv_to_json "$sysinfo_dir/lspci.csv"),
  "df": $(df_to_json "$sysinfo_dir/df.txt"),
  "free": $(free_to_json "$sysinfo_dir/free.txt"),
  "shell_history": $(jq -R -s -c 'split("\n") | map(select(length > 0))' < "$sysinfo_dir/shell_history.txt"),
  "dmidecode": $(cat "$json_output")
}
EOF

# Copy the combined JSON to a specific location with a timestamped name
cp "$sysinfo_dir/combined.json" "$destination"

echo "System data written to: $destination"

# Clean up temporary files
rm -rf "$sysinfo_dir"

exit 0