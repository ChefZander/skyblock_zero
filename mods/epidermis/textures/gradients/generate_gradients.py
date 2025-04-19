# Script that generates the gradients in this folder. Requires Pillow and Python 3.

from PIL import Image
import math


def generate_rgb_gradient(c, name):
    gradient = Image.new("RGB", (256, 1))
    for x in range(0, 256):
        color = [255, 255, 255]
        color[c] = x
        gradient.putpixel((x, 0), tuple(color))
    gradient.save("epidermis_gradient_" + name + ".png")


generate_rgb_gradient(0, "r")
generate_rgb_gradient(1, "g")
generate_rgb_gradient(2, "b")

gradient = Image.new("HSV", (256, 1))
for x in range(0, 256):
    gradient.putpixel((x, 0), (x, 255, 255))
gradient.convert(mode="RGB").save("epidermis_gradient_hue.png")

m_field = Image.new("RGBA", (256, 256))
C_field = Image.new("RGB", (256, 256))
for x in range(0, 256):
    for y in range(0, 256):
        S = y / 255
        V = x / 255
        C = S * V
        m = V - C
        m = math.floor(255 * m + 0.5)
        m_field.putpixel((x, y), (255, 255, 255, m))
        C = math.floor(255 * C + 0.5)
        C_field.putpixel((x, y), (C, C, C))
m_field.save("epidermis_gradient_field_m.png")
C_field.save("epidermis_gradient_field_chroma.png")
