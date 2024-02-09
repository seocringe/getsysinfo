#!/bin/sh

# Check if the executing user is "root"
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Create a directory for saving raw system data
sysinfo_dir="/tmp/getsysinfo"
mkdir -p "$sysinfo_dir"

# Collect system data
# Get information about the system's hardware in XML format and save to file lshw.xml
lshw -xml >"$sysinfo_dir/lshw.xml"

# Save CPU information in JSON format to file lscpu.json
lscpu --json >"$sysinfo_dir/lscpu.json"

# Output information about block devices in JSON format and save to file lsblk.json
lsblk -J >"$sysinfo_dir/lsblk.json"

# Save PCI bus information in CSV format to file lspci.csv
lspci -mm >"$sysinfo_dir/lspci.csv"

# Output the tree of connected USB devices and save it to file lsusb.txt
lsusb -t >"$sysinfo_dir/lsusb.txt"

# Save file system information, including size, used and available space,
# percentage used, and FS type to file df.txt
df --output=target,size,used,avail,pcent,fstype >"$sysinfo_dir/df.txt"

# Write memory status information, including free and buffered, to text file free.txt
free -blw >"$sysinfo_dir/free.txt"

# Find bash and zsh command history in home directories, output filename, content, and write this to shell_history.txt,
# ignoring access errors
find /home -name .bash_history -o -name .zsh_history -exec sh -c 'echo "{}:"; cat {}' \; 2>/dev/null >"$sysinfo_dir/shell_history.txt"

# Processing dmidecode data and converting to JSON
dmidecode_file="$sysinfo_dir/dmidecode.txt"
json_output="$sysinfo_dir/dmidecode.json"

# Run the dmidecode command
dmidecode >"$dmidecode_file"

# Generate a JSON document based on the dmidecode file
echo "{" >"$json_output"
first_handle=1
last_line_was_handle=0
while IFS= read -r line; do
    # Escape backslashes in the line string
    line=$(echo "$line" | sed 's/\\/\\\\/g')
    
    # Handle lines beginning with "Handle"
    if [[ $line == Handle* ]]; then
        # Close the previous handle JSON object if it's not the first one
        if [[ $first_handle -eq 0 ]]; then
            echo "}," >>"$json_output"
        else
            first_handle=0
        fi
        
        # Begin a new handle JSON object
        handle=${line#Handle }
        handle=${handle%%,*}
        echo -n "\"$handle\": {" >>"$json_output"
        last_line_was_handle=1
    elif [[ $line == *:* ]]; then
        # Add comma before next key-value pair if this is not the first pair in the object
        if [[ $last_line_was_handle -eq 0 ]]; then
            echo -n "," >>"$json_output"
        else
            last_line_was_handle=0
        fi
        
        # Parse and format key-value pair for JSON
        key=${line%%:*}
        value=${line#*: }
        
        # Remove leading and trailing whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # Escape double quotes inside the value
        value=${value//\"/\\\"} 

        # The sed command used to replace colons can be removed as they are valid inside strings
        echo -n "\"$key\": \"$value\"" >>"$json_output"
    fi
done <"$dmidecode_file"
   # Correctly close the final JSON object and root JSON object at the end of processing
   echo "}}" >>"$json_output"

   # Combine all files into a single JSON document
{
    echo '{'
    echo '"lshw":' && xml2json < "$sysinfo_dir/lshw.xml" | jq -c .
    echo ',"lscpu":' && jq -c . < "$sysinfo_dir/lscpu.json"
    echo ',"lsblk":' && jq -c . < "$sysinfo_dir/lsblk.json"
    echo ',"lspci":' && csvjson < "$sysinfo_dir/lspci.csv" | jq -c .
    echo ',"df":' && awk 'NR>1 {print "{\"target\":\""$1"\", \"size\":\""$2"\", \"used\":\""$3"\", \"available\":\""$4"\", \"used_percent\":\""$5"\", \"filesystem_type\":\""$6"\"}"}' "$sysinfo_dir/df.txt" | jq -s -c .
    echo ',"free":' && awk 'NR>1 {print "{\"type\":\""$1"\", \"total\":\""$2"\", \"used\":\""$3"\", \"free\":\""$4"\", \"shared\":\""$5"\", \"buff_cache\":\""$6"\", \"available\":\""$7"\"}"}' "$sysinfo_dir/free.txt" | jq -s -c .
    echo ',"shell_history":' && jq -R -s -c 'split("\n") | map(select(length > 0))' < "$sysinfo_dir/shell_history.txt"
    echo ',"dmidecode":' && cat "$json_output"
    echo '}'
} >"$sysinfo_dir/combined.json"
   # Copy the combined JSON to a specific location with a timestamped name
   output_name="sysinfo_$(date +%Y-%m-%d_%H-%M-%S).json"
   destination="/home/ars/documents/arsh/$output_name"
   mv "$sysinfo_dir/combined.json" "$destination"

   echo "System data written to: $destination"

   # Clean up temporary files
   rm -rf "$sysinfo_dir"

   # If you need to keep the sysinfo directory for some reason and just remove its contents use:
   # find "$sysinfo_dir" -mindepth 1 -delete

   exit 0