#!/bin/bash

# Крутим postfix set-permissions, пока не исчезнут ошибки вида:
# chown: cannot access '/какой-то/путь/имя.5.gz': No such file or directory

while true; do
    output="$(postfix set-permissions 2>&1)"
    status=$?

    echo "$output"

    # Ловим строки с нужной ошибкой и вытаскиваем путь в один файл
    missing_file="$(grep -oE "chown: cannot access '([^']+)': No such file or directory" <<< "$output" \
        | sed -E "s/^chown: cannot access '([^']+)'.*/\1/" \
        | head -n1)"

    if [[ -n "$missing_file" ]]; then
        echo "Обнаружен отсутствующий файл: $missing_file"
        dir="$(dirname "$missing_file")"
        mkdir -p "$dir"
        touch "$missing_file"
        echo "Создан файл $missing_file, повторяю postfix set-permissions..."
        continue
    fi

    # Если больше нет таких ошибок — выходим с кодом postfix
    exit "$status"
done