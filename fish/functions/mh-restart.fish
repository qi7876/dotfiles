function mh-restart
    _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/restart"
end
