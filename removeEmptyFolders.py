import os

root = 'E:\-=My_shit=-\google_backup\Takeout\Google Fotók'
folders = list(os.walk(root))[1:]

for folder in folders:
    # folder example: ('FOLDER/3', [], ['file'])
    if not folder[2]:
        os.rmdir(folder[0])