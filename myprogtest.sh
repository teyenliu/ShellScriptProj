#! /bin/bash
# 測驗 awk 與 sed 與 egrep 等會使用到的程式 是否存在
errormesg=""
programs="awk sed egrep ps cat cut tee netstat df uptime"
for profile in $programs
do
	which $profile > /dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo -e "您的系統並沒有包含 $profile 程式；(Your system do not have $profile )"
		errormesg="yes"
	fi
done
if [ "$errormesg" == "yes" ]; then
	echo "您的系統缺乏本程式執行所需要的系統執行檔， $0 將停止作業"
	exit 1
fi