#!/bin/sh

logger "Fetching scripts from USB..."
cp /media/portal/ingester.sh /media/system/ingester.tmp
cp /media/portal/streamer.sh /media/system/streamer.tmp
cp /media/portal/vars.env /media/system/vars.tmp
cp /media/portal/update.sh /media/system/update.tmp
logger " Done."

logger "Setting Script Access Modes..."
if ! chmod +x "/media/system/ingester.tmp"; then
    logger -p "error" "Failed to make ingester executable."
fi
if ! chmod +x "/media/system/streamer.tmp"; then
    logger -p "error" "Failed to make streamer executable."
fi
if ! chmod +x "/media/system/update.tmp"; then
    logger -p "error" "Failed to make updater executable."
fi
logger "Done."

logger "Updating Env Vars File..."
if mv "/media/system/vars.tmp" "/media/system/vars.env"; then
  logger "Done. Update complete."
  #rm "vars.tmp"
else
  logger -p "error" "Failed!"
fi

logger "Updating Ingester..."
systemctl stop ingest.service
if mv "/media/system/ingester.tmp" "/media/system/ingester.sh"; then
  logger "Done. Update complete."
  systemctl start ingest.service
  #rm "ingester.tmp"
else
  logger -p "error" "Failed!"
fi

logger "Updating Streamer..."
systemctl stop stream.service
if mv "/media/system/streamer.tmp" "/media/system/streamer.sh"; then
  logger "Done. Update complete."
  systemctl start stream.service
  #rm "streamer.tmp"
else
  logger -p "error" "Failed!"
fi

logger "Updating Updater..."
cat > /tmp/updateScript.sh << EOF
#!/bin/bash
# Overwrite old file with new
if mv "/media/system/update.tmp" "/media/system/update.sh"; then
  logger "Done. Update complete."
  #rm "update.tmp"
  rm "/tmp/updateScript.sh"
else
  logger -p "error" "Failed!"
fi
EOF
exec /bin/bash /tmp/updateScript.sh
