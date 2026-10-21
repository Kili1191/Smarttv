sub init()
    m.theme = m.top.findNode("theme")
    m.question = m.top.findNode("question")
    m.counter = m.top.findNode("counter")
    showQuestion()
end sub

sub onFocusIn()
    m.top.setFocus(true)
end sub

sub showQuestion()
    q = deckNext()
    m.theme.text = q.c
    m.question.text = q.q
    m.counter.text = q.n.ToStr() + " / " + q.total.ToStr() + "  ·  aucune ne revient avant d'avoir vu toutes les autres"
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press and key = "OK"
        showQuestion()
        return true
    end if
    return false
end function
