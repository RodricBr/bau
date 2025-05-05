#!/bin/bash

# Color variables:
ERR_="\x1b[31m"
INF_="\x1b[38;5;33m"
BAN_="\x1b[38;5;46m" # Color for the usage banner
C_END="\x1b[0m"


# Counting the time the program will take to be executed:
COUNTER_=$(date +%s)

# Checking if curl is installed...
[[ ! $(command -v curl) ]]&& printf "${ERR_}[x] Error:${C_END}\n\"curl\" - which is essential for this program - is not installed in your system!\nQuitting...\n" && exit 1

# Checking if VirussTotal API Key is defined in the .config file
if [[ ! -f "$HOME/.config/bau/vt-key" ]]; then
  echo -e "\n\
[!] Warning:\n\
VirusTotal API Key was NOT provided!\n\
Create a file at \"$HOME/.config/bau/vt-key\" to execute the program at its full potential!\n"
else
  VT_KEY="$HOME/.config/bau/vt-key"
fi

# Checking if the urlscan api key is provided in the .config file
if [[ ! -f "$HOME/.config/bau/urlscan-key" ]]; then
  echo -e "\n\
[!] Warning:\n\
UrlScan API Key was NOT provided!\n\
Create a file at \"$HOME/.config/bau/urlscan-key\" to execute the program at its full potential!\n"
else
  US_KEY="$HOME/.config/bau/urlscan-key"
fi

# Help/usage function
function HELP_OPT {
  echo -e "${INF_}+~~~~~${C_END}      ${BAN_}Bau - Bash All URLs - Created by${C_END} ${ERR_}rodricbr @github.com${C_END}      ${INF_}~~~~~+${C_END}"
  echo -e "\n\t   Extract URLs from stdin or stdout from passive sources. Inspired by lc's gau"
  echo -e "\nUsage: ${0##*/} [-s domain] [-e \"ext1|ext2|...\"]   OR   printf \"domain\" | ${0##*/} [-e \"ext1|ext2|...\"]\n\
    -h/--help         :: Show this usage message and exit\n\
    -s [domain]       :: Specify the domain to be scanned\n\
    -e \"php|ttf|...\"  :: Exclude file extensions before parameters (Separate with \"|\")\n\
    \n${INF_}PS: It is recommended to use urldedupe or any other tool to remove duplicated urls.${C_END}\n"
  exit 0
}

# Scanning phrase (includes subdomains)
function S_OPT {
  local domain_="$1"
  local output_file="${domain_}-output.txt"

  # WayBack API
  curl -skL "https://web.archive.org/cdx/search/cdx?url=*.$domain_%2F*&output=text&fl=original&collapse=urlkey&page=/" > "$output_file"

  # VirusTotal API (requires API Key)
  # Checking if the vt-key file exists
  if [[ -f "$HOME/.config/bau/vt-key" ]]; then
    curl -sk "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$(< "$VT_KEY")&domain=$domain_" | jq -r '.. | .url? // empty' >> "$output_file"
  else
    echo -e "${ERR_}[!] Warning:${C_END}\nVirusTotal API Key was not found at \"$HOME/.config/bau/vt-key\". Skipping VirusTotal scan...\n"
  fi

  # OTX Alien Vault API
  curl -sk "https://otx.alienvault.com/api/v1/indicators/hostname/$domain_/url_list?limit=500&page="{1..3} | jq -r '.. | .url? // empty' >> "$output_file"

  curl -sk "https://urlscan.io/api/v1/search/?q=domain:$domain_&size=500" -H "Key: $(< "$US_KEY")" | jq -r '.. | .result? // empty' | while read -r line; do curl -sk "$line" | jq -r '.. | .url? // empty' | grep "$domain_\/"; done >> "$output_file"
}

