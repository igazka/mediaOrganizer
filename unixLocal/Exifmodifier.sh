#go to working folder    
    orgDir=/home/andras/terraswinyo/images
    cd $orgDir
# list of files from folder
orgDirfiles=$(ls -p | grep -v /)
IFS=$'\n' orgDirfiles=($orgDirfiles)

for file in "${!orgDirfiles[@]}";do
    exiftool -dateTimeOriginal="2021:06:15 00:08:31" "${orgDirfiles[file]}"
done