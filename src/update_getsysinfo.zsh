#!/bin/sh

# Определяем путь к локальному репозиторию
REPO_DIR="/home/ars/gh/getsysinfo"
EXECUTABLE_NAME="getsysinfo"

# Переходим в директорию репозитория
cd "$REPO_DIR" || exit

# Выполняем git pull для получения последних изменений
git pull origin main

# Убедимся, что скрипт исполняемый
chmod +x "getsysinfo.zsh"

# Копируем исполняемый файл в /usr/bin, перезаписываем если он уже там есть
sudo cp -f "getsysinfo.zsh" "/usr/bin/$EXECUTABLE_NAME"