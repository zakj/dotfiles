# pyright: basic
# pyright: reportMissingImports=false

from dataclasses import dataclass

from kitty.colors import theme_colors
from kitty.tab_bar import (
    as_rgb,
    color_as_int,
    get_boss,
)


@dataclass
class Pane:
    """Representation of a window with for title truncation."""

    title: str
    is_active: bool


def color_as_rgb(val) -> str:
    return as_rgb(color_as_int(val))


def draw_tab(
    draw_data,
    screen,
    tab_data,
    _before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data,
) -> int:
    boss = get_boss()
    tab = boss.tab_for_id(tab_data.tab_id)
    sep, soft_sep = "", "╱"

    tab_bg = screen.cursor.bg
    if extra_data.next_tab:
        next_tab_bg = color_as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = color_as_rgb(draw_data.default_bg)
        needs_soft_separator = False

    prefix = ""
    if tab_data.needs_attention:
        prefix = draw_data.bell_on_tab
    elif tab_data.has_activity_since_last_focus:
        prefix = draw_data.tab_activity_symbol

    # If the tab has a custom title, show it; otherwise fall back to the tab
    # number. No need to show the active window's title in the tab, since we're
    # showing all of them later.
    title = prefix + (tab.name or str(index))
    extra_width = 3  # leading/trailing spaces, separator/edge symbol
    screen.draw(" ")
    screen.draw(truncate(title, max_tab_length - extra_width))
    if needs_soft_separator:
        screen.draw(f" {soft_sep}")
    else:
        screen.draw(" ")
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
        screen.draw(sep)

    # Display window titles to the right of tabs.
    if is_last:
        # Traverse groups to get windows in layout order. Exclude windows which
        # have an overlay above them, and therefore cannot be made active.
        groups = boss.os_window_map[tab.os_window_id].active_tab.windows.groups
        windows = [w for group in groups for w in group]
        overlay_parents = {w.overlay_parent for w in windows}
        panes = [
            Pane(w.title, w.is_active) for w in windows if w not in overlay_parents
        ]
        screen.draw(" ")

        width = screen.columns - screen.cursor.x
        pane_sep = f" {soft_sep} "
        panes = truncate_titles(panes, width, sep_width=len(pane_sep))
        last = panes[-1]

        active_color = color_as_rgb(draw_data.active_bg)
        inactive_color = color_as_rgb(theme_colors.get_default_colors()["color8"])
        sep_color = color_as_rgb(draw_data.inactive_bg)
        screen.cursor.bold = False  # TODO: can I get this from draw_data somewhere?
        for pane in panes:
            screen.cursor.fg = active_color if pane.is_active else inactive_color
            screen.draw(pane.title)
            if pane is not last:
                screen.cursor.fg = sep_color
                screen.draw(pane_sep)

    return screen.cursor.x


def truncate_titles(panes: list[Pane], width: int, sep_width: int) -> list[Pane]:
    full_width = sum(len(t.title) for t in panes) + (len(panes) - 1) * sep_width
    if full_width <= width:
        return panes

    active_width = len(next(p.title for p in panes if p.is_active))
    remaining_width = width - active_width - (len(panes) - 1) * sep_width
    inactive_count = len(panes) - 1
    inactive_width = remaining_width // inactive_count if inactive_count else 0

    # If we don't have room to display inactive titles, omit them.
    if inactive_width < 1:
        active, index = next((p, i) for i, p in enumerate(panes) if p.is_active)
        prefix = ""
        if inactive_count:
            prefix = f"[{index + 1}/{len(panes)}] "
        return [Pane(truncate(prefix + active.title, width), True)]

    # Truncate inactive titles to an equal proportion of remaining_width, but
    # record the lengths that are unused by inactive titles that don't need
    # truncation.
    widths = {}
    unused = 0
    truncated_indices = []
    for i, pane in enumerate(panes):
        if pane.is_active:
            widths[i] = active_width
        elif len(pane.title) <= inactive_width:
            widths[i] = len(pane.title)
            unused += inactive_width - widths[i]
        else:
            truncated_indices.append(i)
            widths[i] = inactive_width

    # Distribute the unused remaining width equally across the truncated titles.
    extra_per_title = unused // len(truncated_indices)
    for i in truncated_indices:
        widths[i] += extra_per_title

    return [
        Pane(truncate(pane.title, widths[i]), pane.is_active)
        for i, pane in enumerate(panes)
    ]


def truncate(text: str, maxlen: int | None = None) -> str:
    if maxlen is None or len(text) <= maxlen:
        return text
    if maxlen < 1:
        return ""
    return text[: maxlen - 1] + "…"
