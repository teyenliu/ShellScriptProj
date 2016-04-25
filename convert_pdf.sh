#!/bin/sh

if [[ $# -le 0 ]]; then
  echo "usage: $0 [files]"
  exit 1
fi

echo "$# Files to convert"

for i in $@; do
  folder=echo $i | sed s/\.pdf$//g
  echo "$folder"
  mkdir $folder

  echo "Phase 1: Render PDF pages to JPEG images..."
  # change .jpg to .png to render pages to PNG images
  # you can also specify -quality &lt;1..100&gt; option for image compression quality
  convert -density 150 $i $folder/$i.jpg

  echo "Phase 2: Print images into PDF"
  # if you have changed the intermediate file extension above,
  # you need to change the extension here, too.
  convert -page A4 $folder/\*.jpg scanned/$folder.pdf

  rm -rf $folder
done