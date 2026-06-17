from PIL import Image
import os

def remove_white_bg(input_path, output_path):
    if not os.path.exists(input_path):
        return
    img = Image.open(input_path)
    img = img.convert("RGBA")
    datas = img.getdata()

    newData = []
    # threshold for white
    for item in datas:
        # white background is usually high RGB
        if item[0] > 230 and item[1] > 230 and item[2] > 230:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)

    img.putdata(newData)
    img.save(output_path, "PNG")

remove_white_bg("assets/car-rental.jpg", "assets/rentals.png")
remove_white_bg("assets/scooter.jpg", "assets/scooter.png")
remove_white_bg("assets/bike.png", "assets/bike.png")
print("Converted images!")
