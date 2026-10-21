sub init()
    m.menu = m.top.findNode("menu")
    m.player = m.top.findNode("player")

    ' Sessions live in data/sessions.json so you can swap streams without touching code
    m.sessions = ParseJson(ReadAsciiFile("pkg:/data/sessions.json"))
    if m.sessions = invalid then m.sessions = []

    content = CreateObject("roSGNode", "ContentNode")
    for each s in m.sessions
        item = content.createChild("ContentNode")
        item.title = s.title
    end for
    m.menu.content = content

    m.menu.observeField("itemSelected", "onItemSelected")
    m.player.observeField("state", "onPlayerState")
    m.menu.setFocus(true)
end sub

sub onItemSelected()
    s = m.sessions[m.menu.itemSelected]

    c = CreateObject("roSGNode", "ContentNode")
    c.title = s.title
    c.url = s.url
    c.streamFormat = s.format

    m.player.loop = false
    if s.loop <> invalid then m.player.loop = s.loop
    m.player.content = c
    m.player.visible = true
    m.player.control = "play"
    m.player.setFocus(true)
end sub

sub onPlayerState()
    state = m.player.state
    if state = "error" then print "Playback error: "; m.player.errorMsg
    if state = "finished" or state = "error" then stopPlayback()
end sub

sub stopPlayback()
    m.player.control = "stop"
    m.player.visible = false
    m.menu.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press and key = "back" and m.player.visible
        stopPlayback()
        return true
    end if
    return false
end function
