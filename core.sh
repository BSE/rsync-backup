#!/bin/bash

if [ "$id" == "" ]; then
	exit 1
fi

log="/tmp/$id.log"
host=$(hostname)

echo "++ START BACKUP '$id' $(date)" > $log
echo "" >> $log
echo "host: $(hostname -f)" >> $log
echo "" >> $log

if [ ! -f /backup/selections.txt ];
then
	echo "ERROR: Missing selections.txt Nothing to backup!" >> $log
	echo "" >> $log
	echo "-- END BACKUP '$id' $(date)" >> $log
	exit 1
fi

while read line
do
echo "+ backup '$line' $(date)" >> $log
rsync -a --exclude '.env' --stats --delete --password-file=/etc/rsync.secret "$line" backup@nas1::backup/$host/$id/ >> $log
echo "" >> $log
echo "- end backup '$line' $(date)" >> $log
echo "" >> $log
done < "/backup/selections.txt"

echo "-- END BACKUP '$id' $(date)" >> $log

SUBJECT="BACKUP '$id' of '$(hostname -f)'"
TO="reports@bse.vic.edu.au"
mail -s "$SUBJECT" "$TO" -a "From: Backup <reports@bse.vic.edu.au>" < $log

