#! /bin/bash

my_date=$(date +%Y%m%d)
my_archieve="sflow-collector-rt$my_date.tar.gz"
sudo mount -t vboxsf SourceCode /home/liudanny/Windows_SourceCode
tar zcvf "$my_archieve" sflow-collector-rt/
mv "$my_archieve" ~/Windows_SourceCode/apps/backup