import shutil
import os
import glob
import exif
from exif import Image

destination="E:\-=My_shit=-\google_backup\Takeout\\all"
path ="E:\\-=My_shit=-\\google_backup\\Takeout\\all"
images_path=[]
images_data=[]
for root, dirs, files in os.walk(path):
    for file in files:
        if file.endswith(".jpg"):
             #print(os.path.join(root, file))
             #newpath=shutil.copy(str(os.path.join(root, file)), destination)
             #os.remove(os.path.join(root, file))
             images_path.append(str(os.path.join(root, file)))
        elif file.endswith(".JPG"):
             #print(os.path.join(root, file))
             #newpath=shutil.copy(str(os.path.join(root, file)), destination)
             #os.remove(os.path.join(root, file))
             images_path.append(str(os.path.join(root, file)))


for index, image in enumerate(images_path):
    with open(image, "rb") as phfile:
        phs = Image(phfile)
        if phs.datetime_original!="":
            print(phs.datetime_original)
        
