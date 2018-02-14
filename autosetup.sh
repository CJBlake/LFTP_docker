#!/bin/bash

###### GET Enviroment varibles from docker
uname="${LFTP_USER}"
uid="${LFTP_UID}"
grpname="${LFTP_GROUP}"
gid="${LFTP_GID}"
log_dir="${LFTP_LOG_DIR}"
###### Setup user account
groupadd -g "$gid" "$grpname"
mkdir "/config/users/$uname"
useradd -u "$uid" -g "$grpname" -d "/config/users/$uname" "$uname"
echo "${LFTP_USER}":"${USER_PASSWORD}" | chpasswd
###### Setup download script
su "$uname" -c "mkdir /config/scripts"
su "$uname" -c "cat > /config/scripts/sync_downloads.sh << 'ENDMASTER'
$(
###### The parameter substitution is on here
cat <<INNERMASTER
#!/bin/bash
login="${FERAL_USERNAME}"
pass="${FERAL_PASSWORD}"
host="${FERAL_HOST}"
remote_movie_dir="${REMOTE_MOVIE_DIR}"
local_movie_dir="${LOCAL_MOVIE_DIR}"
temp_movie_dir="${TEMP_MOVIE_DIR}"
remote_music_dir="${REMOTE_MUSIC_DIR}"
local_music_dir="${LOCAL_MUSIC_DIR}"
temp_music_dir="${TEMP_MUSIC_DIR}"
remote_tv_dir="${REMOTE_TV_DIR}"
local_tv_dir="${LOCAL_TV_DIR}"
temp_tv_dir="${TEMP_TV_DIR}"
upload_rate="0"
download_rate="0"
INNERMASTER
###### No parameter substitution
cat <<'INNERMASTER'
if [[ "$1" == "movie" ]]; then
	remote_dir="$remote_movie_dir"
	local_dir="$local_movie_dir"
	temp_dir="$temp_movie_dir"
elif [[ "$1" == "music" ]]; then
	remote_dir="$remote_music_dir"
	local_dir="$local_music_dir"
	temp_dir="$temp_music_dir"
elif [[ "$1" == "tvshow" ]]; then
	remote_dir="$remote_tv_dir"
	local_dir="$local_tv_dir"
	temp_dir="$temp_tv_dir"
else
	echo "download type error"
fi
H=$(date +%H)
base_name="$(basename "$0")"
lock_file="/tmp/$base_name.lock"
trap "rm -f $lock_file; exit 0" SIGINT SIGTERM
if [ -e "$lock_file" ]
then
    echo "$base_name is running already."
    exit
else
    touch "$lock_file"
    if (( 9 <= 10#$H && 10#$H < 24 )); then
        upload_rate="100000"
        download_rate="2000000"
        echo "limit on"
    else
        upload_rate="0"
        download_rate="0"
        echo "limit off"
    fi
    lftp -p 22 -u "$login","$pass" sftp://"$host" << EOF
    set sftp:auto-confirm yes
    set net:limit-rate "$upload_rate":"$download_rate"
    set mirror:use-pget-n 20
    mirror -c -v -P2 --loop --Remove-source-dirs "$remote_dir" "$temp_dir"
    quit
EOF
    cp -val "$temp_dir"/* "$local_dir"
    rm -rf "$temp_dir"/*
    chmod -R 775 "$local_dir"
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit
fi
INNERMASTER
)
ENDMASTER"
su "$uname" -c "chmod 770 /config/scripts/sync_downloads.sh" # Make the script executable
###### Log stuff
touch $log_dir/"setup.log"
echo "time: $(date). - setup successful" >> $log_dir/"setup.log"
exec "$@"
