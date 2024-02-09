#!/bin/bash
# Navigate to the repository directory
cd "$(dirname "$0")" || exit

# Prepare the directory structuremkdir -p src docs
mv *.zsh src/
cat > Makefile <<EOL
install:
	cp src/getsysinfo.zsh /usr/local/bin/getsysinfo
	chmod +x /usr/local/bin/getsysinfo
	cp src/update_getsysinfo.zsh /usr/local/bin/update_getsysinfo
	chmod +x /usr/local/bin/update_getsysinfo

uninstall:
	rm -f /usr/local/bin/getsysinfo
	rm -f /usr/local/bin/update_getsysinfo
EOL

# Install necessary packages for Debian packaging
sudo apt-get update
sudo apt-get install -y dh-make devscripts

# Initialize Debian package structure
dh_make -s --indep --createorig -y

# Navigate to debian directory to modify control file
cd debian
# Manually edit the control file to set package dependencies and information
nano control  # or use your preferred editor
cd ..

# Build the Debian package
dpkg-buildpackage -uc -us

# Update README.md with installation instructions
echo -e "## Installation Instructions\n\nTo install the package, download the .deb file from the releases page and run:\n\n```sh\ndpkg -i getsysinfo_version_all.deb\n```\n\n## Usage\n\nAfter installation, you can use the scripts by running:\n\n```sh\ngetsysinfo\nupdate_getsysinfo\n```" >> README.md

# Note: Replace "getsysinfo_version_all.deb" with your actual package file name.