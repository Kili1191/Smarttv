sub init()
    m.card = m.top.findNode("card")
    m.focusBg = m.top.findNode("focusBg")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.icon = m.top.findNode("icon")
    m.icon.observeField("loadStatus", "onIconLoad")
    m.hasIcon = false
end sub

sub showContent()
    item = m.top.itemContent
    m.title.text = item.title
    m.subtitle.text = item.description
    m.hasIcon = item.HDPosterUrl <> ""
    if m.hasIcon
        ' App tiles: the icon fills the card and focus draws a ring around it
        m.focusBg.uri = "pkg:/images/card_320_ring.png"
        m.icon.uri = item.HDPosterUrl
        m.icon.visible = true
    end if
end sub

sub onIconLoad()
    ' Keep the app name as a fallback until the icon actually loads
    if m.icon.loadStatus = "ready"
        m.title.visible = false
    else if m.icon.loadStatus = "failed"
        m.icon.visible = false
    end if
end sub

sub showFocus()
    p = m.top.focusPercent
    if not m.top.gridHasFocus then p = 0
    m.focusBg.opacity = p
    s = 1.0 + 0.05 * p
    m.card.scale = [s, s]
    if m.hasIcon then return
    if p > 0.5
        m.title.color = "0x1A1F1CFF"
        m.subtitle.color = "0x5C6658FF"
    else
        m.title.color = "0xE8E2D4FF"
        m.subtitle.color = "0x8A9486FF"
    end if
end sub
