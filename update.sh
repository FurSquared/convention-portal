#!/bin/sh

logger "Fetching scripts from USB..."
cp /media/portal/ingester.sh /opt/portal/ingester.tmp
cp /media/portal/streamer.sh /opt/portal/streamer.tmp
cp /media/portal/vars.env /opt/portal/vars.tmp
cp /media/portal/update.sh /opt/portal/update.tmp
logger " Done."

logger "Setting Script Access Modes..."
if ! chmod +x "/opt/portal/ingester.tmp"; then
    logger -p "error" "Failed to make ingester executable."
fi
if ! chmod +x "/opt/portal/streamer.tmp"; then
    logger -p "error" "Failed to make streamer executable."
fi
if ! chmod +x "/opt/portal/update.tmp"; then
    logger -p "error" "Failed to make updater executable."
fi
logger "Done."

logger "Updating Env Vars File..."
if mv "/opt/portal/vars.tmp" "/opt/portal/vars.env"; then
  logger "Done. Update complete."
  #rm "vars.tmp"
else
  logger -p "error" "Failed!"
fi

logger "Updating Ingester..."
systemctl stop ingest.service
if mv "/opt/portal/ingester.tmp" "/opt/portal/ingester.sh"; then
  logger "Done. Update complete."
  systemctl start ingest.service
  #rm "ingester.tmp"
else
  logger -p "error" "Failed!"
fi

logger "Updating Streamer..."
systemctl stop stream.service
if mv "/opt/portal/streamer.tmp" "/opt/portal/streamer.sh"; then
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
if mv "/opt/portal/update.tmp" "/opt/portal/update.sh"; then
  logger "Done. Update complete."
  #rm "update.tmp"
  rm "/tmp/updateScript.sh"
else
  logger -p "error" "Failed!"
fi
EOF
exec /bin/bash /tmp/updateScript.sh
