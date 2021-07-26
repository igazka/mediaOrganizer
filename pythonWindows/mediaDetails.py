# Python3 program to illustrate
# accessing of audio metadata
# using tinytag library
  
# Import Tinytag method from
# tinytag library
from tinytag import TinyTag
  
# Pass the filename into the
# Tinytag.get() method and store
# the result in audio variable
video = TinyTag.get("E:\\-=My_shit=-\\google_backup\\Takeout\\all\\28M08S_1575714488.mp4")
  
# Use the attributes
# and Display
print("Title:")
print(video.title)
print("Artist: ") 
print(video.artist)
print("Genre:" )
print(video.genre)
print("Year Released: " ) 
print(video.year)
print("Bitrate: kBits/s")
print(video.bitrate)
print("Composer: ")
print(video.composer)
print("Filesize:  bytes")
print(video.filesize)
print("Duration: seconds")
print(video.duration)
