#!/bin/sh

# Определяем путь к директории, где находится этот скрипт
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
# Предполагаем, что имя главного скрипта - getsysinfo.zsh и он находится в той же директории
EXECUTABLE_NAME="getsysinfo"

echo "Переходим в директорию скрипта: $REPO_DIR"
cd "$REPO_DIR" || { echo "Ошибка: Невозможно перейти в директорию $REPO_DIR"; exit 1; }

echo "Получаем последние изменения из git..."
git pull origin main || { echo "Ошибка: Не удалось выполнить git pull"; exit 1; }

echo "Устанавливаем права на выполнение скрипта..."
chmod +x "${EXECUTABLE_NAME}.zsh" || { echo "Ошибка: Не удалось установить права на выполнение"; exit 1; }

echo "Копируем исполняемый файл в /usr/bin/"
sudo cp -f "${EXECUTABLE_NAME}.zsh" "/usr/bin/${EXECUTABLE_NAME}" || { echo "Ошибка: Не удалось скопировать файл"; exit 1; }

echo "Обновление системной информации выполнено успешно."