#!/bin/bash

# nohup ./monitor.sh > /dev/null 2>&1 &

email=""
folder="/var/www/website/"
logfile="/var/www/website.log"

events="attrib,create,delete,delete_self,modify,move_self,move"
exclude="\.(jpe?g|png|gif|svg|txt|docx?|xlsx?|mpe?g|mov|mp4|mp3|pdf|swp|xml)$"
skippaths="^()$"
skipfiles="^()$"

last=-600

if [[ -z `pgrep inotifywait` ]]; then
        inotifywait -m -r -e $events $folder --exclude $exclude |
                while read path action file; do
                        if [[ $path =~ $skippaths ]] || [[ $file =~ $skipfiles ]]; then
                                echo "skipped $path$file $action"
                                
                        elif [[ $file =~ \. ]]; then
                                echo -e "$(date)\n$path$file $action\n\n" >> $logfile
                                
                                now=$SECONDS
                                temp=$((last + 600))
                                if  [[ $now -gt $temp ]] && [[ $email =~ @ ]]; then
                                        last=$now
                                        tail $logfile -n 100 | /usr/bin/mail -s "EVENT : $path$file" $email
                                        echo -e "email notification sent to $email\n\n" >> $logfile
                                fi
                        fi
                done
else
        echo "script running"
fi

