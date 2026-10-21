' Lists and launches the installed channels through the Roku's own
' External Control Protocol (ECP) on port 8060.

function settingHint() as String
    return "Activez : Paramètres › Système › Paramètres système avancés › Contrôle par applications mobiles › Accès réseau : Autorisé."
end function

sub init()
    m.top.functionName = "runTask"
end sub

sub runTask()
    m.base = "http://" + localIp() + ":8060"
    fetchApps()

    port = CreateObject("roMessagePort")
    m.top.observeField("launch", port)
    while true
        msg = wait(0, port)
        if type(msg) = "roSGNodeEvent" then launchApp(msg.getData())
    end while
end sub

function localIp() as String
    ips = CreateObject("roDeviceInfo").GetIPAddrs()
    for each name in ips
        return ips[name]
    end for
    return "127.0.0.1"
end function

sub fetchApps()
    xfer = CreateObject("roUrlTransfer")
    xfer.SetUrl(m.base + "/query/apps")
    body = xfer.GetToString()
    xml = CreateObject("roXMLElement")
    if body = "" or not xml.Parse(body)
        m.top.error = "Impossible de lister vos applications. " + settingHint()
        return
    end if

    list = []
    children = xml.GetChildElements()
    if children <> invalid
        for each app in children
            attrs = app.GetAttributes()
            ' Skip TV inputs and this sideloaded channel itself
            if attrs.type = "appl" and attrs.id <> "dev"
                list.Push({ id: attrs.id, name: app.GetText(), icon: m.base + "/query/icon/" + attrs.id })
            end if
        end for
    end if
    m.top.apps = list
end sub

sub launchApp(id as String)
    xfer = CreateObject("roUrlTransfer")
    xfer.SetUrl(m.base + "/launch/" + id)
    code = xfer.PostFromString("")
    if code < 200 or code >= 300
        m.top.error = "Lancement refusé (code " + code.ToStr() + "). " + settingHint()
    end if
end sub
