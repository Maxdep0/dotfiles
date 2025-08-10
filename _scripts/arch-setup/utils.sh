declare -Ar LOG=(
    [START]="🚀" [PROGRESS]="⏳" [INFO]="ℹ️"
    [WARN]="⚠️" [ERROR]="❌" [OK]="✅"
)

logger() {
    local status="${1^^}"
    shift
    local msg="$*"
    local line="${BASH_LINENO[0]}"
    local file="${BASH_SOURCE[1]##*/}"
    local icon="${LOG[$status]}"

    printf '%(%H:%M:%S)T [%s:%s] - %s %s\n' -1 "$file" "$line" "$icon" "$msg" >&3
}

export -f logger
