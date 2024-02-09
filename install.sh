# Navigate to your repository directory
cd /home/ars/gh/getsysinfo/

# Prepare the directory structure
mkdir -p src docs
mv *.zsh src/
echo -e "install:\n\tcp src/getsysinfo.zsh /usr/local/bin/getsysinfo\n\tchmod +x /usr/local/bin/getsysinfo\n\tcp src/update_getsysinfo.zsh /usr/local/bin/update_getsysinfo\n\tchmod +x /usr/local/bin/update_getsysinfo\n\nuninstall:\n\trm -f /usr/local/bin/getsysinfo\n\trm -f /usr/local/bin/update_getsysinfo" > Makefile

# Install necessary packages for Debian packaging
sudo apt-get update
sudo apt-get install dh-make devscripts

# Initialize Debian package structure
dh_make -s --indep --createorig -y

# Navigate to debian directory to modify control file
cd debian
# Manually edit the control file to set package dependencies and information
nano control  # or use your preferred editor

# Go back to the main directory
cd ..

# Build the Debian package
dpkg-buildpackage -uc -us

# Update README.md with installation instructions
echo -e "## Installation Instructions\n\nTo install the package, download the .deb file from the releases page and run:\n\n```sh\ndpkg -i getsysinfo_version_all.deb\n```\n\n## Usage\n\nAfter installation, you can use the scripts by running:\n\n```sh\ngetsysinfo\nupdate_getsysinfo\n```" >> README.md

# Note: Replace "getsysinfo_version_all.deb" with your actual package file name.
