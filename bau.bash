#!/usr/bin/bash

ULTI="${@: -1}"
SUBSS="${*: -2:1}" # Do lado do ultimo

if [[ -z "$1" ]]; then
  echo -e "\n./${0##*/} <URL> <-s OR -ns> \"php|jpeg|txt|jpg|svg\"\n"
#https://index.commoncrawl.org/CC-MAIN-2022-05-index?url=$1/*&output=json" | jq '.url'
fi

# Primeira etapa sem crawling de subdominios
# First phase without subdomain crawling
if [[ "$2" == "-ns" ]] && [[ ! -z "$1" ]]; then
  curl -s -k --tcp-fastopen --tcp-nodelay --connect-timeout 25 "https://web.archive.org/cdx/search/cdx?url=$1/*&output=json&fl=original&collapse=urlkey&page=/" | tr -d '[',']','"' | egrep ".*?:\/\/.*\?.*\=[^$]" | egrep -v ".($ULTI)" | uniq
  exit 0
# Segunda etapa com crawling de subdominios
# Second phase with subdomain crawling
elif [[ "$2" == "-s" ]] && [[ ! -z "$1" ]]; then
  curl -s -k --tcp-fastopen --tcp-nodelay --connect-timeout 25 "https://web.archive.org/cdx/search/cdx?url=*.$1/*&output=json&fl=original&collapse=urlkey&page=/" | tr -d '[',']','"' | egrep ".*?:\/\/.*\?.*\=[^$]" | egrep -v ".($ULTI)" | uniq
  exit 0
fi
