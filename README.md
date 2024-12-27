# dotfiles

## GPG

when gpg has problems commiting try this:
```
gpg-connect-agent reloadagent /bye
```

## SSH

when adding a ssh key that is going to be used in the git clone don't forget to add it to the ssh-agent:
```
ssh-add [path-to-private-key]
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

