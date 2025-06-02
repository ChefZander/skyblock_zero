if command -v sha256sum >/dev/null 2>/dev/null; then
    cat "$@" | sha256sum | awk '{ print $1 }'
elif command -v shasum >/dev/null 2>/dev/null; then
    cat "$@" | shasum | awk '{ print $1 }'
fi