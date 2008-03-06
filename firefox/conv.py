#!/usr/bin/env python

import re
shortcut_re = re.compile(
    r'href="(?P<url>.+?)".+shortcuturl="(?P<key>.+?)"')
from xml.sax.saxutils import escape

def shortcuts(fn='bookmarks.html'):
    ret = []
    for l in file(fn):
        m = shortcut_re.search(l)
        if m:
            d = m.groupdict()
            d['url'] = escape(d['url'].replace('%s', '@@@'))
            ret.append('\t<key>%(key)s</key>\n\t<string>%(url)s</string>' % d)
    return ret


if __name__ == '__main__':
    print """\
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/ PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
%s
</dict>
</plist>""" % '\n'.join(shortcuts())
