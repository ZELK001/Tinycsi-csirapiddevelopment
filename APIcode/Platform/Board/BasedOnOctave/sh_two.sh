#!/bin/sh
echo "开始采集CSI。。。"
echo "运行collectCSIShownInRealTime.sh脚本 "
echo "与服务器是新的socket连接（初始化使用端口8099，采集csi用8000）"
filename="0001_`date +%y%m%d%H%M`_test_csi"
echo "存储CSI文件名为"
echo $1
cd ~/humandetectionusingcsi/code/display/onlineDisplay
./collectCSIShownInRealTime.sh 0.05 10.214.128.178 $1
echo "采集结束"
echo "Done!"
