' Helpers shared by the screen components

function textOr(value as Dynamic, fallback as String) as String
    if value = invalid then return fallback
    return value
end function

sub addTile(parent as Object, id as String, title as String, subtitle as String, icon as String)
    n = parent.createChild("ContentNode")
    n.id = id
    n.title = title
    n.description = subtitle
    n.HDPosterUrl = icon
end sub

' Tile ids encode what selecting them does: "breath:<id>", "app:<id>", "play:<index>", "reflect"
sub emitAction(id as String)
    if Left(id, 7) = "breath:"
        m.top.action = { type: "breath", ref: Mid(id, 8) }
    else if Left(id, 4) = "app:"
        m.top.action = { type: "app", ref: Mid(id, 5) }
    else if Left(id, 5) = "play:"
        m.top.action = { type: "play", ref: Mid(id, 6) }
    else if id = "reflect"
        m.top.action = { type: "reflect", ref: "" }
    end if
end sub
