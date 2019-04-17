#!/bin/sh

cd /home/kst/CSIRapidDevelop
sudo ./log_to_file_server_fork csififo.fifo & java -jar Server_formatlab.jar & sudo mkfifo csififo.fifo & echo "调用MATLAB的中的GUI文件" & sudo /usr/local/MATLAB/R2014a/bin/matlab -nodesktop -nosplash -r "cd /home/kst/CSIRapidDevelop; myguitest;"

echo "kill占用8000端口的进程。。。。"
ps -ef | grep log_to_file_server_fork | grep -v grep | awk '{print $2}' | xargs kill -9
echo "Done!"
