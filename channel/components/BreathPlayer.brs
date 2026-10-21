' Guided breathing engine. A technique is rounds x blocks x repeats x steps;
' each step is a phase ("in", "sniff", "out", "hold", "holdEmpty") with a
' duration in seconds, or an open hold that lasts until the user presses OK.

sub init()
    m.title = m.top.findNode("title")
    m.progress = m.top.findNode("progress")
    m.core = m.top.findNode("core")
    m.halo = m.top.findNode("halo")
    m.count = m.top.findNode("count")
    m.phase = m.top.findNode("phase")
    m.detail = m.top.findNode("detail")
    m.hint = m.top.findNode("hint")
    m.anim = m.top.findNode("anim")
    m.coreInterp = m.top.findNode("coreInterp")
    m.haloInterp = m.top.findNode("haloInterp")
    m.stepTimer = m.top.findNode("stepTimer")
    m.tick = m.top.findNode("tick")

    m.stepTimer.observeField("fire", "nextStep")
    m.tick.observeField("fire", "onTick")
    m.span = CreateObject("roTimespan")
    m.total = CreateObject("roTimespan")
    m.cur = invalid
    m.finished = true
end sub

function textOr(value as Dynamic, fallback as String) as String
    if value = invalid then return fallback
    return value
end function

function numOr(value as Dynamic, fallback as Float) as Float
    if value = invalid then return fallback
    return value
end function

function defaultLabel(p as String) as String
    labels = { "in": "Inspirez", "sniff": "Encore un peu", "out": "Expirez", "hold": "Retenez", "holdEmpty": "Retenez, poumons vides" }
    return textOr(labels[p], "")
end function

function targetScale(p as String) as Float
    if p = "in" then return 1.0
    if p = "sniff" then return 1.12
    if p = "out" or p = "ready" then return 0.55
    return m.scale
end function

sub start()
    t = m.top.technique
    if t = invalid then return

    m.steps = [{ p: "ready", s: 5.0, text: "Installez-vous confortablement", open: false, round: 0, rounds: 0, rep: 0, reps: 0, label: "" }]
    rounds = Int(numOr(t.rounds, 1))
    for r = 1 to rounds
        for each b in t.blocks
            reps = Int(numOr(b.repeat, 1))
            for i = 1 to reps
                for each st in b.steps
                    m.steps.Push({
                        p: st.p
                        s: numOr(st.s, 0)
                        text: textOr(st.t, defaultLabel(st.p))
                        open: st.open <> invalid
                        round: r
                        rounds: rounds
                        rep: i
                        reps: reps
                        label: textOr(b.label, "")
                    })
                end for
            end for
        end for
    end for

    m.title.text = t.title
    m.holds = []
    m.paused = false
    m.finished = false
    m.index = -1
    m.offset = 0.0
    m.scale = 0.55
    m.core.scale = [0.55, 0.55]
    m.halo.scale = [0.62, 0.62]
    m.detail.text = ""
    m.hint.text = "OK : pause   ·   Retour : quitter"
    m.total.Mark()
    m.tick.control = "start"
    nextStep()
end sub

sub nextStep()
    if m.finished then return
    m.index = m.index + 1
    if m.index >= m.steps.Count()
        finish()
        return
    end if

    st = m.steps[m.index]
    m.cur = st
    m.offset = 0.0
    m.span.Mark()
    m.phase.text = st.text
    m.progress.text = progressText(st)

    if st.open
        m.detail.text = "OK dès que vous reprenez votre souffle"
        animateTo(targetScale(st.p), 0.6)
    else
        m.detail.text = ""
        animateTo(targetScale(st.p), st.s)
        m.stepTimer.duration = st.s
        m.stepTimer.control = "start"
    end if
    onTick()
end sub

function progressText(st as Object) as String
    s = ""
    if st.rounds > 1 then s = "Round " + st.round.ToStr() + " / " + st.rounds.ToStr()
    if st.label <> ""
        if s <> "" then s = s + "   ·   "
        s = s + st.label
    end if
    if st.reps > 1
        if s <> "" then s = s + "   ·   "
        s = s + st.rep.ToStr() + " / " + st.reps.ToStr()
    end if
    return s
end function

sub animateTo(target as Float, seconds as Float)
    if seconds < 0.3 then seconds = 0.3
    m.anim.control = "stop"
    m.coreInterp.keyValue = [[m.scale, m.scale], [target, target]]
    h0 = m.scale * 1.12
    h1 = target * 1.12
    m.haloInterp.keyValue = [[h0, h0], [h1, h1]]
    m.anim.duration = seconds
    m.anim.control = "start"
    m.scale = target
end sub

function elapsed() as Float
    if m.paused then return m.offset
    return m.offset + m.span.TotalMilliseconds() / 1000.0
end function

function formatTime(sec as Integer) as String
    return (sec \ 60).ToStr() + ":" + Right("0" + (sec mod 60).ToStr(), 2)
end function

sub onTick()
    if m.cur = invalid or m.finished or m.paused then return
    st = m.cur
    if st.open
        m.count.text = formatTime(Int(elapsed()))
    else if st.s < 2 and st.reps > 1
        ' Fast breathing: count the breaths instead of the seconds
        m.count.text = st.rep.ToStr()
    else
        n = Int(st.s - elapsed() + 0.999)
        if n < 1 then n = 1
        m.count.text = n.ToStr()
    end if
end sub

sub togglePause()
    if m.paused
        m.paused = false
        m.span.Mark()
        remaining = m.cur.s - m.offset
        if remaining < 0.1 then remaining = 0.1
        m.stepTimer.duration = remaining
        m.stepTimer.control = "start"
        m.anim.control = "resume"
        m.phase.text = m.cur.text
        m.hint.text = "OK : pause   ·   Retour : quitter"
    else
        m.offset = elapsed()
        m.paused = true
        m.stepTimer.control = "stop"
        m.anim.control = "pause"
        m.phase.text = "Pause"
        m.hint.text = "OK : reprendre   ·   Retour : quitter"
    end if
end sub

sub finish()
    m.finished = true
    m.stepTimer.control = "stop"
    m.tick.control = "stop"
    animateTo(0.8, 2.0)
    m.phase.text = "Séance terminée"
    m.progress.text = "Durée " + formatTime(Int(m.total.TotalSeconds()))
    m.count.text = ""
    if m.holds.Count() > 0
        s = "Rétentions :"
        for each h in m.holds
            s = s + "  " + formatTime(h)
        end for
        m.detail.text = s
    else
        m.detail.text = ""
    end if
    m.hint.text = "OK ou Retour pour revenir"
end sub

sub quit()
    m.finished = true
    m.cur = invalid
    m.stepTimer.control = "stop"
    m.tick.control = "stop"
    m.anim.control = "stop"
    m.top.done = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back"
        quit()
        return true
    end if
    if key = "OK"
        if m.finished
            quit()
        else if m.cur <> invalid and m.cur.open
            m.holds.Push(Int(elapsed()))
            nextStep()
        else if m.cur <> invalid
            togglePause()
        end if
        return true
    end if
    return false
end function
