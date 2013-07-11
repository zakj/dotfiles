slate.configAll({
    focusCheckWidthMax: 3000,
    windowHintsBackgroundColor: [50, 53, 58, 0.8],
    windowHintsFontName: 'HelveticaNeue',
});

// Common variables.
var gutter = 30,
    topGutter = 'screenOriginY + ' + gutter / 2,
    term = {width: 570, height: 726},
    vim = {width: 563, height: 1383},
    browser = {width: 1110, height: 1414},
    windowOffset = 22;

// Reusable operations.
var moveCenter = slate.operation('move', {
    x: "(screenSizeX - windowSizeX) / 2",
    y: "(screenSizeY - windowSizeY) / 2",
    width: 'windowSizeX',
    height: 'windowSizeY',
});
var cornerTopLeft = slate.operation('corner', {direction: 'top-left'});


// Operations and layout for an Apple Cinema Display.
var extOps = {
    term: slate.operation('move', {
        x: 'screenOriginX + ' + (gutter / 2),
        y: topGutter,
        width: term.width,
        height: term.height,
    }),
    vim: slate.operation('move', {
        x: 'screenOriginX + ' + (gutter / 2 + term.width + gutter),
        y: topGutter,
        width: vim.width,
        height: vim.height,
    }),
};

function extBrowserLayout() {
    var offset = null;

    function makeBrowserOp(left) {
        return slate.operation('move', {
            x: left, y: 0,
            width: browser.width, height: browser.height,
        });
    }

    function browser1(win) {
        offset = win.screen().rect().x + gutter / 2;
        offset += term.width + gutter;
        offset += vim.width + gutter;
        win.doOperation(makeBrowserOp(offset));
    }

    function browserN(win) {
        // For some reason Chrome reports an extra empty window for each real
        // window; the only way I've been able to detect them is by checking
        // for an empty title and small window height. Ugh.
        if (win.title() === '' && win.size().height < 20) return;
        offset += windowOffset;
        win.doOperation(makeBrowserOp(offset));
    }

    return {
        operations: [browser1, browserN],
        'ignore-fail': true,
        'main-first': true,
        'repeat-last': true,
    };
}

var extLayout = slate.layout('ext', {
    'iTerm': {operations: [extOps.term], repeat: true},
    'MacVim': {operations: [extOps.vim], repeat: true},
    'Google Chrome': extBrowserLayout(),
    'Safari': extBrowserLayout(),
    'Sparrow': {operations: [moveCenter], repeat: true},
});
var ext = slate.operation('layout', {name: extLayout})


// Operations and layout for the MacBook Pro screen.
function mbpBrowserLayout() {
    return {
        operations: [S.op('corner', {direction: 'top-right'})],
        repeat: true,
    }
}

var mbpLayout = slate.layout('mbp', {
    'iTerm': {operations: [cornerTopLeft], repeat: true},
    'MacVim': {operations: [cornerTopLeft], repeat: true},
    'Google Chrome': mbpBrowserLayout(),
    'Safari': mbpBrowserLayout(),
    'Sparrow': {operations: [moveCenter], repeat: true},
});
var mbp = slate.operation('layout', {name: mbpLayout})


// Main layout function.
function reLayout() {
    var layout;
    switch (slate.screen().rect().width) {
        case 2560: layout = ext; break;
        case 1440: layout = mbp; break;
    }
    layout.run();
}
slate.on('screenConfigurationChanged', reLayout);


// Bindings.
slate.bindAll({
    'space:ctrl': reLayout,
    ';:ctrl': S.op('hint', {characters: 'sdfjkla;gh'}),
    'h:cmd,ctrl': S.op('focus', {direction: 'left'}),
    'j:cmd,ctrl': S.op('focus', {direction: 'down'}),
    'k:cmd,ctrl': S.op('focus', {direction: 'up'}),
    'l:cmd,ctrl': S.op('focus', {direction: 'right'}),

    ']:ctrl': S.op('nudge', {x: '+' + windowOffset, y: '+0'}),
    '[:ctrl': S.op('nudge', {x: '-' + windowOffset, y: '+0'}),
    'backslash:ctrl': moveCenter,
});
