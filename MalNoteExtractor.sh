#!/bin/bash
#MalNoteExtractor
#A rediculous method of extracting FileDataStoreObjects
#made for fun on an old MacBook by an old lady @sk3tchymoos3
#HackThePlanet
#Havent figured out the spacing issue in a file name ... yet
#Assumes all one note samples are in a folder in the CWD called 'samples'
#Requires: foremost and dd

mkdir -p output
for file in $(ls ./samples/*.one)
do
    echo "[*] Parsing:  $file"
    BASENAME=$(basename $file .one) #you can change the extension path to whatever
    BASENAME1=$(echo $BASENAME | tr '[a-z]' '[A-Z]')
    FILEHASH=$(md5 -q -s "$file")
    FILENAME="$BASENAME1""_""$FILEHASH"
    # echo $FILENAME
    if [ -d "output/$FILENAME" ]; then 
        echo "[!] Directory already exists, skipping"
        continue
    fi 
    foremost -Q -c foremost.conf -o output/$FILENAME $file
    for carve in $(ls output/$FILENAME/foo)
    do
        echo "[!] Now we are dealing with the carved out FileDataStoreObject: $carve"
        FILESIZE=$(stat -f%z "output/$FILENAME/foo/$carve")
        SUBBASENAME=$(basename $carve .foo)
        echo -e "\t [i] Filesize: $FILESIZE"
        DESIREDSIZE=$(($FILESIZE - 52))
        echo -e "\t [i] Desired Filesize: $DESIREDSIZE"
        echo -e "\t [i] Checking for images so code can be easily spotted"
        dd if="output/$FILENAME/foo/$carve" of="output/$FILENAME/foo/$SUBBASENAME.txt" bs=1 skip=36 count=$DESIREDSIZE
        ISIMAGE=$(file "output/$FILENAME/foo/$SUBBASENAME.txt")
        IMAGE="image"
        if grep -q "image" <<< $ISIMAGE; then 
            echo -e "\t [!] Image file found: output/$BASENAME/foo/$SUBBASENAME.txt - renaming"
            mv "output/$FILENAME/foo/$SUBBASENAME.txt" "output/$FILENAME/foo/$SUBBASENAME.png"
        else
            echo -e "\t [!] output/$FILENAME/foo/$SUBBASENAME.txt is not an image!" | tee -a output/interesting.txt
        fi
        mkdir -p "output/$FILENAME/foo/original"
        mv "output/$FILENAME/foo/$carve" "output/$FILENAME/foo/original"
    done
done
