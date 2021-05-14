import shutil
import os
import glob
import exif
from exif import Image
from os import listdir
from os.path import isfile, join

destination="E:\-=My_shit=-\google_backup\Takeout\\all"
path ="E:\\-=My_shit=-\\google_backup\\Takeout\\all"
images_path=[]
images_data=[]
videos_path=[]
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
        elif file.endswith(".mp4"):
             #print(os.path.join(root, file))
             #newpath=shutil.copy(str(os.path.join(root, file)), destination)
             #os.remove(os.path.join(root, file))
             videos_path.append(str(os.path.join(root, file)))
        elif file.endswith(".3gp"):
             #print(os.path.join(root, file))
             #newpath=shutil.copy(str(os.path.join(root, file)), destination)
             #os.remove(os.path.join(root, file))
             videos_path.append(str(os.path.join(root, file)))             


onlyfiles = [f for f in listdir(path) if isfile(join(path, f))]

for index, image in enumerate(images_path):
    with open(image, "rb") as phfile:
        phs = Image(phfile)
        #if phs.datetime_original!="":
        #    print(phs.datetime_original)
        attr=phs.list_all()
        for item in attr:
            if item=="datetime_original":
                print(str(index)+"/"+str(len(onlyfiles))+" Oragnized")
                year=phs.datetime_original[:4]
                month=phs.datetime_original[5:7]
                destination=os.path.join(path, year+"_"+month)
                if not os.path.isdir(destination):
                    os.mkdir(destination)
                if not os.path.isfile(os.path.join(image, destination)):
                    newpath=shutil.copy(image, destination)
    os.remove(image)
    print(str(index)+"/"+str(len(onlyfiles))+" Deleted")

