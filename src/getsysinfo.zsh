#!/bin/zsh
[[ $(id -u) != 0 ]]&&{ echo "This operation requires superuser privileges.";sudo -v||{ echo "Superuser verification failed.";exit 1;};}
d="$HOME/tmp/.ags";a="/home/ars/archives/";r="/home/ars/documents/arsh"
collect_system_data(){ sudo sh -c "mkdir -p '$d'&&chmod 755 '$d'&&lshw -xml >'$d/lshw.xml'&&lscpu --json >'$d/lscpu.json'&&lsblk -J >'$d/lsblk.json'&&lspci -mm >'$d/lspci.csv'&&lsusb -t >'$d/lsusb.txt'&&df --output=target,size,used,avail,pcent,fstype >'$d/df.txt'&&free -blw >'$d/free.txt'&&find /home \( -name .bash_history -o -name .zsh_history \) -exec sh -c 'echo \"{}:\"; cat {}' \; 2>/dev/null >'$d/shell_history.txt'&&dmidecode >'$d/dmidecode.txt'";}
create_json_files(){ f="$d/dmidecode.txt";j="$d/dmidecode.json";h="";p=0;while IFS= read -r l; do [[ $l == Handle* ]]&&{ [[ $p -eq 0 ]]&&echo "},";h=${l#Handle };h=${h%%,*};echo "\"$h\":{";p=1;}||[[ $l == *:* && $p -eq 0 ]]&&echo ",";[[ $l == *:* ]]&&{ k=${l%%:*};v=${l#*: };v=${v//\"/\\\"};printf "\"%s\":\"%s\"" "${k// /}" "$v";p=0;};done <"$f"|sed 's/,{'/'{'/g' >"$j";echo "}" >>"$j";}
generate_combined_json(){ sudo sh -c "cat <<EOF >'$d/combined.json'{\"lshw\":\$(cat '$d/lshw.xml'|xml2json|jq -c .),\"dmidecode\":\$(cat '$j')}EOF";}
collect_system_data
[[ -f "$d/dmidecode.txt" ]]&&create_json_files||echo "dmidecode.txt does not exist, skipping dmidecode JSON conversion."
generate_combined_json
t=$(date +%Y-%m-%d_%H-%M-%S);o="sysinfo_$t.json";sudo sh -c "mkdir -p '$r'&&mv '$d/combined.json' '$r/$o'&&echo 'System data written to: $r/$o'||{ echo 'Failed to move combined JSON to $r/$o.';exit 1;};mkdir -p '$a'&&tar -czf '$a/sysinfo_archive_$t.tar.gz' -C '$d' .&&echo 'Данные системы заархивированы в: $a/sysinfo_archive_$t.tar.gz'&&rm -rf '$d';"
