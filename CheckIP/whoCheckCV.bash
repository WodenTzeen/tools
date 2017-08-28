#! /bin/bash
#
###########
# Dev by  : W0d3n
# Date    : August 2017
###########
#
#Find who see my cv on my website

ip=$(cat /var/log/nginx/access.log | grep "cv.html" | tr ' ' '@' | cut -d '@' -f1 | uniq)
for i in $(echo $ip); do date && echo -e "###############\n$i\n" && whois $i | grep -e descr -e role -e Org && echo -e "\n"; done

