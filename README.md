# Maison du Calme — Roku channel

A minimal SceneGraph channel: a list of sessions, pick one, it streams full-screen. Back returns to the list.

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
| `title`  | shown in the menu              |
| `url`    | HTTPS stream URL               |
| `format` | `hls`, `mp4`, `mp3`, `dash`    |
| `loop`   | `true` for ambient loops       |

The two entries shipped are public test streams, not meditation content. Replace them.

## Layout

```
channel/
  manifest
  source/main.brs            entry point
  components/MainScene.xml   UI layout
  components/MainScene.brs   menu + playback logic
  data/sessions.json         your content
scripts/deploy.sh            zip + sideload
```