function FILTER_OPT {
  local exclude_extensions="$1"
  local domain_="$2"
  local output_file="${domain_}-output.txt"

  [[ -f "$output_file" ]]|| {
    printf "${ERR_}[x] Error:${C_END}\nFile \"$output_file\" was not found. Make sure the scan has been performed correctly.\n"
    return 1
  }

  if [[ -n "$exclude_extensions" ]]; then
    printf "${INF_}[i] Filtered file extensions:${C_END} $exclude_extensions\n"
    grep -vEi "\.(${exclude_extensions})([[:punct:]][^/]*|)([/?#]|$)" "$output_file" > "${domain_}-filtered-output.txt"
    mv "${domain_}-filtered-output.txt" "$output_file"
  else
    printf "${ERR_}[x] No file extensions was provided for filtering!${C_END}\nSee \"-h/--help\" for more information\n"
  fi
}

# Handling argument flags..
DOMAIN=""
EXCLUDE_EXTENSIONS=""
SUBDOMAINS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -e)
      if [[ -n "$2" ]]; then
        EXCLUDE_EXTENSIONS="$2"
        shift 2
      else
        printf "${ERR_}[x] Error:${C_END}\nOption \"-e\" requires a list of extensions.\nSee \"-h/--help\" for more information.\n"
        exit 1
      fi ;;

    -s) SUBDOMAINS=true ; shift
      if [[ -n "$1" && "$1" != -* ]]; then
        DOMAIN="$1"
        shift
      elif [ ! -t 0 ]; then
        read -r DOMAIN
      else
        printf "${ERR_}[x] Error:${C_END}\nOption \"-s\" requires a domain.\nSee \"-h/--help\" for more information.\n"
        exit 1
      fi ;;

    --help|-h) HELP_OPT ; exit 0 ;;

    -*) printf "${ERR_}[x] Error:${C_END}\nUnknown option flag \"$1\"\nSee \"-h/--help\" for more information.\n" ; exit 1 ;;

    *) [[ -z "$DOMAIN" ]] && DOMAIN="$1" || {
        printf "${ERR_}[x] Error:${C_END}\nExtra argument found: \"$1\"\nSee \"-h/--help\" for more information.\n"
        exit 1
      } ; shift ;;
  esac
done

# Handling domain from stdin if not provided as an argument
if [[ -z "$DOMAIN" && ! -t 0 ]]; then
  read -r DOMAIN
fi

# Suming up and showing the results...
if [[ -n "$DOMAIN" ]]; then
  S_OPT "$DOMAIN" > "$DOMAIN-output.txt"
  cat "$DOMAIN-output.txt" | grep -E "^https?://" | grep "$DOMAIN\/" | uniq | sort -u > "$DOMAIN-output2.txt"
  rm "$DOMAIN-output.txt" && mv "$DOMAIN-output2.txt" "$DOMAIN-output.txt" # pretend you saw nothing

  [[ -n "$EXCLUDE_EXTENSIONS" ]]&& FILTER_OPT "$EXCLUDE_EXTENSIONS" "$DOMAIN"

  printf "\n${INF_}[!] Info:${C_END}\n"
  if [[ -f "${DOMAIN}-output.txt" ]]; then
    printf "${INF_}> Scanned${C_END} \"$(wc -l < "$DOMAIN-output.txt")\" ${INF_}urls for domain${C_END} \"$DOMAIN\"\n"
    printf "${INF_}> Output file:${C_END} "$DOMAIN-output.txt"\n"
    printf "${INF_}> Took${C_END} \"$(printf "$(( $(date +%s) - $COUNTER_))")\"${INF_} seconds to complete${C_END}\n"
  else
    printf "${ERR_}No URLs were found for domain${C_END} \"$DOMAIN\" ${ERR_}or an error occurred during the scan.${C_END}\n"
  fi
else
  printf "${ERR_}[x] Error:${C_END}\nNo domain was provided.\nSee \"-h/--help\" for more information. $(exit 1)\n"
  exit 1
fi
