# Silverblue Enhanced

*A setup script for Fedora Silverblue that reflects my tastes.*

## Table of Contents
- [Introduction](#introduction)
- [Screenshots](#screenshots)
- [Usage](#Usage)
    - [Setup](#shortcuts)
    - [Shortcuts](#shortcuts)

## Introduction

This is a script and only a script. Without overlays, it is mostly backed by upstream Fedora Atomic. I've written it to fit GNOME to my preferences, among these are:

- **Blur My Shell, Dash to Dock, other extensions**
- **elementary OS default wallpapers**
- **Zen as the default web browser**
- **VSCodium and VLC (with codecs) from Flathub**

## Screenshots

![Screenshot](assets/screenshot1.png)

![Screenshot](assets/screenshot2.png)

## Usage

### Setup

1. Disable suspension on settings.
2. Run the setup script:
```bash
git clone https://github.com/notawyvern/silverblue-enhanced &&
bash ./silverblue-enhanced/setup-silverblue.sh 
```
3. Enter your password and wait for reboot.

### Shortcuts

- **Super+f**: nautilus
- **Super+t**: new terminal window
- **Super+b**: zen browser