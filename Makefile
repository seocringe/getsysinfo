install:
	@echo "Установка скриптов..."
	mkdir -p "${HOME}/bin"
	cp src/getsysinfo.zsh "${HOME}/bin/getsysinfo"
	chmod +x "${HOME}/bin/getsysinfo"
	cp src/update_getsysinfo.zsh "${HOME}/bin/update_getsysinfo"
	chmod +x "${HOME}/bin/update_getsysinfo"
	@echo "Скрипты успешно установлены."

uninstall:
	@echo "Удаление скриптов..."
	rm -f "${HOME}/bin/getsysinfo"
	rm -f "${HOME}/bin/update_getsysinfo"
	@echo "Скрипты успешно удалены."
