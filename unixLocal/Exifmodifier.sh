#go to working folder    
    orgDir=/home/andras/terraswinyo/images
    cd $orgDir
# list of files from folder
orgDirfiles=$(ls -p | grep -v /)
IFS=$'\n' orgDirfiles=($orgDirfiles)

for file in "${!orgDirfiles[@]}";do
    exiftool -dateTimeOriginal="2018:03:17 00:00:01" "${orgDirfiles[file]}"
done