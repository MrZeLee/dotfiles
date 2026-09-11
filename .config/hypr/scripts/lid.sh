#!/usr/bin/env bash

# Lid switch: drop the internal screen and keep the external monitor on the
# workspace it already had (Hyprland would otherwise focus the one moved over
# from eDP-1).
#   lid.sh on   -> lid closed
#   lid.sh off  -> lid opened

EDP_RULE="eDP-1,2560x1600@119.93Hz,0x0,1"

case "$1" in
on)
  ws=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")][0].activeWorkspace.id')
  hyprctl keyword monitor "eDP-1,disable"
  # keyword is applied on the next compositor tick; wait for eDP-1 to be gone
  for _ in $(seq 20); do
    hyprctl monitors -j | jq -e 'any(.[]; .name == "eDP-1")' >/dev/null || break
    sleep 0.1
  done
  [ "$ws" != null ] && hyprctl dispatch workspace "$ws"
  ;;
off)
  hyprctl keyword monitor "$EDP_RULE"
  ;;
esac
