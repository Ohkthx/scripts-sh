#!/bin/bash
if [[ $1 == "-h" || $1 == "--help" || $1 == "" ]]; then
  echo -e "  Proper syntax:   \"strip-audio.sh   [website]   [folder]\""
  exit
fi
echo -e "\n [+]  Starting Download.\n"

music_path=$HOME/media/music
echo $music_path

if [[ $1 == "" ]]; then
  echo -en "URL: "
  read path
else
  path=$1
fi

if [[ $2 == "" ]]; then
  echo -en "Folder [default: stripped]: "
  read folder
else
  folder=$2
fi

if [[ $folder == "" ]]; then
  folder=stripped
fi

if [[ ! -d $music_path/$folder ]]; then
  mkdir -v  $music_path/$folder
fi

cd $music_path/$folder
youtube-dl -x --audio-format mp3 --audio-quality 0 $path
echo -e "\n [+]  Music saved: $music_path/$folder"
