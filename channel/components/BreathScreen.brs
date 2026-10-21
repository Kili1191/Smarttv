sub init()
    m.grid = m.top.findNode("grid")
    m.info = m.top.findNode("info")
    m.count = m.top.findNode("count")
    m.grid.observeField("itemSelected", "onSelected")
    m.grid.observeField("itemFocused", "onFocused")
end sub

sub onFocusIn()
    m.grid.setFocus(true)
end sub

sub buildTiles()
    content = CreateObject("roSGNode", "ContentNode")
    for each t in m.top.techniques
        addTile(content, "breath:" + t.id, t.title, t.category + " · " + t.duration, "")
    end for
    m.grid.content = content
    m.count.text = m.top.techniques.Count().ToStr() + " techniques guidées  ·  OK pour commencer"
    onFocused()
end sub

sub onFocused()
    if m.top.techniques = invalid then return
    i = m.grid.itemFocused
    if i < 0 or i >= m.top.techniques.Count() then return
    m.info.text = m.top.techniques[i].benefit
end sub

sub onSelected()
    emitAction(m.grid.content.getChild(m.grid.itemSelected).id)
end sub
