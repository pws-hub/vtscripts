#!/usr/bin/env bash
set -e

source="${1}"
target="${2}"
_title="${3}"
_author="${4}"
_date="$(date +%F-%T)"
_copyright="Web-Micros; ${APPNAME}/${APPVERSION} - $(date +%Y)"
_watermark=${HLS_WATERMARK_SOURCE}

sourceResolution="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 ${source})"
arrIN=(${sourceResolution//x/ })
sourceWidth="${arrIN[0]}"
sourceHeight="${arrIN[1]}"
watermarkWidth="$(echo "scale=3; ($sourceWidth / 1920) * 65" | bc)"
watermarkWidth=${watermarkWidth%.*}

echo $watermarkWidth
if [ $((watermarkWidth % 2)) -ne 0 ];then
  echo "width is odd."
  watermarkWidth=$((watermarkWidth - 1))
fi
echo $watermarkWidth

# Add Metadata and Watermark to the video source
ffmpeg -hide_banner -y -i ${source} -i ${_watermark} -metadata title="${_title}" -metadata author="${_author}" -metadata date="${_date}" -metadata copyright="${_copyright}" -filter_complex "[1:v]scale=${watermarkWidth}:-1[wm];[0:v][wm]overlay=15:15" -crf ${HLS_CRF} ${target}