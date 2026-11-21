function mh-reload
    _mhcurl -X PUT -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/configs?force=true"
end
