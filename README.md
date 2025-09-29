# axis_Gauss_1x5
tb/input_raw/raw_to_png.py - python script for converting original
and transformed .raw images.
parameters: input_path (str): путь к исходному RAW файлу
            output_path (str): путь для сохранения PNG файла
            width (int): ширина изображения в пикселях
            height (int): высота изображения в пикселях

tb/input_raw/lynx_gray_512x768.png - original image from the Internet,
what I replaced your image from task.

tb/input_raw/lynx_gray_512x768.raw - converted from lynx_gray_512x768.png
image with usage some online converter

tb/input_raw/output_img_random_valid.png - transformed image after Gauss filter
(with random tvalid in simulation)

tb/axis_Gauss_1x5_tb.sv - main test file

tb/axis_video_gen.sv - package for read .raw file to send to the AXI Stream (AXIS) - interface

tb/axis_save_raw.sv - module to save .raw file from AXIS
