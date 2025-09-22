#!/bin/bash

# Путь к директории сохранений resurrect
RESURRECT_DIR="$HOME/.local/share/tmux/resurrect"
# Альтернативный путь для старых версий
if [ ! -d "$RESURRECT_DIR" ]; then
    RESURRECT_DIR="$HOME/.tmux/resurrect"
fi

# Если директория не существует
if [ ! -d "$RESURRECT_DIR" ]; then
    echo "no saves"
    exit 0
fi

# Найти последний файл сохранения
LAST_SAVE=$(find "$RESURRECT_DIR" -name "last" -type l 2>/dev/null)

if [ -z "$LAST_SAVE" ] || [ ! -e "$LAST_SAVE" ]; then
    # Найти самый новый файл сохранения по времени
    LAST_FILE=$(find "$RESURRECT_DIR" -name "tmux_resurrect_*.txt" -type f 2>/dev/null | head -1)
    if [ -z "$LAST_FILE" ]; then
        echo "no saves"
        exit 0
    fi
    LAST_SAVE="$LAST_FILE"
fi

# Получить время модификации файла
if command -v stat >/dev/null 2>&1; then
    # macOS и Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        SAVE_TIME=$(stat -f "%m" "$LAST_SAVE" 2>/dev/null)
    else
        # Linux
        SAVE_TIME=$(stat -c "%Y" "$LAST_SAVE" 2>/dev/null)
    fi
    
    if [ -n "$SAVE_TIME" ]; then
        CURRENT_TIME=$(date +%s)
        DIFF=$((CURRENT_TIME - SAVE_TIME))
        
        # Преобразовать в читаемый формат
        if [ $DIFF -lt 60 ]; then
            echo "${DIFF}s ago"
        elif [ $DIFF -lt 3600 ]; then
            echo "$((DIFF/60))m ago"
        elif [ $DIFF -lt 86400 ]; then
            echo "$((DIFF/3600))h ago"
        else
            echo "$((DIFF/86400))d ago"
        fi
    else
        echo "unknown"
    fi
else
    echo "no stat"
fi
