#!/usr/bin/env bash

set -e

function make_style
{
    echo "#[${1//,/]#[}]"
}

# The placeholder that will be replaced with the Tmux mode indicator
mode_indicator_placeholder='\#{mode_indicator}'

# Get the user-defined values.
tmux_value=$(tmux show -gqv '@mode_indicator_tmux_value')
wait_value=$(tmux show -gqv '@mode_indicator_wait_value')
copy_value=$(tmux show -gqv '@mode_indicator_copy_value')
sync_value=$(tmux show -gqv '@mode_indicator_sync_value')

# Get the user-defined styles.
tmux_style=$(tmux show -gqv '@mode_indicator_tmux_style')
wait_style=$(tmux show -gqv '@mode_indicator_wait_style')
copy_style=$(tmux show -gqv '@mode_indicator_copy_style')
sync_style=$(tmux show -gqv '@mode_indicator_sync_style')

# Get the formats of the left/right status strings.
status_l_format=$(tmux show -gqv status-left)
status_r_format=$(tmux show -gqv status-right)

# Use the default in case of no user-defined value.
tmux_value="${tmux_value:- TMUX }"
wait_value="${wait_value:- WAIT }"
copy_value="${copy_value:- COPY }"
sync_value="${sync_value:- SYNC }"

# Use the default in case of no user-defined style.
tmux_style=$(make_style "${tmux_style:-fg=black,bg=green}")
wait_style=$(make_style "${wait_style:-fg=black,bg=cyan}")
copy_style=$(make_style "${copy_style:-fg=black,bg=yellow}")
sync_style=$(make_style "${sync_style:-fg=black,bg=red}")

#
# This is essentially a big nested ternary expression in Tmux syntax.
#
# i.e. (is_wait_mode) ? ... : (is_copy_mode) ? ... : (is_sync_mode) ? ... : ...
#
mode_value="#{?client_prefix,$wait_value,#{?pane_in_mode,$copy_value,#{?pane_synchronized,$sync_value,$tmux_value}}}"
mode_style="#{?client_prefix,$wait_style,#{?pane_in_mode,$copy_style,#{?pane_synchronized,$sync_style,$tmux_style}}}"

# Reset style, set our style, print our value, reset style.
mode_indicator="#[default]$mode_style$mode_value#[default]"

#
# Replace all occurrences of `$mode_indicator_placeholder` with `$mode_indicator` in the left/right
# status strings and set these options to their new values.
#
tmux set -gq status-left  "${status_l_format/$mode_indicator_placeholder/$mode_indicator}"
tmux set -gq status-right "${status_r_format/$mode_indicator_placeholder/$mode_indicator}"
