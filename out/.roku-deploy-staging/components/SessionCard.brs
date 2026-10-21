sub init()
    m.card = m.top.findNode("card")
    m.focusBg = m.top.findNode("focusBg")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
end sub

sub showContent()
    item = m.top.itemContent
    m.title.text = item.title
    m.subtitle.text = UCase(item.description)
end sub

sub showFocus()
    p = m.top.focusPercent
    m.focusBg.opacity = p
    s = 1.0 + 0.06 * p
    m.card.scale = [s, s]
    if p > 0.5
        m.title.color = "0x1A1F1CFF"
        m.subtitle.color = "0x5C6658FF"
    else
        m.title.color = "0xE8E2D4FF"
        m.subtitle.color = "0x8A9486FF"
    end if
end sub
