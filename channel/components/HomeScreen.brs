sub init()
    m.greeting = m.top.findNode("greeting")
    m.dateLine = m.top.findNode("dateLine")
    m.question = m.top.findNode("question")
    m.grid = m.top.findNode("grid")
    m.grid.observeField("itemSelected", "onSelected")

    clockTimer = m.top.findNode("clockTimer")
    clockTimer.observeField("fire", "updateClock")
    clockTimer.control = "start"
    questionTimer = m.top.findNode("questionTimer")
    questionTimer.observeField("fire", "showQuestion")
    questionTimer.control = "start"

    updateClock()
    showQuestion()
end sub

sub onFocusIn()
    m.grid.setFocus(true)
end sub

sub showQuestion()
    m.question.text = deckNext().q
end sub

sub updateClock()
    days = ["dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi"]
    months = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"]
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    h = now.GetHours()
    clock = Right("0" + h.ToStr(), 2) + ":" + Right("0" + now.GetMinutes().ToStr(), 2)
    m.dateLine.text = days[now.GetDayOfWeek()] + " " + now.GetDayOfMonth().ToStr() + " " + months[now.GetMonth() - 1] + "  ·  " + clock
    if h >= 5 and h < 12
        m.greeting.text = "Bonjour"
    else if h >= 12 and h < 18
        m.greeting.text = "Bon après-midi"
    else
        m.greeting.text = "Bonsoir"
    end if
end sub

' Energising in the morning, focus in the day, calm in the evening, sleep at night
function recommendedId() as String
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    h = now.GetHours()
    if h >= 5 and h < 11 then return "wimhof"
    if h >= 11 and h < 17 then return "box"
    if h >= 17 and h < 21 then return "coherence"
    return "478"
end function

sub buildTiles()
    content = CreateObject("roSGNode", "ContentNode")

    techniques = m.top.techniques
    if techniques <> invalid and techniques.Count() > 0
        pick = techniques[0]
        want = recommendedId()
        for each t in techniques
            if t.id = want then pick = t
        end for
        addTile(content, "breath:" + pick.id, pick.title, "MAINTENANT · " + pick.duration, "")
    end if
    addTile(content, "reflect", "Une question pour toi", "RÉFLEXION", "")

    apps = m.top.apps
    if apps <> invalid
        shown = 0
        for each a in apps
            if shown < 6
                addTile(content, "app:" + a.id, a.name, "", a.icon)
                shown = shown + 1
            end if
        end for
    end if

    m.grid.content = content
end sub

sub onSelected()
    emitAction(m.grid.content.getChild(m.grid.itemSelected).id)
end sub
