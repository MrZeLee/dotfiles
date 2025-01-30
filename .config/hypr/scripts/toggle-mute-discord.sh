#!/usr/bin/env bash

hyprctl dispatch focuswindow initialtitle:^Discord$ -q
hyprctl dispatch sendshortcut CTRL_SHIFT, M, initialtitle:^Discord$ -q
hyprctl dispatch focuscurrentorlast -q

