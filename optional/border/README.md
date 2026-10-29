# Optional green border

The main install is borderless. This folder contains the optional frame used
in the repository screenshot.

```sh
cp green-frame.png ~/.config/kitty/
cp kitty-border.conf ~/.config/kitty/green-city-border.conf
printf '\ninclude green-city-border.conf\n' >> ~/.config/kitty/kitty.conf
```

Restart Kitty completely. The PNG draws the outer frame around a single
window; `window_border_width` in `kitty-border.conf` draws borders between
split panes.

See the **Optional green border** section in the main
[README](../../README.md#optional-green-border) for details.
