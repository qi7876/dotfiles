function _mhcurl
    if not set -q MIHOMO_API[1]; or test -z "$MIHOMO_API"
        printf 'set MIHOMO_API in ~/.config/fish/secrets.fish\n' >&2
        return 1
    end
    if set -q MIHOMO_SECRET[1]; and test -n "$MIHOMO_SECRET"
        command curl -fsS -H "Authorization: Bearer $MIHOMO_SECRET" $argv
    else
        command curl -fsS $argv
    end
end
