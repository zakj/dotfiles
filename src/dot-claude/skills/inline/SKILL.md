---
name: inline
description: Find and respond to inline AI! comments
disable-model-invocation: true
---

Search for code comments starting with `AI!` (in $ARGUMENTS if provided, otherwise the whole project). For each one, read the surrounding context, then either answer in the chat or modify the code in-place as appropriate. Remove the `AI!` comment after addressing it.
