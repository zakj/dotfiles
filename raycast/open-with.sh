#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open with…
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🧞
# @raycast.argument1 { "type": "text", "placeholder": "Application" }
# @raycast.packageName Navigation

# Documentation:
# @raycast.description Open the current Finder selection in a given application.
# @raycast.author Zak Johnson
# @raycast.authorURL https://zakj.net/

finderSelection() {
  osascript -l JavaScript -e 'console.log(Application("Finder").selection().map(x => x.url()).join(" "));' 2>&1
}

open -a ${1} $(finderSelection)
