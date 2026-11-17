function _mhcurl
    if not set -q MIHOMO_API[1]; or test -z "$MIHOMO_API"
        printf 'set MIHOMO_API in ~/.secrets.sh\n' >&2
        return 1
    end
    command curl -fsS $argv
end
