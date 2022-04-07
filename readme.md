The basic flow is that the Syncthing app on my phone backs up photos to a "Library/Photos/Camera" The script will read the EXIF data from those phots and move them to another Folder named "Organized" where all photos from phones, cameras, etc. are all collected.

I write this as a Python app but you could use any programming language that can make API calls. Overall, my script retrieves an auth token from Seafile then performs the following steps in a loop:

    1.  Retrive auth token
    2.  Retrieves a list of libraries ("repos" in the API doc) to translate the source and destination library names specified in my config to library IDs. and folder structure
    3.  Retrieve a list of all files in the source library/folder
    4.  Loop through every file, download it to a temporary directory, and read the EXIF data (in my case using the "exiftool-vendored" package)
    5.  Based on the EXIF data, determine if the desired directory structure exists in the destination. For example, if I want the file to exist in a year/month directory of "/2021/05", I check first if the "2021" directory exists and create it if it does not. Then do the same for the child "05" directory.
    6.  Move the file from the source to the destination directory.

The app I have written does some more logic with optionally renaming files (my DSLR just names everything IMG_0001 and I want photos automatically renamed to an ISO8601 date format) and does some RegEx replacement (after an automatic date rename, it removes microseconds from the newly renamed filename).
