sub init()
    m.grid = m.top.findNode("grid")
    m.grid.observeField("itemSelected", "onSelected")
end sub

sub onFocusIn()
    m.grid.setFocus(true)
end sub

sub buildTiles()
    content = CreateObject("roSGNode", "ContentNode")
    i = 0
    for each s in m.top.sessions
        addTile(content, "play:" + i.ToStr(), s.title, textOr(s.subtitle, ""), "")
        i = i + 1
    end for
    m.grid.content = content
end sub

sub onSelected()
    emitAction(m.grid.content.getChild(m.grid.itemSelected).id)
end sub
