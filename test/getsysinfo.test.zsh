#!/bin/zsh

# Test prerequisites
test_prerequisites() {
  echo "Testing prerequisites..."
  local commands=(lshw lscpu lsblk lspci lsusb df free find dmidecode xml2json jq tar)
  for cmd in "${commands[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "Command $cmd not found."; return 1; }
  done
  echo "All required commands are available."
}

# Define collect_system_data function here
collect_system_data() {
  # Placeholder for collect_system_data implementation
  :
}

# Define create_json_files function here
create_json_files() {
  # Placeholder for create_json_files implementation
  :
}

# Define generate_combined_json function here
generate_combined_json() {
  # Placeholder for generate_combined_json implementation
  :
}

# Test collect_system_data function
test_collect_system_data() {
  echo "Testing collect_system_data..."
  collect_system_data
  local files=(lshw.xml lscpu.json lsblk.json lspci.csv lsusb.txt df.txt free.txt shell_history.txt dmidecode.txt)
  for file in "${files[@]}"; do
    [[ ! -f "$d/$file" ]] && { echo "File $d/$file not found."; return 1; }
  done
  echo "collect_system_data passed."
}

# Test create_json_files function
test_create_json_files() {
  echo "Testing create_json_files..."
  create_json_files
  [[ ! -f "$d/dmidecode.json" ]] && { echo "dmidecode.json not created."; return 1; }
  echo "create_json_files passed."
}

# Test generate_combined_json function
test_generate_combined_json() {
  echo "Testing generate_combined_json..."
  generate_combined_json
  [[ ! -f "$d/combined.json" ]] && { echo "combined.json not created."; return 1; }
  echo "generate_combined_json passed."
}

# Test archive creation and cleanup
test_archive_and_cleanup() {
  echo "Testing archive creation and cleanup..."
  t=$(date +%Y-%m-%d_%H-%M-%S)
  o="sysinfo_$t.json"
  mkdir -p "$r" && mv "$d/combined.json" "$r/$o" && echo "System data written to: $r/$o"
  if [[ $? -ne 0 ]]; then
    echo "Failed to move combined JSON to $r/$o."
    return 1
  fi
  mkdir -p "$a" && tar -czf "$a/sysinfo_archive_$t.tar.gz" -C "$d" . && echo "Данные системы заархивированы в: $a/sysinfo_archive_$t.tar.gz"
  if [[ $? -ne 0 ]]; then
    echo "Archive not created."
    return 1
  fi
  rm -rf "$d"
  if [[ -d "$d" ]]; then
    echo "Temporary directory not removed."
    return 1
  fi
  echo "archive creation and cleanup passed."
}

# Run all tests
run_all_tests() {
  test_prerequisites && test_collect_system_data && test_create_json_files && test_generate_combined_json && test_archive_and_cleanup
  if [[ $? -eq 0 ]]; then
    echo "All tests passed!"
  else
    echo "Some tests failed."
    return 1
  fi
}

# Main execution
if [[ $(id -u) != 0 ]]; then
  echo "This operation requires superuser privileges."
  sudo -v || { echo "Superuser verification failed."; exit 1; }
fi

d="$HOME/tmp/.ags"
a="/home/ars/archives/"
r="/home/ars/documents/arsh"

# Uncomment the following line to run tests instead of the main script
run_all_tests
