#!/bin/bash

DOME_DIMMING_FACTOR=2.28

last_ambient_lux=`echo "select * from ambient_sensor order by time desc limit 1;" | mysql -uallsky -pallsky allsky | tail -n1 | awk '{print $3}'`
last_ambient_lux=`bc <<< "scale=2; ${last_ambient_lux}/1"`
last_ambient_lux_for_iso=${last_ambient_lux%.*}

ISO_VALUE=100
EXPOCORRECTION=-2

if [ $last_ambient_lux_for_iso -lt 19 ]; then
        echo "Ambient lux="$last_ambient_lux
        echo "Setting ISO=200"
        ISO_VALUE=200
        EXPOCORRECTION=0
fi

if [ $last_ambient_lux_for_iso -gt 10000 ]; then
		echo "Ambient lux="$last_ambient_lux
		echo "Correcting EV to -5"
        EXPOCORRECTION=-4
fi

raspistill -ev $EXPOCORRECTION -w 1024 -h 768 -sh 60 --awb auto -ISO $ISO_VALUE -sa 40 -o /storage/web/__cam2.jpg

last_temp_humidity=`echo "select * from external_dh22 order by time desc limit 1;" | mysql -uallsky -pallsky allsky | tail -n1`

last_temp=`echo ${last_temp_humidity} | awk '{print $3}'`
last_temp=`bc <<< "scale=2; ${last_temp}/1"`

last_humidity=`echo ${last_temp_humidity} | awk '{print $4}'`
last_humidity=`bc <<< "scale=2; ${last_humidity}/1"`

current_date_time=`date +"%d.%m.%Y %H:%M"`

convert -background '#00000080' -fill white -size 1024x45 label:"Nauchniy - CAM2\nDate: ${current_date_time}  Temperature: ${last_temp} C  Humidity: ${last_humidity} %  Luminosity: ${last_ambient_lux} lux"\
	-gravity southwest /storage/web/__cam2.jpg +swap -gravity south -composite /storage/web/cam2.jpg

/opt/allsky/bin/cam_to_arch.sh

