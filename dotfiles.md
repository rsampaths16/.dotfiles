---
title: How I setup my dotfiles
date: Tuesday 27 April 2021 02:34:28 PM IST
---
# How I setup my dotfiles

## Problems
### How to bootstrap properly?

1. How do I set the `$DOTFILES` directory properly.
I'm starting my dotfiles journey by trying to setup my nvim configuration.
A problem that I've faced right now is how to set the $DOTFILES directory?

present working directory `$(pwd)` isn't working as it changes according to
where the script is run, instead of where the script actually is.

```bash
cd "$(dirname "$0")/.."
DOTFILES=$(pwd -P)
```

2. ln -sf $dir1 $dir2 behaves abnormally when $dir2 already exists
if $dir2 already exists a link to $dir1 is put inside $dir1
```
ln -s -T TARGET LINK_NAME # treats target as a name
```
