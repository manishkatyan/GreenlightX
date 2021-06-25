#!usr/bin/sh
. ./.env

sudo docker run --rm -d \
                --expose 8080 \
                --name "$MEETING_ID" \
                -v /root/bbb-live-streaming/.env:/usr/src/app/.env \
                bbb-live-streaming:v1