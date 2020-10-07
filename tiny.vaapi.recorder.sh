#!/bin/bash
# Script using YAD and FFMPEG to make GUI to record screen
# Install the dependencies:
# $ sudo apt install yad xterm ffmpeg
# Philippe734 @ 2020

defaultpath="$HOME"
apptitle="Tiny VAAPI recorder"
filenameoutput="record"_$(date +"%m%d%H%M%S")".mkv"

formmain ()
{
yad --width=100 --center --title="$apptitle" \
--text="Record screen with hardware encoding using h264, vaapi and ffmpeg to mkv. Select path to save output before press ready.\nOutput will be save as:\n$defaultpath/$filenameoutput" \
--image="media-tape" \
--window-icon="media-tape" \
--form --field="Resolution":CBE \
'1920x1080!1280x720!1366x768!1024x768!800x600!other' \
--button="Cancel":1  \
--button="Ready and minimize":2 \
--button="Select path":3
}

formselectpath ()
{
yad --file --directory --width=600 --height=400 --title=Path
}

forminprogress ()
{
(
echo "# To stop recording, show the minimized Xterm then Ctrl+C"
echo "99" ; sleep 1
echo "90" ; sleep 1
echo "80" ; sleep 1
echo "70" ; sleep 1
echo "60" ; sleep 1
echo "50" ; sleep 1
echo "40" ; sleep 1
echo "30" ; sleep 1
echo "20" ; sleep 1
echo "10" ; sleep 1
echo "00" : sleep 0.2
echo "100"
) | yad --progress --title="10 seconds before record" --width=400 --height=50 --no-buttons --center --fixed --auto-close
}

begin ()
{
resolution=$(formmain)
button=$?
resolution=$(echo $resolution | cut -d'|' -f 1)
if [ "$button" = 3 ]; then
  # Path to select
  defaultpath=$(formselectpath)
  begin
elif [ "$button" = 1 ]; then
  exit 0
fi
}

begin

forminprogress

# Command to record at bitrate
#xterm -iconic -e "ffmpeg -vaapi_device /dev/dri/renderD128 -f x11grab -video_size $resolution -i :0 -vf 'hwupload,scale_vaapi=format=nv12' -c:v h264_vaapi -b:v 20M -preset superfast '$defaultpath/$filenameoutput'"

# To record with a quality level near lossless
xterm -iconic -e "ffmpeg -vaapi_device /dev/dri/renderD128 -f x11grab -video_size $resolution -i :0 -vf 'hwupload,scale_vaapi=format=nv12' -c:v h264_vaapi -qp 17 -preset ultrafast '$defaultpath/$filenameoutput'"

exit 0

