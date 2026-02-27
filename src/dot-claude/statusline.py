#!/usr/bin/env python3
import json
import os
import sys

data = json.load(sys.stdin)

model_id = data.get("model", {}).get("id", "")
model_name = data.get("model", {}).get("display_name", "")
project_dir = data.get("workspace", {}).get("project_dir") or data.get("cwd", "")
project = os.path.basename(project_dir)

pct = int(data.get("context_window", {}).get("used_percentage") or 0)
ctx_size = data.get("context_window", {}).get("context_window_size") or 200000

cu = data.get("context_window", {}).get("current_usage") or {}
used = (
    (cu.get("input_tokens") or 0)
    + (cu.get("cache_creation_input_tokens") or 0)
    + (cu.get("cache_read_input_tokens") or 0)
)
if used == 0 and pct > 0:
    used = pct * ctx_size // 100

cost = data.get("cost", {}).get("total_cost_usd") or 0


def fmt_tokens(t):
    return f"{t // 1000}k" if t >= 1000 else str(t)


COST_THRESHOLD = 20

GREEN, YELLOW, RED, DIM, RESET = "\033[32m", "\033[33m", "\033[31m", "\033[90m", "\033[0m"
bar_color = RED if pct >= 75 else YELLOW if pct >= 50 else GREEN

bar_width = 10
filled = pct * bar_width // 100
bar = f"{bar_color}{'━' * filled}{DIM}{'─' * (bar_width - filled)}{RESET}"

model = "" if "opus" in model_id else f"  {model_name}"

cost_fmt = f"  ${cost:.2f}" if cost >= COST_THRESHOLD else ""

print(
    f"{project}{model}  {bar} {DIM}{fmt_tokens(used)}/{fmt_tokens(ctx_size)}{cost_fmt}{RESET}"
)
