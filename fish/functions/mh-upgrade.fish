function mh-upgrade
    _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/upgrade"
end
