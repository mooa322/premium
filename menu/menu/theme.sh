#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Retro-Futuristic / Cyberpunk Terminal UI Theme
# Neon gradient frames · monospaced layout · pitch black
# Sourced by menu/menu/menu — provides:
#   neon_box_top <width> [color]   -> top frame (gradient start)
#   neon_box_mid                   -> side padding helper
#   neon_box_bot <width> [color]   -> bottom frame (gradient end)
#   neon_header <text> <width>     -> solid-block section header
#   neon_bar <percent> <width>     -> animated-style progress bar
#   kv_line <label> <value>        -> "» label : value" row
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ── Neon palette ───────────────────────────────────────
NPURPLE=$'\033[1;95m'    # bright neon purple
NCYN=$'\033[1;96m'       # neon cyan
NLIME=$'\033[1;92m'      # lime green
NORANGE=$'\033[1;93m'    # vivid orange
NGOLD=$'\033[1;33m'      # gold
NBLUE=$'\033[1;94m'      # neon blue
NPINK=$'\033[1;95m'      # magenta/pink
NRED=$'\033[1;91m'       # neon red
NWHITE=$'\033[1;97m'
NGRAY=$'\033[0;37m'
NOFF=$'\033[0m'

# background blocks for headers
BG_PURPLE=$'\033[1;30;45m'   # white-on-purple  (solid purple block)
BG_CYAN=$'\033[1;30;46m'     # black-on-cyan
BG_BLUE=$'\033[1;37;44m'

TUI_WIDTH=68                # inner width of the main frames

# ── Gradient frame characters ─────────────────────────
# top frame: purple -> cyan fade, bottom frame: cyan -> purple fade
neon_grad() {  # neon_grad <len> <c1> <c2> — two-color horizontal fade
    local len=$1 c1=$2 c2=$3 half=$(( len / 2 )) i
    for ((i=0; i<len; i++)); do
        if (( i < half )); then printf "${c1}━${NOFF}"; else printf "${c2}━${NOFF}"; fi
    done
}

neon_box_top() {  # neon_box_top [width] [left color] [right color]
    local w=${1:-$TUI_WIDTH} lc=${2:-$NPURPLE} rc=${3:-$NCYN}
    printf " ${lc}┏${NOFF}"; neon_grad "$w" "$lc" "$rc"; printf "${rc}┓${NOFF}\n"
}

neon_box_bot() {  # neon_box_bot [width] [left color] [right color]
    local w=${1:-$TUI_WIDTH} lc=${2:-$NCYN} rc=${3:-$NPURPLE}
    printf " ${lc}┗${NOFF}"; neon_grad "$w" "$lc" "$rc"; printf "${rc}┛${NOFF}\n"
}

neon_row() {  # neon_row "<already colored content>" [width] — pads + side rails
    local txt=$1 w=${2:-$TUI_WIDTH}
    # visible length: strip ANSI escapes
    local plain vis
    plain=$(printf '%b' "$txt" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
    vis=$(printf '%s' "$plain" | wc -m)
    local pad=$(( w - vis ))
    (( pad < 0 )) && pad=0
    printf " ${NPURPLE}│${NOFF}%b%*s ${NPURPLE}│${NOFF}\n" "$txt" "$pad" ""
}

neon_header() {  # neon_header "TEXT" [width] [bg] — centered solid-block heading with neon rules
    local txt="$1" w=$(( ${2:-$TUI_WIDTH} + 3 )) bg=${3:-$BG_PURPLE}
    local inner=" ${txt} "
    local rem=$(( w - ${#inner} ))
    (( rem < 0 )) && rem=0
    local left=$(( rem / 2 )) right=$(( rem - left ))
    local ll="" rl="" i
    for ((i=0;i<left;i++));  do ll+="═"; done
    for ((i=0;i<right;i++)); do rl+="═"; done
    printf "${NPURPLE}%s${NOFF}${bg}%s${NOFF}${NCYN}%s${NOFF}\n" "$ll" "$inner" "$rl"
}

neon_bar() {  # neon_bar <percent> [width] — neon progress bar
    local pct=${1:-0} w=${2:-20}
    [[ "$pct" =~ ^[0-9.]+ ]] || pct=0
    local filled=$(awk -v p="$pct" -v w="$w" 'BEGIN{printf "%d", (p/100)*w + 0.5}')
    (( filled > w )) && filled=$w
    (( filled < 0 )) && filled=0
    local empty=$(( w - filled ))
    local bar=""
    local i
    for ((i=0;i<filled;i++)); do bar+="${NCYN}█${NOFF}"; done
    for ((i=0;i<empty;i++));  do bar+="${NGRAY}░${NOFF}"; done
    printf " ${NCYN}[${NOFF}%s${NCYN}]${NOFF} ${NLIME}%s%%${NOFF}" "$bar" "$pct"
}

kv_line() {  # kv_line "LABEL" "VALUE" — » gold prefix, blue label, lime value (framed row)
    neon_row "  ${NGOLD}»${NOFF} ${NBLUE}$1${NOFF} ${NGOLD}:${NOFF} ${NLIME}$2${NOFF}"
}

svc_box() {  # svc_box <name> <status> <border color> — small service tile (raw text name)
    local name="$1" st="$2" col="$3"
    local w=20
    local status_col="$NLIME"; [[ "$st" != "ON" ]] && status_col="$NRED"
    local npad=$(( (w - ${#name}) / 2 ))
    local nright=$(( w - npad - ${#name} ))
    local stxt=": $st"
    local sp=$(( (w - ${#stxt}) / 2 ))
    local sright=$(( w - sp - ${#stxt} ))
    printf "${col}┌━━━━━━━━━━━━━━━━━━━━┐${NOFF}\n"
    printf "${col}│${NOFF}%*s${NWHITE}%s${NOFF}%*s${col}│${NOFF}\n" $npad "" "$name" $nright ""
    printf "${col}│${NOFF}%*s${NGOLD}:${NOFF} ${status_col}%s${NOFF}%*s${col}│${NOFF}\n" $((sp-1)) "" "$st" $((sright+1)) ""
    printf "${col}└━━━━━━━━━━━━━━━━━━━━┘${NOFF}\n"
}

menu_item() {  # menu_item <num> <text> [label color] — [01] neon-blue number + colored label
    local lc=${3:-$NGOLD}
    printf "${NBLUE}[${NOFF}${NRED}%02d${NOFF}${NBLUE}]${NOFF} ${lc}%s${NOFF}" "$1" "$2"
}

neon_solid_line() {  # neon_solid_line <width> <color> <char> — full-width rule (banner underline)
    local w=$1 col=${2:-$NPURPLE} ch=${3:-'━'} i s=''
    for ((i=0;i<w;i++)); do s+="$ch"; done
    printf " ${col}%s${NOFF}\n" "$s"
}

blink_cursor() {  # blinking block cursor for the prompt line
    printf "[?25h"
}
