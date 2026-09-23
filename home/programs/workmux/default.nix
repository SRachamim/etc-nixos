# workmux: git worktrees + tmux windows + agents (https://workmux.raine.dev).
# Trialled alongside Agent of Empires; the binary comes from Homebrew
# (modules/darwin/homebrew.nix) so it tracks upstream's latest release.
{ config, pkgs, lib, ... }:
let
  brewBin = "/opt/homebrew/bin/workmux";

  # Same palette source catppuccin/nix's own modules read, so workmux follows
  # catppuccin.flavor and catppuccin.accent without a hardcoded flavor.
  palette = (lib.importJSON "${config.catppuccin.sources.palette}/palette.json")
    .${config.catppuccin.flavor}.colors;
  hex = name: palette.${name}.hex;
  accent = hex config.catppuccin.accent;

  # tmux style codes render in both the status bar and the dashboard.
  statusIcon = color: glyph: "#[fg=${hex color}]${glyph}#[fg=default]";

  # Bundled with the binary (src/skills.rs). Only `coordinator` is
  # model-invocable; the rest set disable-model-invocation.
  skills = [ "workmux" "worktree" "coordinator" "merge" "rebase" "open-pr" ];

  # Mirrors upstream's .claude-plugin/plugin.json. `workmux setup --hooks`
  # reports "update available" if upstream changes them.
  hook = command: { type = "command"; inherit command; };
  status = state: hook "workmux set-window-status ${state}";
in
{
  # Homebrew binaries are not on the Nix-managed PATH for non-login shells
  # (tmux run-shell, agent hooks); the wrapper lands in the profile.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "workmux";
      text = ''
        if [ ! -x "${brewBin}" ]; then
          echo "workmux: not installed — run switch to install via Homebrew" >&2
          exit 127
        fi
        exec "${brewBin}" "$@"
      '';
    })
  ];

  xdg.configFile."workmux/config.yaml".source = (pkgs.formats.yaml { }).generate "workmux-config.yaml" {
    # Set explicitly: the first-run prompt cannot write to this read-only file.
    nerdfont = true;
    agent = "claude";
    # Relative to the main worktree: siblings of `main`, next to the
    # worktree-layout-g checkouts.
    worktree_dir = "..";
    panes = [
      { command = "<agent>"; focus = true; }
      { split = "horizontal"; }
    ];

    # The catppuccin tmux window text carries @workmux_status itself;
    # workmux's own injection would override the themed format.
    status_format = false;
    status_icons = {
      working = statusIcon "peach" "󰔠";
      waiting = statusIcon "yellow" "󰀪";
      done = statusIcon "green" "󰄴";
    };

    theme = {
      mode = if config.catppuccin.flavor == "latte" then "light" else "dark";
      custom = {
        text = hex "text";
        current_row_bg = hex "surface0";
        highlight_row_bg = hex "surface1";
        current_worktree_fg = accent;
        dimmed = hex "overlay0";
        border = hex "surface2";
        help_border = hex "overlay1";
        help_muted = hex "subtext0";
        header = hex "blue";
        keycap = hex "peach";
        info = hex "sky";
        success = hex "green";
        warning = hex "yellow";
        danger = hex "red";
        inherit accent;
      };
    };
  };

  programs.claude-code.settings.hooks = {
    SessionStart = [{ matcher = "startup|resume|clear|fork"; hooks = [ (hook "workmux register-agent") ]; }];
    UserPromptSubmit = [{ hooks = [ (status "working") ]; }];
    PostToolUse = [{ hooks = [ (status "working") ]; }];
    Notification = [{ matcher = "permission_prompt|elicitation_dialog"; hooks = [ (status "waiting") ]; }];
    Stop = [{ hooks = [ (status "done") ]; }];
  };

  # Skills are fetched from the release tag matching the installed binary, so
  # they stay in step with Homebrew upgrades without pinning a version here.
  home.activation.installWorkmuxSkills = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x "${brewBin}" ]; then
      wmVersion=$("${brewBin}" --version | ${pkgs.gawk}/bin/awk '{print $NF}')
      for skill in ${lib.escapeShellArgs skills}; do
        dir="$HOME/.claude/skills/$skill"
        tmp=$(mktemp)
        if ${pkgs.curl}/bin/curl -fsSL \
            "https://raw.githubusercontent.com/raine/workmux/v$wmVersion/skills/$skill/SKILL.md" \
            -o "$tmp"; then
          run mkdir -p "$dir"
          run mv "$tmp" "$dir/SKILL.md"
        else
          rm -f "$tmp"
          verboseEcho "workmux: could not fetch skill $skill for v$wmVersion"
        fi
      done
    else
      verboseEcho "workmux: not installed yet; skills are fetched on the next switch"
    fi
  '';

  programs.zsh.shellAliases.wm = "workmux";

  # Upstream suggests C-s / L / Tab, which resurrect, switch-client -l and
  # extrakto already own here.
  programs.tmux.extraConfig = ''
    # --- workmux ---
    bind g   display-popup -E -w 90% -h 80% "workmux dashboard"
    bind a   run-shell "workmux last-done"
    bind A   run-shell "workmux last-agent"
    bind C-t run-shell "workmux sidebar"
  '';
}
