A demo of how addtodash can launch web pages in independent app containers

Basically, we have one "launcher app", which is Main.qml in this example (and would be the scope in addtodash). We also have a "subapp", which would be the webapp container; this is subapp.qml. There are then many _instances_ of the subapp defined; in this demo there are 4. So there's only one copy of subapp.qml, but we need to define 4 separate apps which use it. To do this, in `manifest.json` we have:

        "hooks": {
            "manyapps": {
                "apparmor": "manyapps.apparmor",
                "desktop": "manyapps.desktop"
            },
            "subapp1": {
                "apparmor": "manyapps.apparmor",
                "desktop": "subapp1.desktop",
                "urls": "subapp1.url-dispatcher"
            },
            "subapp2": {
                "apparmor": "manyapps.apparmor",
                "desktop": "subapp2.desktop",
                "urls": "subapp2.url-dispatcher"
            },
            "subapp3": {
                "apparmor": "manyapps.apparmor",
                "desktop": "subapp3.desktop",
                "urls": "subapp3.url-dispatcher"
            },
            "subapp4": {
                "apparmor": "manyapps.apparmor",
                "desktop": "subapp4.desktop",
                "urls": "subapp4.url-dispatcher"
            }
        }

Note that each shares an apparmor file, but has its own desktop and urls file.

The desktop files look like this: this is `subapp1.desktop`:

    [Desktop Entry]
    Name=manyapps
    Exec=qmlscene %u subapp.qml 1
    Icon=manyapps.png
    Terminal=false
    Type=Application
    X-Ubuntu-Touch=true

There are two important things here, on the `Exec` line; the `%u` is where a passed URL is substituted, and the `1` means "I am app instance 1". (The app needs to know which instance it is; that's used in `subapp.qml`).

The urls file looks like this: this is `subapp1.url-dispatcher`:

    [{"protocol": "subapp1"}]

So subapp 1 registers for `subapp1://` URLs, and is started with the command `qmlscene (the url) subapp.qml 1`.

The user taps a webapp in the main app (or scope), and the webapp launches the URL `subapp1://the-url` (always subapp1). This launches subapp1, i.e., runs the command `qmlscene subapp1://the-url subapp.qml 1`. `subapp.qml` on startup reads the passed URL and its number from `Qt.application.arguments`. It then displays the passed URL in its web container.

When the user taps a second webapp in the scope, this again launches `subapp1://new-url`, which again launches subapp1... but this time, that's already running, and so this new URL is passed to it via `UriHandler{}`. That, because this subapp is already running, creates the URL `subapp2://new-url` and launches it. Subapp1 knows to launch `subapp2://` URLs because it knows that _it_ is subapp1. The URL dispatcher then gets a `subapp2://` URL and launches subapp2 to handle it, which displays that URL. And so on; the scope always launches `subapp1://` URLs and they are "passed down the chain" until we find a subapp which isn't running, which then displays that URL.

Fortunately, this process is OK in appearance -- it might be thought that the user experience would be "tap webapp, get startup screen for subapp 1, wait one second, subapp 1 opens, immediately launches subapp2 URL, get startup screen for subapp2, wait one second, subapp2 opens..." but in practice this is not the case; we see essentially only one startup screen.


