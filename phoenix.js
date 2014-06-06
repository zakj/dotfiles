'use strict';
/* jshint globalstrict: true, unused: true */
/* global _, api, App, Screen, Window */

// https://github.com/sdegutis/Phoenix/wiki/JavaScript-API-documentation

var GUTTER = 15;
var WINDOW_OFFSET = 22;
var BROWSER_SIZE = {width: 1110};
var TERM_SIZE = {width: 570, height: 726};
var EDITOR_SIZE = {width: 563};

var layouts = {
    'iTerm': function (windows) {
        windows.slice(0, 1).each(function (win) {
            var rect = win.screen().cornerNW();
            win.setFrame(_.extend(rect, TERM_SIZE));
        });
    },

    'MacVim': function (windows) {
        windows.slice(0, 1).each(function (win) {
            var screen = win.screen().frameWithoutMenu();
            var rect = win.screen().cornerNW();
            rect = _.extend(rect, {height: screen.height}, EDITOR_SIZE);
            if (win.isOnCinemaDisplay()) {
                rect.x += TERM_SIZE.width + GUTTER * 2;
                rect.height -= GUTTER * 2;
            }
            win.setFrame(rect);
        });
    },

    'Google Chrome': function (windows) {
        var left = TERM_SIZE.width + EDITOR_SIZE.width + (GUTTER * 5);

        windows.reject(function (win) {
            return !!win.title().match(/^Developer Tools - /);
        })
        .each(function (win) {
            var screen = win.screen().frameWithoutMenu();
            var rect = win.screen().cornerNE();
            rect.x -= BROWSER_SIZE.width;
            rect = _.extend(rect, {height: screen.height}, BROWSER_SIZE);
            if (win.isOnCinemaDisplay()) {
                rect.x = left;
                rect.y -= GUTTER;
                left += WINDOW_OFFSET;
            }
            win.setFrame(rect);
        });
    },

    'Mail': function (windows) {
        windows.filter(function (win) {
            return !!win.title().match(/^Inbox /);
        })
        .each(function (win) { win.toCenter(); });
    },

    'iTunes': function (windows) {
        windows.each(function (win) {
            if (win.title() === 'MiniPlayer') {
                var point = win.screen().cornerSW();
                point.y -= win.size().height;
                win.setTopLeft(point);
            }
            else {
                win.toCenter();
            }
        });
    }
};


api.bind('space', ['ctrl'], function () {
    _.each(App.runningApps(), function (app) {
        var title = app.title();
        if (typeof layouts[title] === 'function')
            layouts[title](_.chain(app.visibleWindows()));
    });
});


// Screen methods  ///////////////////////////////////////////////////////////

Screen.prototype.frameWithoutMenu = function () {
    var outer = this.frameIncludingDockAndMenu();
    var inner = this.frameWithoutDockOrMenu();
    var menuHeight = inner.y - outer.y;
    inner.height = outer.height - menuHeight;
    return inner;
};

Screen.prototype.isCinemaDisplay = function () {
    return this.frameIncludingDockAndMenu().width === 2560;
};

Screen.prototype.center = function () {
    var rect = this.frameWithoutMenu();
    return {
        x: rect.x + rect.width / 2,
        y: rect.y + rect.height / 2
    };
};

Screen.prototype.cornerNW = function () {
    var rect = this.frameWithoutDockOrMenu();
    if (this.isCinemaDisplay()) {
        rect.x += GUTTER;
        rect.y += GUTTER;
    }
    return {x: rect.x, y: rect.y};
};

Screen.prototype.cornerNE = function () {
    var rect = this.frameWithoutDockOrMenu();
    rect.x += rect.width;
    if (this.isCinemaDisplay()) {
        rect.x -= GUTTER;
        rect.y += GUTTER;
    }
    return {x: rect.x, y: rect.y};
};

Screen.prototype.cornerSW = function () {
    var rect = this.frameWithoutMenu();
    rect.y += rect.height;
    if (this.isCinemaDisplay()) {
        rect.x += GUTTER;
        rect.y -= GUTTER;
    }
    return {x: rect.x, y: rect.y};
};


// Window methods  ///////////////////////////////////////////////////////////

Window.prototype.toCenter = function () {
    var center = this.screen().center();
    var size = this.size();
    this.setTopLeft({
        x: center.x - size.width / 2,
        y: center.y - size.height / 2
    });
};

Window.prototype.isOnCinemaDisplay = function () {
    return this.screen().isCinemaDisplay();
};
