sub init()
    m.home = m.top.findNode("home")
    m.chrome = m.top.findNode("chrome")
    m.nowPlaying = m.top.findNode("nowPlaying")
    m.nowTitle = m.top.findNode("nowTitle")
    m.rows = m.top.findNode("sessions")
    m.video = m.top.findNode("video")
    m.audio = m.top.findNode("audio")
    m.greeting = m.top.findNode("greeting")
    m.clock = m.top.findNode("clock")
    m.breathLabel = m.top.findNode("breathLabel")
    m.playing = ""

    ' Sessions live in data/sessions.json so you can swap streams without touching code
    m.sessions = ParseJson(ReadAsciiFile("pkg:/data/sessions.json"))
    if m.sessions = invalid then m.sessions = []

    root = CreateObject("roSGNode", "ContentNode")
    row = root.createChild("ContentNode")
    for each s in m.sessions
        item = row.createChild("ContentNode")
        item.title = s.title
        item.description = textOr(s.subtitle, "")
    end for
    m.rows.content = root
    m.rows.observeField("rowItemSelected", "onSelected")

    m.video.observeField("state", "onPlayerState")
    m.audio.observeField("state", "onPlayerState")

    m.top.findNode("breathe").control = "start"
    phaseTimer = m.top.findNode("phaseTimer")
    phaseTimer.observeField("fire", "onBreathPhase")
    phaseTimer.control = "start"
    clockTimer = m.top.findNode("clockTimer")
    clockTimer.observeField("fire", "updateClock")
    clockTimer.control = "start"
    updateClock()

    m.rows.setFocus(true)
end sub

function textOr(value as Dynamic, fallback as String) as String
    if value = invalid then return fallback
    return value
end function

sub onBreathPhase()
    if m.breathLabel.text = "Inspirez" then m.breathLabel.text = "Expirez" else m.breathLabel.text = "Inspirez"
end sub

sub updateClock()
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    h = now.GetHours()
    mins = now.GetMinutes()
    m.clock.text = Right("0" + h.ToStr(), 2) + ":" + Right("0" + mins.ToStr(), 2)
    if h < 12
        m.greeting.text = "Bonjour"
    else if h < 18
        m.greeting.text = "Bon après-midi"
    else
        m.greeting.text = "Bonsoir"
    end if
end sub

sub onSelected()
    s = m.sessions[m.rows.rowItemSelected[1]]

    c = CreateObject("roSGNode", "ContentNode")
    c.title = s.title
    c.url = s.url
    c.streamFormat = s.format
    shouldLoop = false
    if s.loop <> invalid then shouldLoop = s.loop

    if textOr(s.type, "video") = "audio"
        ' Audio plays over the breathing screen
        m.playing = "audio"
        m.audio.content = c
        m.audio.loop = shouldLoop
        m.audio.control = "play"
        m.nowTitle.text = s.title
        m.chrome.visible = false
        m.nowPlaying.visible = true
        m.top.setFocus(true)
    else
        m.playing = "video"
        m.video.content = c
        m.video.loop = shouldLoop
        m.video.visible = true
        m.home.visible = false
        m.video.control = "play"
        m.video.setFocus(true)
    end if
end sub

sub onPlayerState(event as Object)
    state = event.getData()
    if state = "error" then print "Playback error: "; event.getRoSGNode().errorMsg
    if state = "finished" or state = "error" then stopPlayback()
end sub

sub stopPlayback()
    m.video.control = "stop"
    m.audio.control = "stop"
    m.video.visible = false
    m.home.visible = true
    m.nowPlaying.visible = false
    m.chrome.visible = true
    m.playing = ""
    m.rows.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press and key = "back" and m.playing <> ""
        stopPlayback()
        return true
    end if
    return false
end function
