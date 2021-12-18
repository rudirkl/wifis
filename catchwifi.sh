#!/bin/bash
#
# Script to store data from wifi networks
#
# Site: xor@xor.net.br
# Author: Rudi
#
#
# ID ; ESSID ; BSSID ; PASSWORD ; DESCRIPTION ; CITY ; STATE ; COUNTRY ; WPS(PIN) ; HASH

DB_TXT="db.txt"
TEMP=temp.$$
TEMP2=temp2.$$
TEMP3=temp3.$$
TEMP4=temp4.$$
GREEN="\033[32;1m"
RED="\033[31;1m"

[ ! -e "$DB_TXT" ] && echo "File does not exist" && exit 1
[ ! -r "$DB_TXT" ] && echo "Without read permition" && exit 1
[ ! -w "$DB_TXT" ] && echo "Without write permition" && exit 1

ShowList () {
	
	local ID="$(echo $2 | cut -d ";" -f1)"
	local ESSID="$(echo $2 | cut -d ";" -f2)"
	local BSSID="$(echo $2 | cut -d ";" -f3)"
	local PASS="$(echo $2 | cut -d ";" -f4)"
	local DSCR="$(echo $2 | cut -d ";" -f5)"
	local CITY="$(echo $2 | cut -d ";" -f6)"
	local STATE="$(echo $2 | cut -d ";" -f7)"
	local CNTRY="$(echo $2 | cut -d ";" -f8)"
	local WPS="$(echo $2 | cut -d ";" -f9)"
	local HASH="$(echo $2 | cut -d ";" -f10)"

	if [[ $1 -eq 1  ]]; then
	
		echo -e "${GREEN}ID: ${RED}$ID"
		echo -e "${GREEN}ESSID: ${RED}$ESSID"
		echo -e "${GREEN}PASSWORD: ${RED}$PASS"
		echo -e "${GREEN}CITY: ${RED}$CITY"

		echo ""
	fi

	if [[ $1 -eq 2  ]]; then
		echo -e "${GREEN}ID: ${RED}$ID"
		echo -e "${GREEN}ESSID: ${RED}$ESSID"
		echo -e "${GREEN}PASSWORD: ${RED}$PASS"
		echo -e "${GREEN}WPS(PIN): ${RED}$WPS"
		echo -e "${GREEN}BSSID: ${RED}$BSSID"
		echo -e "${GREEN}CITY: ${RED}$CITY"
		echo -e "${GREEN}STATE: ${RED}$STATE"
		echo -e "${GREEN}COUNTRY: ${RED}$CNTRY"
		echo -e "${GREEN}DESCRIPTION: ${RED}$DSCR"
		echo -e "${GREEN}HASH: ${RED}$HASH"

		echo ""
	fi
}

NetList () {

	while read -r line
	do
		[ "$(echo $line | cut -c1)" = "#" ] && continue
		[ ! "$line" ]  && continue
		
		ShowList $1 "$line"
	done < "$DB_TXT"
}

AddNet () {
	
	echo -e "${RED}ESSID AND PASSWORD ARE MANDATORY"
	echo ""
	local LAST_ID=$(egrep -v "^#|^$" "$DB_TXT" | sort -h | tail -n 1 | cut -d ";" -f1)
	local NEXT_ID=$(($LAST_ID+1))
	
	echo -e "${GREEN}"
	read -p "Enter the ESSID: " ESSID
	[ ! "$ESSID" ] && echo -e "${RED}ESSID ARE MANDATORY" && exit 1
	read -p "Enter the PASSWORD: " PASS
	[ ! "$PASS" ] && echo "${RED}PASSWORD ARE MANDATORY" && exit 1
	read -p "Enter the BSSID: " BSSID
	[ ! "$BSSID" ] && BSSID="*"
	read -p "Enter the Description: " DSCR
	[ ! "$DSCR" ] && DSCR="*"
	read -p "Enter the WPS(PIN): " WPS
	[ ! "$WPS" ] && WPS="*"
	read -p "Enter the City: " CITY
	[ ! "$CITY" ] && CITY="*"
	read -p "Enter the State: " STATE
	[ ! "$STATE" ] && STATE="*"
	read -p "Enter the COUNTRY: " COUNTRY
	[ ! "$COUNTRY" ] && COUNTRY="*"
	read -p "Enter the HASH: " HASH
	[ ! "$HASH" ] && HASH="*"

	echo "$NEXT_ID;$ESSID;$BSSID;$PASS;$DSCR;$CITY;$STATE;$COUNTRY;$WPS;$HASH" >> "$DB_TXT"
	echo "$(clear)"

}
	
RmNet () {

	read -p "Enter the ID to remove: " ID
	[ ! "$ID" ] && echo -e "${RED}ID is mandatory" && exit 1

	grep -i -v "^$ID;" "$DB_TXT" > "$TEMP"
	mv "$TEMP" "$DB_TXT"
	rm "$TEMP"
	echo "$(clear)"
}

EditNet () {
	
	read -p "Enter the ID to edit: " ID
	[ ! "$ID" ] && echo -e "${RED}ID is mandatory" && exit 1
	
	grep -i "^$ID;" "$DB_TXT" > "$TEMP2"
	grep -i -v "^$ID;" "$DB_TXT" > "$TEMP"

	echo "
	2->ESSID 
	3->BSSID;
	4->PASS;
	5->DSCRIPTION;
	6->CITY;
	7->STATE;
	8->COUNTRY;
	9->WPS;
	10->HASH
	"
	
	read -p "Select the option to edit: " OPTEDIT
       	read -p "Modify to: " EDIT	

	TEMP3=`cut -d ";" -f "$OPTEDIT" $TEMP2`

	sed "s/$TEMP3/$EDIT/g" $TEMP2 > $TEMP4

	cat $TEMP4 >> $TEMP
	sort $TEMP > $DB_TXT

	rm temp*
	echo "$(clear)"
}

clear

while :
do
	echo -e "${GREEN} Choose an option? 
		0 to exit 
		1 List networks
		2 to add wifi network data 
		3 to remove wifi network
		4 List networks(full)
		5 Edit Network
		"
		read -p "-----> " OPT
	
	echo "$(clear)"

	case $OPT in
		0) echo -e "${RED}Good bye!!!" && exit 0;;
		1) NetList 1;;
		2) AddNet;;
		3) RmNet;;
		4) NetList 2;;
		5) EditNet;;
		*) echo -e "${RED}Invalid Option" && exit 1;;
	esac	

done
