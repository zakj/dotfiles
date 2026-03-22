#!/usr/bin/env python3
import json
import os
import sys

MAX_CTX = 250_000  # API reports up to 1M; real usable cap is lower
COST_THRESHOLD = 200
BAR_WIDTH = 10

GREEN, YELLOW, RED, DIM, RESET = (
    "\033[32m",
    "\033[33m",
    "\033[31m",
    "\033[90m",
    "\033[0m",
)

data = json.load(sys.stdin)


def pluck(path: str):
    val = data
    for key in path.split("."):
        if isinstance(val, dict):
            val = val.get(key)
        else:
            return None
    return val


def fmt_tokens(t: int) -> str:
    return f"{t // 1000}k" if t >= 1000 else str(t)


model_id = pluck("model.id") or ""
model_name = pluck("model.display_name") or ""
project = os.path.basename(pluck("workspace.project_dir") or pluck("cwd") or "")

TOKEN_KEYS = ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens")
tokens_used = sum(pluck(f"context_window.current_usage.{k}") or 0 for k in TOKEN_KEYS)
context_size = min(pluck("context_window.context_window_size") or 200_000, MAX_CTX)
percent = tokens_used * 100 // context_size
total_cost = pluck("cost.total_cost_usd") or 0

bar_color = RED if percent >= 75 else YELLOW if percent >= 50 else GREEN
filled = min(percent, 100) * BAR_WIDTH // 100
bar = f"{bar_color}{'━' * filled}{DIM}{'─' * (BAR_WIDTH - filled)}{RESET}"

model = "" if "opus" in model_id else f"  {model_name}"
cost_label = f"  ${total_cost:.2f}" if total_cost >= COST_THRESHOLD else ""

print(f"{project}{model}  {bar} {DIM}{fmt_tokens(context_size)}{cost_label}{RESET}")
