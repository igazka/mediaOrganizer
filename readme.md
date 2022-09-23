# Summary
This is a bash script that takes and moves the pictures found in a source folder to a destenation folder, checks the names of the files based on the exif data, changes it if neccesary.
# Usage:
For this scipt to work, you need to:
1. Copy it to wherever you would like to run it form
2. create an .env file to the same folder you have it
3. fill the .env file with the following variables:
    `srcFolder1=/home/your/images
    srcFolder2=/home/your/images2
    destDir=/home/storage/images
    logfilepath="/home/Crontablogs"`
4. you need [exiftool](https://exiftool.org/install.html) installed on your system
5. you can run the script

