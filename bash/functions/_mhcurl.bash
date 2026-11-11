_mhcurl() {
        if [[ -z "${MIHOMO_API:-}" ]]; then
                printf 'set MIHOMO_API in ~/.config/bash/secrets.bash\n' >&2
                return 1
        fi
        if [[ -n "${MIHOMO_SECRET:-}" ]]; then
                command curl -fsS -H "Authorization: Bearer $MIHOMO_SECRET" "$@"
        else
                command curl -fsS "$@"
        fi
}
