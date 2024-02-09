install:
	cp src/getsysinfo.zsh /usr/local/bin/getsysinfo
	chmod +x /usr/local/bin/getsysinfo
	cp src/update_getsysinfo.zsh /usr/local/bin/update_getsysinfo
	chmod +x /usr/local/bin/update_getsysinfo

uninstall:
	rm -f /usr/local/bin/getsysinfo
	rm -f /usr/local/bin/update_getsysinfo
