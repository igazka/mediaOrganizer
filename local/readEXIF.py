from exif import Image

with open("./images/palm tree 1.jpg", "rb") as palm_1_file:
    palm_1_image = Image(palm_1_file)
    
with open("./images/palm tree 2.jpg", "rb") as palm_2_file:
    palm_2_image = Image(palm_2_file)
    
images = [palm_1_image, palm_2_image]