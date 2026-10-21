sub init()
    m.grid = m.top.findNode("grid")
    m.statusLabel = m.top.findNode("statusLabel")
    m.grid.observeField("itemSelected", "onSelected")
end sub

sub onFocusIn()
    if m.grid.content <> invalid and m.grid.content.getChildCount() > 0
        m.grid.setFocus(true)
    else
        m.top.setFocus(true)
    end if
end sub

sub buildTiles()
    content = CreateObject("roSGNode", "ContentNode")
    for each a in m.top.apps
        addTile(content, "app:" + a.id, a.name, "", a.icon)
    end for
    m.grid.content = content
    m.statusLabel.text = m.top.apps.Count().ToStr() + " applications  ·  OK pour lancer"
end sub

sub showStatus()
    m.statusLabel.text = m.top.status
end sub

sub onSelected()
    emitAction(m.grid.content.getChild(m.grid.itemSelected).id)
end sub
