#!/usr/bin/env bash
START_TIME=$SECONDS
set -e

echo "-----START EXTRACTING ASSETS-----"
# Usage extract-assets.sh SOURCE_FILE [OUTPUT_NAME]
[[ ! "${1}" ]] && echo "Usage: extract-assets.sh SOURCE_FILE [OUTPUT_NAME]" && exit 1

source="${1}"
target="${2}"
_title="${3}"
_author="${4}"
_date="$(date +%F-%T)"
_copyright="Web-Micros; ${APPNAME}/${APPVERSION} - $(date +%Y)"

sourceDuration="$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of csv=s=x:p=0 ${source})"
toInt=${sourceDuration%.*}
echo -e "Duration: ${toInt}"

# Number of thumbnail to extract
tbVars="[screen0]"

# timemark as each thumbnail extraction
timemarkUnit=$((${toInt} / 6))
timemark=0

# concat extraction command
vFrameCmd="-vframes 1 -map ${tbVars} ${target}/poster-1.jpg"

for i in {1..5}; do
    timemark=$((${timemark} + ${timemarkUnit}))
    tbVars+="[screen$i]"
    vFrameCmd+=" -vframes 1 -map [screen$i] -ss ${timemark} ${target}/poster-$(($i + 1)).jpg"
done

# Misc params
misc_params="-filter_complex scale=w=640:h=360[size0];[size0]split=6${tbVars}"

# Create output directory (target) if not exists
mkdir -p ${target}
# Start extraction
echo -e "Executing command:\nffmpeg -i ${source} ${misc_params} ${metadata_params} -aq 5 -vn ${target}/audio.ogg -crf ${HLS_CRF} ${vFrameCmd}\n"
ffmpeg -hide_banner -y -i ${source} ${misc_params} -metadata title="${_title}" -metadata author="${_author}" -metadata date="${_date}" -metadata copyright="${_copyright}" -aq 5 -vn ${target}/audio.ogg -crf ${HLS_CRF} ${vFrameCmd}

ELAPSED_TIME=$(($SECONDS - $START_TIME))

echo "Elapsed time: ${ELAPSED_TIME}"
echo "-----FINISH EXTRACTING ASSETS-----"