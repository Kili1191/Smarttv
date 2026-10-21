# Maison du Calme — Roku channel

A personal SceneGraph channel: greeting and clock, a breathing circle (4s in / 4s out), and a row of session cards. Video sessions play full-screen; audio sessions play over the breathing screen. Back stops playback.

## Run it on your Roku

1. Enable dev mode on the remote: Home ×3, Up ×2, Right, Left, Right, Left, Right. Set a password, note the IP.
2. Deploy:
   ```sh
   ROKU_IP=192.168.1.50 ROKU_PASS=yourpass ./scripts/deploy.sh
   ```
   Or zip the *contents* of `channel/` and upload at `http://<roku-ip>`.
3. Logs: `telnet <roku-ip> 8085`

## Add your own sessions

Edit `channel/data/sessions.json`. Each entry:

| field    | values                         |
|----------|--------------------------------|
| `title`  | card title                     |
| `subtitle` | small caps line on the card  |
| `type`   | `video` or `audio`             |
| `url`    | HTTPS stream URL               |
| `format` | `hls`, `mp4`, `mp3`, `dash`    |
| `loop`   | `true` for ambient loops       |

The video entries are public test streams and the audio entry points at a placeholder LAN address. Replace them.

## Layout

```
channel/
  manifest
  source/main.brs            entry point
  components/MainScene.xml   UI layout
  components/MainScene.brs   home screen + playback logic
  components/SessionCard.*   card design and focus effect
  images/                    background, breathing circle, cards, icons
  data/sessions.json         your content
scripts/deploy.sh            zip + sideload
```
