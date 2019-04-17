#!/bin/sh

echo "kill占用8000端口的进程。。。。，即结束采集CSI的collectCSI进程"
#kill -9 $(lsof -i:8000 |awk '{print $2}' | tail -n 2)  
#lsof -i:8000 |awk '{print $2}' |xargs kill -9
ps -ef | grep log_to_file_display_online_add_filename | grep -v grep | awk '{print $2}' | xargs kill -9
echo "结束采集CSI"
echo "采集结束"
echo "Done!"
