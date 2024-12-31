#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
public_ip=$(curl http://checkip.amazonaws.com/)

echo "<html><body><h1>Hello, <b>$public_ip</b></h1></body></html>" > /usr/share/nginx/html/index.html

systemctl restart nginx
