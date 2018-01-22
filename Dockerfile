FROM debian:jessie

ENV LFTP_USERNAME ="LFTP" \
    LFTP_UID="1001" \
    LFTP_GROUP_NAME="LFTP" \
    FERAL_USERNAME="username" \
    FERAL_PASSWORD="password" \
    FERAL_HOST="host.feralhosting.com" \
    TV_REMOTE_DIR="~/folder/you/want/to/copy" \
    TV_LOCAL_DIR="/folder/you/mounted/to/docker" \
    MOVIE_REMOTE_DIR="~/folder/you/want/to/copy" \
    MOVIE_LOCAL_DIR="/folder/you/mounted/to/docker"

RUN apt-get update && \
    apt-get -y --no-install-recommends install nano bash lftp wget openssh-server ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
    # add user
    user add "${LFTP_USERNAME}" -u "${LFTP_UID" -g "$LFTP_GROUP_NAME" && \
    su "${LFTP_USERNAME}" -c "mkdir /config/scripts && \
    su "${LFTP_USERNAME}" -c "cat > /config/scripts/tsyncdownloads.sh << 'ENDMASTER'
$(
###### The parameter substitution is on here
cat <<INNERMASTER
#!/bin/bash
login="${FERAL_USERNAME}"
pass="${FERAL_PASSWORD}"
host="${FERAL_HOST}"
remote_dir="${TV_REMOTE_DIR}"
local_dir="${TV_LOCAL_DIR}/completed"
temp_dir="${TV_LOCAL_DIR}/completed"
upload_rate="0"
download_rate="0"
H=$(date +%H)
INNERMASTER
###### No parameter substitution
cat <<'INNERMASTER'
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
    cp -val "$temp_dir/*" "$local_dir"
    rm -rf "$temp_dir/*"
    chmod -R 777 "$local_dir"
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit
fi
INNERMASTER
)
ENDMASTER" && \

    su "${LFTP_USERNAME}" -c "chmod 700 /config/scripts/tsyncdownloads.sh" # Make the script executable $$ \
    su "${LFTP_USERNAME}" -c "cat > /config/scripts/msyncdownloads.sh << 'ENDMASTER'
$(
###### The parameter substitution is on here
cat <<INNERMASTER
#!/bin/bash
login="${FERAL_USERNAME}"
pass="${FERAL_PASSWORD}"
host="${FERAL_HOST}"
remote_dir="${MOVIE_REMOTE_DIR}"
local_dir="${MOVIE_LOCAL_DIR}/completed"
temp_dir="${MOVIE_LOCAL_DIR}/completed"
upload_rate="0"
download_rate="0"
H=$(date +%H)
INNERMASTER
###### No parameter substitution
cat <<'INNERMASTER'
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
    cp -val "$temp_dir/*" "$local_dir"
    rm -rf "$temp_dir/*"
    chmod -R 777 "$local_dir"
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit
fi
INNERMASTER
)
ENDMASTER" && \

    su "${LFTP_USERNAME}" -c "chmod 700 /config/scripts/msyncdownloads.sh" # Make the script executable $$ \
  ENTRYPOINT /bin/bash
    
