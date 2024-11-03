# dotfiles

## GPG

when gpg has problems commiting try this:
```
gpg-connect-agent reloadagent /bye
```

## Nix install flake
```
darwin-rebuild switch --flake .#macos --impure
```
 the --impure is used to get access to ENV variables

## Neovim

Dependencies:

- nix-env -i yarn
- nix-env -i nodejs
- npm install -g typescript-language-server typescript
- nix-env ripgrep

