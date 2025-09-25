[user]
    name = YOUR_NAME
    email = YOUR_EMAIL
    signingkey = YOUR_SIGNING_KEY
[commit]
    gpgsign = true
[tag]
    gpgsign = true
[alias]
    co = checkout
    st = status
    ci = commit
    rm-submodule = "!f(){ git rm -rf \"$1\";git config -f .gitmodules --remove-section \"submodule.$1\";git config -f .git/config --remove-section \"submodule.$1\";git add .gitmodules; }; f"
[color]
    diff = auto
    status = auto
    branch = auto
[core]
    excludesfile = ~/.gitignore
    editor = nvim
    autocrlf = input
[pull]
    rebase = true
[push]
    default = current
[format]
    pretty = %C(yellow)%h%Creset %s %C(red)(%an, %cr)%Creset
[github]
    user = YOUR_GITHUB_USERNAME
[web]
    browser = chromium-browser

# Work profile - automatically used in work directories
[includeIf "gitdir:YOUR_WORK_PATH/"]
    path = ~/.gitconfig-work