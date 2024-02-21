#!/bin/zsh

# Определение домашней директории текущего пользователя
echo "Определяем домашнюю директорию пользователя..."
if [[ -n "$SUDO_USER" ]]; then
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_HOME=$HOME
fi
echo "Домашняя директория: $REAL_HOME"

# Установка пути переменной ZSH_CUSTOM в каталог custom плагинов Oh My Zsh
PLUGIN_PATH="${ZSH_CUSTOM:-$REAL_HOME/.oh-my-zsh/custom}/plugins/arshcollectdata"
echo "Путь для установки плагина: $PLUGIN_PATH"

# Создание директории плагина, если она не существует
echo "Создаем директории для плагина..."
mkdir -p "$PLUGIN_PATH/src" "$PLUGIN_PATH/docs"

# Переходим в директорию скрипта установки
cd "$(dirname "$0")" || { echo "Не удалось перейти в директорию скрипта."; exit; }

# Включаем опцию nullglob для предотвращения ошибок при отсутствии .zsh файлов
setopt nullglob

# Копирование файлов .zsh из директории src в директорию $PLUGIN_PATH/src
echo "Копируем файлы .zsh из исходной директории в целевую директорию..."
zsh_files=(src/*.zsh)
if (( ${#zsh_files} )); then
    cp -- $zsh_files "$PLUGIN_PATH/src/"
    echo "Файлы успешно скопированы."
else
    echo "Файлы .zsh для перемещения не найдены."
    # Нет необходимости выходить с ошибкой, если это не критично
fi

# Сброс опции nullglob после использования
unsetopt nullglob

# Копирование Makefile в каталог плагина
echo "Копируем Makefile в каталог плагина..."
cp Makefile "$PLUGIN_PATH/"

# Обновление содержимого Makefile в каталоге плагина
echo "Обновляем Makefile в каталоге плагина..."
cat > "$PLUGIN_PATH/Makefile" <<-EOL
install:
    @echo "Установка скриптов..."
    mkdir -p "\${HOME}/bin"
    cp src/getsysinfo.zsh "\${HOME}/bin/getsysinfo"
    chmod +x "\${HOME}/bin/getsysinfo"
    cp src/update_getsysinfo.zsh "\${HOME}/bin/update_getsysinfo"
    chmod +x "\${HOME}/bin/update_getsysinfo"
    @echo "Скрипты успешно установлены."

uninstall:
    @echo "Удаление скриптов..."
    rm -f "\${HOME}/bin/getsysinfo"
    rm -f "\${HOME}/bin/update_getsysinfo"
    @echo "Скрипты успешно удалены."
EOL

# Проверка наличия установленных пакетов и установка недостающих для Arch Linux
echo "Проверяем наличие необходимых пакетов и устанавливаем их при необходимости..."
required_packages=(base-devel)
for package in $required_packages; do
    if ! pacman -Qq $package &>/dev/null; then
        echo "Установка пакета $package..."
        sudo pacman -Syu --needed $package
    else
        echo "Пакет $package уже установлен."
    fi
done

# Обновление README.md инструкциями по установке для Arch Linux
echo "Обновляем README.md инструкциями по установке для Arch Linux..."
cat >> "$PLUGIN_PATH/README.md" <<-EOL
## Инструкции по установке

Чтобы установить пакет на Arch Linux, клонируйте репозиторий AUR, соберите пакет с помощью makepkg и установите его с использованием pacman:

\`\`\`sh
git clone 'https://github.com/seocringe/getsysinfo.git'
cd getsysinfo
makepkg -si
\`\`\`

## Использование

После установки вы можете использовать скрипты, запустив:

\`\`\`sh
getsysinfo
update_getsysinfo
\`\`\`
EOL

echo "Инструкции по установке обновлены в README.md."

# Примечание: Вам нужно будет заменить "<aur-repo-url>" и "<repo-name>" на фактические URL и имя вашего репозитория AUR.
echo "Внимание! Замените '<aur-repo-url>' и '<repo-name>' на актуальные ссылку и название вашего репозитория AUR."
