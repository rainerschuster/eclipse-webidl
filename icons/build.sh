
# Branding - Window Images
convert logo.svg -resize 16x16 eclipse16.gif
convert logo.svg -resize 32x32 eclipse32.gif
convert logo.svg -resize 48x48 eclipse48.gif
convert logo.svg -resize 16x16 eclipse16.png
convert logo.svg -resize 32x32 eclipse32.png
convert logo.svg -resize 48x48 eclipse48.png
convert logo.svg -resize 64x64 eclipse64.png
convert logo.svg -resize 128x128 eclipse128.png
convert logo.svg -resize 256x256 eclipse256.png


# Launching - Program Launcher
# Linux
convert logo.svg -resize 256x256 icon.xpm
# Mac OS X
convert logo.svg -resize 16x16 icon_16x16.png
convert logo.svg -resize 32x32 icon_16x16@2x.png
convert logo.svg -resize 32x32 icon_32x32.png
convert logo.svg -resize 128x128 icon_32x32@2x.png
convert logo.svg -resize 128x128 icon_128x128.png
convert logo.svg -resize 256x256 icon_128x128@2x.png
convert logo.svg -resize 256x256 icon_256x256.png
convert logo.svg -resize 512x512 icon_256x256@2x.png
convert logo.svg -resize 512x512 icon_512x512.png
convert logo.svg -resize 1024x1024 icon_512x512@2x.png
convert logo.svg Eclipse.icns
# Solaris
convert logo.svg Eclipse.l.pm
convert logo.svg Eclipse.m.pm
convert logo.svg Eclipse.s.pm
convert logo.svg Eclipse.t.pm
# Windows
convert logo.svg -resize 16x16 -type Palette -colors 255 icon_16x16_8bit.bmp
convert logo.svg -resize 32x32 -type Palette -colors 255 icon_32x32_8bit.bmp
convert logo.svg -resize 48x48 -type Palette -colors 255 icon_48x48_8bit.bmp
convert logo.svg -resize 16x16 icon_16x16_32bit.bmp
convert logo.svg -resize 32x32 icon_32x32_32bit.bmp
convert logo.svg -resize 48x48 icon_48x48_32bit.bmp
convert logo.svg -resize 256x256 icon_256x256_32bit.bmp
convert icon_16x16_8bit.bmp icon_16x16_32bit.bmp icon_32x32_8bit.bmp icon_32x32_32bit.bmp icon_48x48_8bit.bmp icon_48x48_32bit.bmp icon_256x256_32bit.bmp eclipse.ico

