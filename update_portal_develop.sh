#!/bin/bash

cd /home
rm -r gemini
git clone https://github.com/fanchy1025/gemini.git
cd gemini/
git checkout develop
rm -rf /usr/share/gocloud
ln -s /home/gemini/gocloud /usr/share/gocloud
ln -s /usr/local/lib/python2.7/dist-packages/django/contrib/admin/static/admin /usr/share/gocloud/static/
ln -s /usr/local/lib/python2.7/dist-packages/rest_framework_swagger/static/rest_framework_swagger /usr/share/gocloud/static/
vi gocloud/gocloud/settings.py
python init.py 
service apache2 restart