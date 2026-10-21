sub init()
    m.ui = m.top.findNode("ui")
    m.nav = m.top.findNode("nav")
    m.screens = [
        m.top.findNode("homeScreen")
        m.top.findNode("breathScreen")
        m.top.findNode("reflectScreen")
        m.top.findNode("appsScreen")
        m.top.findNode("sessionsScreen")
    ]
    m.warning = m.top.findNode("warning")
    m.warnTitle = m.top.findNode("warnTitle")
    m.warnText = m.top.findNode("warnText")
    m.player = m.top.findNode("player")
    m.nowPlaying = m.top.findNode("nowPlaying")
    m.nowTitle = m.top.findNode("nowTitle")
    m.video = m.top.findNode("video")
    m.audio = m.top.findNode("audio")
    m.mode = ""
    m.current = 0

    m.techniques = loadJson("pkg:/data/breathwork.json")
    m.techById = {}
    for each t in m.techniques
        m.techById[t.id] = t
    end for
    m.sessions = loadJson("pkg:/data/sessions.json")
    m.screens[0].techniques = m.techniques
    m.screens[1].techniques = m.techniques
    m.screens[4].sessions = m.sessions

    for each s in m.screens
        s.observeField("action", "onAction")
    end for
    m.nav.observeField("itemFocused", "onNavFocused")
    m.player.observeField("done", "onBreathDone")
    m.video.observeField("state", "onPlayerState")
    m.audio.observeField("state", "onPlayerState")

    m.appsTask = m.top.findNode("appsTask")
    m.appsTask.observeField("apps", "onApps")
    m.appsTask.observeField("error", "onAppsError")
    m.appsTask.control = "run"

    focusScreen()
end sub

function loadJson(path as String) as Object
    data = ParseJson(ReadAsciiFile(path))
    if data = invalid then return []
    return data
end function

sub onNavFocused()
    m.current = m.nav.itemFocused
    for i = 0 to m.screens.Count() - 1
        m.screens[i].visible = (i = m.current)
    end for
end sub

sub focusScreen()
    m.screens[m.current].focusIn = true
end sub

sub onApps()
    m.screens[0].apps = m.appsTask.apps
    m.screens[3].apps = m.appsTask.apps
end sub

sub onAppsError()
    m.screens[3].status = m.appsTask.error
end sub

sub onAction(event as Object)
    a = event.getData()
    if a.type = "breath"
        startBreath(a.ref)
    else if a.type = "app"
        m.appsTask.launch = a.ref
    else if a.type = "reflect"
        m.nav.jumpToItem = 2
        onNavFocused()
        focusScreen()
    else if a.type = "play"
        playSession(a.ref.ToInt())
    end if
end sub

sub startBreath(id as String)
    t = m.techById[id]
    if t = invalid then return
    if t.warning <> invalid
        m.pending = t
        m.warnTitle.text = t.title
        m.warnText.text = t.warning
        m.warning.visible = true
        m.mode = "warning"
        m.top.setFocus(true)
    else
        runBreath(t)
    end if
end sub

sub runBreath(t as Object)
    m.warning.visible = false
    m.ui.visible = false
    m.player.visible = true
    m.mode = "breath"
    m.player.technique = t
    m.player.setFocus(true)
end sub

sub onBreathDone()
    m.player.visible = false
    m.ui.visible = true
    m.mode = ""
    focusScreen()
end sub

sub playSession(i as Integer)
    s = m.sessions[i]
    if s = invalid then return

    c = CreateObject("roSGNode", "ContentNode")
    c.title = s.title
    c.url = s.url
    c.streamFormat = s.format
    shouldLoop = false
    if s.loop <> invalid then shouldLoop = s.loop

    isAudio = false
    if s.type <> invalid then isAudio = (s.type = "audio")

    m.ui.visible = false
    if isAudio
        m.mode = "audio"
        m.audio.content = c
        m.audio.loop = shouldLoop
        m.audio.control = "play"
        m.nowTitle.text = s.title
        m.nowPlaying.visible = true
        m.top.setFocus(true)
    else
        m.mode = "video"
        m.video.content = c
        m.video.loop = shouldLoop
        m.video.visible = true
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
    m.nowPlaying.visible = false
    m.ui.visible = true
    m.mode = ""
    focusScreen()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if m.mode = "warning"
        if key = "OK"
            runBreath(m.pending)
        else if key = "back"
            m.warning.visible = false
            m.mode = ""
            focusScreen()
        end if
        return true
    end if
    if m.mode = "audio" or m.mode = "video"
        if key = "back" then stopPlayback()
        return true
    end if
    if m.mode = "breath" then return true

    ' Sidebar <-> content navigation; Back on the sidebar exits the channel
    if m.nav.hasFocus()
        if key = "right"
            focusScreen()
            return true
        end if
        return false
    end if
    if key = "left" or key = "back"
        m.nav.setFocus(true)
        return true
    end if
    return false
end function
