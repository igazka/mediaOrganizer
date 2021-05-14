import os

path ="E:\-=My_shit=-\google_backup\Takeout\\all"
#we shall store all the file names in this list
filelist = []

for root, dirs, files in os.walk(path):
	for file in files:
        #append the file name to the list
		filelist.append(os.path.join(root,file))

#print all the file names
#for name in filelist:
#    print(name)
print(len(filelist))