import os
import sys
import shutil
# License=MIT https://github.com/Belval/pdf2image
from pdf2image import convert_from_path
# License= https://github.com/python-pillow/Pillow
# https://github.com/python-pillow/Pillow/blob/master/LICENSE
# Basically, make sure to include license and do not
# use company or author name in advertising
from PIL import Image
from PIL import TiffImagePlugin

# Sample PDF from http://africau.edu/images/default/sample.pdf

# Not very well documented
# Path to the PDF as the first arg when executing this
# Name of final tif is the second arg.
base = sys.argv[1]
final_file_name = sys.argv[2]

tif_temp_dir = "./tiff_tmp"
os.mkdir(tif_temp_dir)

images_from_path = convert_from_path(
    pdf_path=base, fmt="tiff", output_file="out", output_folder=tif_temp_dir)

tiffs_to_combine = [x for x in os.listdir(tif_temp_dir) if x.endswith("tif")]

with TiffImagePlugin.AppendingTiffWriter(final_file_name+".tif", True) as tf:
    for tiff_in in tiffs_to_combine:
        path_to_tmp_tif = tif_temp_dir+"/"+tiff_in
        with open(path_to_tmp_tif, "rb") as tiff_in:
            im = Image.open(tiff_in)
            im.save(tf)
            tf.newFrame()

shutil.rmtree(tif_temp_dir)
