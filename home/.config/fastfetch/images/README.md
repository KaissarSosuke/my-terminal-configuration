# Fastfetch logo

`current.png` is the image displayed by `~/.config/fastfetch/config.jsonc`.
The bundled image is a sample; replace it with an image you have the rights to
use. The same image is shown in the repository's main README as
`assets/fastfetch-logo.png`.

## Change the image

Replace `current.png` with any PNG, preferably a portrait image with a
transparent background, then run:

```sh
cp /path/to/image.png ~/.config/fastfetch/images/current.png
fastfetch
```

The layout uses `width: 22` and `height: 13` character cells, which matches
the 85-column Kitty window and the current image's aspect ratio. Fastfetch
renders it with the `kitty-direct` protocol, so Kitty reads the file directly
and does not need ImageMagick.

## Missing image / reset

If `current.png` is missing or unreadable, fastfetch falls back to its
built-in logo instead of failing the fetch.

To restore the placeholder image:

```sh
cp ~/.config/fastfetch/images/default.png \
   ~/.config/fastfetch/images/current.png
```
