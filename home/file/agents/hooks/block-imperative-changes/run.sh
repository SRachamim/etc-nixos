# Blocks shell commands that mutate this Nix-managed machine outside the
# flake. Only command positions count, so a banned phrase inside quoted
# text (a commit message, an echo) passes.
cmd=$(jq -r '.tool_input.command // .command // .toolCall.args.CommandLine // .toolCall.args.command // empty')
[ -n "$cmd" ] || exit 0

unquoted=$(printf '%s' "$cmd" | sed -E "s/'[^']*'//g; s/\"([^\"\\\\]|\\\\.)*\"//g")

start='(^|[;&|(]|\$\()[[:space:]]*(sudo[[:space:]]+)?'
bans=(
  '(darwin|nixos)-rebuild[[:space:]]+(switch|activate|boot|test)'
  'home-manager[[:space:]]+switch'
  'switch([[:space:]]|$)'
  'brew[[:space:]]+(install|reinstall|upgrade|tap)'
  'apt(-get)?[[:space:]]+install'
  'dnf[[:space:]]+install'
  'pacman[[:space:]]+-S'
  'npm[[:space:]]+(install|i|add)[[:space:]]([^;&|]*[[:space:]])?(-g|--global)'
  'pip3?[[:space:]]+install[[:space:]]([^;&|]*[[:space:]])?--user'
  'defaults[[:space:]]+write'
  'gsettings[[:space:]]+set'
  'systemctl[[:space:]]+(--user[[:space:]]+)?enable'
  'launchctl[[:space:]]+(load|bootstrap)'
)

for ban in "${bans[@]}"; do
  if match=$(printf '%s\n' "$unquoted" | grep -oE "$start$ban" | head -1); [ -n "$match" ]; then
    {
      echo "Blocked: '${match#"${match%%[![:space:];&|(]*}"}' changes this machine outside the Nix flake."
      echo "Make the change declaratively (see 'Where to make changes' in the dotfiles AGENTS.md) and ask the user to run \`switch\`."
    } >&2
    exit 2
  fi
done
