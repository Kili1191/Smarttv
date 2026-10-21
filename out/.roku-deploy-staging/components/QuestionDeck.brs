' Walks through every question in a shuffled order saved in the registry,
' so nothing repeats until all of them have been shown.

function deckLoad() as Object
    if m.deck <> invalid then return m.deck
    m.deck = []
    data = ParseJson(ReadAsciiFile("pkg:/data/questions.json"))
    if data <> invalid
        for each theme in data
            for each q in theme.questions
                m.deck.Push({ c: theme.name, q: q })
            end for
        end for
    end if
    return m.deck
end function

function deckNext() as Object
    list = deckLoad()
    total = list.Count()
    if total = 0 then return { c: "", q: "Ajoutez des questions dans data/questions.json", n: 0, total: 0 }

    sec = CreateObject("roRegistrySection", "questions")
    order = invalid
    if sec.Exists("order") then order = ParseJson(sec.Read("order"))
    cursor = 0
    if sec.Exists("cursor") then cursor = sec.Read("cursor").ToInt()

    if order = invalid or order.Count() <> total or cursor >= total
        order = shuffledIndexes(total)
        cursor = 0
        sec.Write("order", FormatJson(order))
    end if

    item = list[order[cursor]]
    cursor = cursor + 1
    sec.Write("cursor", cursor.ToStr())
    sec.Flush()
    return { c: item.c, q: item.q, n: cursor, total: total }
end function

function shuffledIndexes(n as Integer) as Object
    a = []
    for i = 0 to n - 1
        a.Push(i)
    end for
    for i = n - 1 to 1 step -1
        j = Rnd(i + 1) - 1
        tmp = a[i]
        a[i] = a[j]
        a[j] = tmp
    end for
    return a
end function
