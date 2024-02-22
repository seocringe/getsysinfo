# Check if the executing user is "root"
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Get the directory of the current script
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)

# Define and call getsysinfo function
getsysinfo() {
  if [[ $1 == "update" ]]; then
    # Use the SCRIPT_DIR to construct the relative path
    local update_script="$SCRIPT_DIR/update_getsysinfo.sh"
    if [[ -x "${update_script}" ]]; then
      "${update_script}"
    else
      echo "Update script is not executable or found"
      exit 1
    fi
  else
    # Here you can add the main code of getsysinfo if needed, or leave it as just an update function
    echo "Usage: getsysinfo update"
    return 1
  fi
}

# If the first argument is 'update' then just run the update process
if [[ $1 == "update" ]]; then
    getsysinfo update
    exit $?
fi

sysinfo_dir="/tmp/getsysinfo"
mkdir -p "$sysinfo_dir"

# Collect system data in a more compact way
{
    lshw -xml >"$sysinfo_dir/lshw.xml"
    lscpu --json >"$sysinfo_dir/lscpu.json"
    lsblk -J >"$sysinfo_dir/lsblk.json"
    lspci -mm >"$sysinfo_dir/lspci.csv"
    lsusb -t >"$sysinfo_dir/lsusb.txt"
    df --output=target,size,used,avail,pcent,fstype >"$sysinfo_dir/df.txt"
    free -blw >"$sysinfo_dir/free.txt"
} &  # Run this block in a subshell in the background to collect data concurrently

# Enhanced find command without invoking multiple shells
find /home \( -name .bash_history -o -name .zsh_history \) \
    -exec echo '{}:' \; -exec cat '{}' + 2>/dev/null >"$sysinfo_dir/shell_history.txt" &

dmidecode_file="$sysinfo_dir/dmidecode.txt"
json_output="$sysinfo_dir/dmidecode.json"

# Optimize dmidecode processing
dmidecode >"$dmidecode_file"
awk '/Handle /{if (!first) printf "},\n"; first=0; gsub(",", "", $2); print "\"" $2 "\": {"; next}
     /^[[:space:]]*[^[:space:]]+:/{
         gsub(/"/, "\\\"", $2);
         printf "\"%s\": \"%s\"", substr($1, 1, length($1)-1), substr($2, 3);
         getline;
         if ($0 != "") {print ","}
     }' "$dmidecode_file" | sed '1s/^/{/' | sed '$s/$/\n}\n}/' >"$json_output" &

wait  # Wait for all background processes to complete

# Combine all files into a single JSON document
jq -n --slurpfile lshw "$sysinfo_dir/lshw.xml" \
          --slurpfile lscpu "$sysinfo_dir/lscpu.json" \
          --slurpfile lsblk "$sysinfo_dir/lsblk.json" \
          --slurpfile lspci "$sysinfo_dir/lspci.csv" \
          --slurpfile df "$sysinfo_dir/df.txt" \
          --slurpfile free "$sysinfo_dir/free.txt" \
          --slurpfile history "$sysinfo_dir/shell_history.txt" \
          --slurpfile dmidecode "$json_output" '
{
    lshw: $lshw[0] | fromjson,
    lscpu: $lscpu[0],
    lsblk: $lsblk[0],
    lspci: ($lspci[0] | fromcsv | map({(.[0]): .[1]})),
    df: [ $df[0][] | {target: .[0], size: .[1], used: .[2], available: .[3], used_percent: .[4], filesystem_type: .[5]} ],
    free: [ $free[0][] | {type: .[0], total: .[1], used: .[2], free: .[3], shared: .[4], buff_cache: .[5], available: .[6]} ],
    shell_history: ($history[0] | split("\n") | map(select(length > 0))),
    dmidecode: ($dmidecode[0] | fromjson)
}' >"$sysinfo_dir/combined.json"

# Move the combined JSON file to the final destination
output_name="sysinfo_$(date +%Y-%m-%d_%H-%M-%S).json"
destination="/home/ars/documents/arsh/$output_name"
mv "$sysinfo_dir/combined.json" "$destination"

echo "System data written to: $destination"

# Clean up temporary files
rm -rf "$sysinfo_dir"
exit 0