# Определение оболочки для выполнения команд
SHELL := /bin/sh

# Задаем переменные для пути установки плагина
SRC := src
REAL_HOME ?= $(HOME)
PLUGIN_NAME := getsysinfo
ZSH_CUSTOM_PATH ?= $(realpath $(REAL_HOME)/.oh-my-zsh/custom)
PLUGIN_PATH := $(ZSH_CUSTOM_PATH)/plugins/$(PLUGIN_NAME)

.PHONY: install uninstall

# Определение цели "install"
install:
	@echo "Определяем домашнюю директорию пользователя..."
	@if [ -n "$$SUDO_USER" ]; then \
		REAL_HOME=$$(getent passwd "$$SUDO_USER" | cut -d: -f6); \
	else \
		REAL_HOME=$(HOME); \
	fi; \
	echo "Домашняя директория: $$REAL_HOME"; \
	\
	ZSH_CUSTOM_PATH=$${ZSH_CUSTOM:-$$REAL_HOME/.oh-my-zsh/custom}; \
	PLUGIN_PATH=$$(realpath $$ZSH_CUSTOM_PATH)/plugins/$(PLUGIN_NAME); \
	echo "Путь для установки плагина: $$PLUGIN_PATH"; \
	\
	echo "Создаем директорию для плагина..."; \
	mkdir -p "$$PLUGIN_PATH"; \
	\
	echo "Копируем файлы .zsh в директорию плагина..."; \
	for file in $(SRC)/*.zsh; do \
		plugin_file="$$PLUGIN_PATH"/$$(basename $$file); \
		cp -- "$$file" "$${plugin_file%.zsh}".plugin.zsh; \
	done; \
	echo "Файлы успешно скопированы."; \
	\
	echo "Устанавливаем правильные разрешения для директории плагина..."; \
	chmod -R 755 "$$PLUGIN_PATH"; \
	echo "Разрешения установлены."

# Определение цели "uninstall"
uninstall:
	@echo "Удаление плагина $(PLUGIN_NAME) из пути $$PLUGIN_PATH..."
	@if [ -d "$(PLUGIN_PATH)" ]; then \
		rm -rf "$(PLUGIN_PATH)"; \
		echo "Плагин $(PLUGIN_NAME) успешно удален."; \
	else \
		echo "Плагин $(PLUGIN_NAME) не найден."; \
	fi;
