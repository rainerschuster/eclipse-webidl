
# Branding - Window Images
convert -background none -resize 16x16 logo.svg eclipse16.gif
convert -background none -resize 32x32 logo.svg eclipse32.gif
convert -background none -resize 48x48 logo.svg eclipse48.gif
convert -background none -resize 16x16 logo.svg eclipse16.png
convert -background none -resize 32x32 logo.svg eclipse32.png
convert -background none -resize 48x48 logo.svg eclipse48.png
convert -background none -resize 64x64 logo.svg eclipse64.png
convert -background none -resize 128x128 logo.svg eclipse128.png
convert -background none -resize 256x256 logo.svg eclipse256.png


# Launching - Program Launcher
# Linux
convert -background none -resize 256x256 logo.svg icon.xpm
# Mac OS X
convert -background none -resize 16x16 logo.svg icon_16x16.png
convert -background none -resize 32x32 logo.svg icon_16x16@2x.png
convert -background none -resize 32x32 logo.svg icon_32x32.png
convert -background none -resize 128x128 logo.svg icon_32x32@2x.png
convert -background none -resize 128x128 logo.svg icon_128x128.png
convert -background none -resize 256x256 logo.svg icon_128x128@2x.png
convert -background none -resize 256x256 logo.svg icon_256x256.png
convert -background none -resize 512x512 logo.svg icon_256x256@2x.png
convert -background none -resize 512x512 logo.svg icon_512x512.png
convert -background none -resize 1024x1024 logo.svg icon_512x512@2x.png
convert -background none logo.svg Eclipse.icns
# Solaris
#convert -background none logo.svg Eclipse.l.pm
#convert -background none logo.svg Eclipse.m.pm
#convert -background none logo.svg Eclipse.s.pm
#convert -background none logo.svg Eclipse.t.pm
# Windows
convert -background none -resize 16x16 -type Palette -colors 255 -channel Alpha logo.svg icon_16x16_8bit.bmp
convert -background none -resize 32x32 -type Palette -colors 255 -channel Alpha logo.svg icon_32x32_8bit.bmp
convert -background none -resize 48x48 -type Palette -colors 255 -channel Alpha logo.svg icon_48x48_8bit.bmp
convert -background none -resize 16x16 logo.svg icon_16x16_32bit.bmp
convert -background none -resize 32x32 logo.svg icon_32x32_32bit.bmp
convert -background none -resize 48x48 logo.svg icon_48x48_32bit.bmp
convert -background none -resize 256x256 logo.svg icon_256x256_32bit.bmp
convert icon_16x16_8bit.bmp icon_16x16_32bit.bmp icon_32x32_8bit.bmp icon_32x32_32bit.bmp icon_48x48_8bit.bmp icon_48x48_32bit.bmp icon_256x256_32bit.bmp eclipse.ico



cp icon.xpm ../com.rainerschuster.epp.package.webidl.product/icons/
#cp Eclipse.icns ../com.rainerschuster.epp.package.webidl.product/icons/
#cp Eclipse.*.pm ../com.rainerschuster.epp.package.webidl.product/icons/
#cp eclipse.ico ../com.rainerschuster.epp.package.webidl.product/icons/
cp icon_*.bmp ../com.rainerschuster.epp.package.webidl.product/icons/
cp eclipse*.gif ../com.rainerschuster.epp.package.webidl/icons/
cp eclipse*.png ../com.rainerschuster.epp.package.webidl/icons/
cp eclipse16.png ../com.rainerschuster.epp.package.webidl/eclipse16.png
cp eclipse32.png ../com.rainerschuster.epp.package.webidl/eclipse32.png
cp eclipse48.png ../com.rainerschuster.epp.package.webidl/eclipse48.png
cp eclipse256.png ../com.rainerschuster.epp.package.webidl/eclipse256.png
cp eclipse32.png ../com.rainerschuster.webidl.ui/icons/logo.png

