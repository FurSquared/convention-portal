# convention-portal
Furry Convention Portal

## Installation instructions

Start with a fresh net install of debian
https://www.debian.org/CD/netinst/

Use entire disk.

De-select desktop environment and gnome. Select SSH Server.

Install.

Remove the installation media and restart.
Sign in. 

```bash
su root
...
apt install -y git net-tools
/sbin/ifconfig
```

Make note of your IP address. It'll be more convenient to copy and paste things going forward over ssh.

SSH in.

```bash
git clone https://github.com/FurSquared/convention-portal.git
cd convention-portal
su root
...
./installer.sh
```

While the script is in progress, grab your RTMP details. For example
* Server: `rtmp://ingest.vrcdn.live/live`
* Stream Key: `vrcdn_{uuid}`
* RTMP (source): `rtmp://stream.vrcdn.live/live/{username}`

Prepare a copy url for the stream: `${Server}/${Stream Key}`, in this case it would be `rtmp://ingest.vrcdn.live/live/vrcdn_{uuid}`. 

Return to the install script and enter this information.


```
=== === === === === === === === === === === === === ===
Configuring MPV ingester...
Installing Neural Networks for FFMPEG...
Cloning into 'rnnoise-models'...
remote: Enumerating objects: 51, done.
remote: Total 51 (delta 0), reused 0 (delta 0), pack-reused 51 (from 1)
Receiving objects: 100% (51/51), 4.24 MiB | 4.53 MiB/s, done.
Resolving deltas: 100% (15/15), done.
=== === === === === === === === === === === === === ===
Configuring vars.env...
Enter RTMP destination [rtmp://example.com/live/keyhere]: ....
Enter RTMP source [rtmp://example.com/live]: ....

Select the OUTPUT audio source (capture device for streaming):
XDG_RUNTIME_DIR (/run/user/1000) is not owned by us (uid 0), but by uid 1000! (This could e.g. happen if you try to connect to a non-root PulseAudio as a root user, over the native protocol. Don't do that.)
Available sources:
  [1] alsa_input.usb-046d_HD_Pro_Webcam_C920_EDAA27BF-02.analog-stereo
  [2] alsa_input.usb-046d_HD_Pro_Webcam_C920_EDAA27BF-02.analog-stereo.echo-cancel
Select device [2]:
=== === === === === === === === === === === === === ===
Configure USB drive for update files? (y/n):

=== === === === === === === === === === === === === ===
Copying files...
Done.
=== === === === === === === === === === === === === ===
Restarting/enabling services...
Created symlink '/etc/systemd/system/multi-user.target.wants/pulseaudio.service' → '/etc/systemd/system/pulseaudio.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/stream.service' → '/etc/systemd/system/stream.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/ingest.service' → '/etc/systemd/system/ingest.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/sink-monitor.service' → '/etc/systemd/system/sink-monitor.service'.
Mount Update Service disabled. Updates are manual.
Done.
=== === === === === === === === === === === === === ===
Installation Complete. A reboot is recommended.
```

