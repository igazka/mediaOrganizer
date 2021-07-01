#!/bin/bash
#bash script to rename photos basesed on their EXIF data IMG_YYYYMMDD_HHMMSS.jpg
#go to working folder    
    orgDir=/home/andras/terraswinyo/images
    cd $orgDir
# list of files from folder
    orgDirfiles=$(ls -p | grep -v /)
    IFS=$'\n' orgDirfiles=($orgDirfiles)
    echo "--------------------------------------------"
    echo "num of files: ${#orgDirfiles[@]}"
for file in "${!orgDirfiles[@]}";do
    echo -e "Processing: \e[1;31m$file\e[0m  of ${#orgDirfiles[@]}" 
    echo "${orgDirfiles[file]}"
    #check if filename is valid
        length=$(expr length "${orgDirfiles[file]}")
            if [ $length -gt 0 ]&&[[ "${orgDirfiles[file]}" == *".jpg"* || *".3gp"* || *".mp4"* || *".JPG"* ]]; then
                echo "good filename: ${orgDirfiles[file]}"
            else
                echo "bad file extension: ${orgDirfiles[file]}, skipping"
                continue
            fi
    #get exif data
        if [[ "${orgDirfiles[file]}" == *".jpg"* || "${orgDirfiles[file]}" == *".JPG"* ]]; then
           date=$(exiftool -p '$dateTimeOriginal' "${orgDirfiles[file]}" -F)
           if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
             date=$(exiftool -p '$DateAcquired' "${orgDirfiles[file]}" -F)
             if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
              date=$(exiftool -p '${FileModifyDate#;DateFmt("%Y:%m:%d %H:%M:%S")}' "${orgDirfiles[file]}")
             fi
           fi
           ext=".jpg"
           prefix="IMG"
         elif [[ "${orgDirfiles[file]}" == *".mp4"* || "${orgDirfiles[file]}" == *".MP4"* ]]; then
           date=$(exiftool -p '$mediacreatedate' "${orgDirfiles[file]}" -F)
           ext=".mp4"
           prefix="VID"
         elif  [[ "${orgDirfiles[file]}" == *".3gp"* || "${orgDirfiles[file]}" == *".3GP"* ]]; then
            date=$(exiftool -p '$mediacreatedate' "${orgDirfiles[file]}" -F)
            ext=".3gp"
            prefix="VID"
        fi
        echo $date, "${#date}"
        #if there is no exif data, rename to NOEXIF_DATA + current name
        if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
            newFilename=$prefix"_NOEXIF_DATA_"${orgDirfiles[file]}$ext
        else
            year=${date::4}
            month=${date:5:2}
            day=${date:8:2}
            hour=${date:11:2}
            minutes=${date:14:2}
            seconds=${date:17:2}  
            newFilename=$prefix"_"$year$month$day"_"$hour$minutes$seconds$ext
        fi
    #renaming
        if [[ "${orgDirfiles[file]}" == "$newFilename" ]]; then
           echo "File ${orgDirfiles[file]} is \e[1;32malready\e[0m named $newFilename." 
           else 
             mv --backup=numbered ${orgDirfiles[file]} $newFilename
             echo "\e[1;32mFile: ${orgDirfiles[file]} is renamed to $newFilename.\e[0m"
        fi 
done