# Run in an isolated interactive Zsh: zsh -fic 'source tests/shell.zsh'
if [[ -n ${NEOTOKYO_TEST_ZSH_ROOT:-} ]]; then
    module_path=("$NEOTOKYO_TEST_ZSH_ROOT/usr/lib/x86_64-linux-gnu/zsh/5.9" $module_path)
    fpath=("$NEOTOKYO_TEST_ZSH_ROOT"/usr/share/zsh/functions/**/*(/N) $fpath)
fi
typeset test_root="${${(%):-%N}:A:h:h}"
typeset start_dir=$PWD
typeset -a original_path=($path)
source "$test_root/config/neotokyo.zsh"
fail() { print -u2 -r -- "FAIL: $*"; exit 1; }
[[ $PWD == $start_dir ]] || fail 'startup changed the directory'
[[ $HISTSIZE == 50000 && $SAVEHIST == 50000 ]] || fail 'history limits'
[[ -o sharehistory && -o histignorespace ]] || fail 'history settings'
[[ ${ZSH_AUTOSUGGEST_STRATEGY[*]} == 'history completion' ]] || fail 'suggestion strategy'
[[ $(bindkey '^[[A') == *up-line-or-beginning-search* ]] || fail 'prefix search'
[[ $(bindkey '^[[13;2u') == *_neotokyo_newline* ]] || fail 'multiline binding'
[[ $NEOTOKYO_HOME == "$test_root/config" ]] || fail 'source-relative config path'
for entry in $original_path; do
    (( ${path[(Ie)$entry]} )) || fail "PATH entry lost: $entry"
done
typeset -a captured
git() { captured=("$@"); }
eval "gco 'branch with spaces' --detach"
[[ ${captured[1]} == checkout && ${captured[2]} == 'branch with spaces' && ${captured[3]} == --detach ]] || fail 'Git arguments not preserved'
typeset before_fzf=${FZF_DEFAULT_OPTS:-}
source "$test_root/config/neotokyo.zsh"
[[ $FZF_DEFAULT_OPTS == $before_fzf ]] || fail 'loading twice duplicates options'
if (( $+functions[_zsh_autosuggest_strategy_history] )); then
    typeset history_fixture=$(mktemp)
    # Zsh's history parameter excludes the current (last) event.
    printf '%s\n' 'neotokyo-history-example --first' 'neotokyo-history-example --second' 'unrelated-current-command' > "$history_fixture"
    fc -p "$history_fixture"
    _zsh_autosuggest_strategy_history 'neotokyo-history-example'
    [[ $suggestion == 'neotokyo-history-example --second' ]] || fail "real history suggestions: actual=[$suggestion], history=[$(fc -l -5)]"
    fc -P
    rm -- "$history_fixture"
    print 'PASS: actual history plugin returns the most recent matching command'
fi
if (( $+commands[fzf] )); then
    [[ $(bindkey '^R') == *fzf-history-widget* ]] || fail 'fzf history binding'
    [[ $(printf 'neotokyo-filter-check\nother\n' | fzf --filter=neotokyo-filter-check) == neotokyo-filter-check ]] || fail 'fzf configuration'
fi
if (( $+commands[eza] )); then
    command eza --long --icons=always "$test_root/config" >/dev/null || fail 'eza theme or options'
fi
if (( $+functions[_zsh_highlight] )); then
    [[ ${ZSH_HIGHLIGHT_STYLES[command]} == 'fg=#FF79C6' ]] || fail 'syntax highlight palette'
fi
print 'PASS: Zsh startup, history, shortcuts, argument forwarding and repeated loading'
