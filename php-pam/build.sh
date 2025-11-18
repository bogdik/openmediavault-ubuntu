#!/bin/bash

sudo apt install devscripts -y
sudo apt-get install xsltproc php-dev libpam-dev -y
debuild -us -uc -b
debuild -us -uc -b

