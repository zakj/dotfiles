from pathlib import Path
from subprocess import check_output

from kittens.tui.handler import result_handler
from kitty.window import CwdRequest, CwdRequestType

MISE = (str(Path("~/.local/bin/mise").expanduser()), "x", "--")


def main():
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss) -> None:
    w = boss.window_id_map.get(target_window_id)
    cwd = CwdRequest(w, CwdRequestType.last_reported).cwd_of_child
    try:
        root = check_output((*MISE, "jj", "root"), cwd=cwd, text=True).strip()
    except Exception:
        return

    def at(*args):
        boss.call_remote_control(w, args)

    try:
        at("focus-window", f"--match=title:jjui and cwd:{root}")
    except Exception:
        title = f"jjui {Path(root).name}"
        # Run with fish to get mise active and $EDITOR set.
        at("launch", f"--cwd={root}", f"--title={title}", "fish", "-c", "jjui")
