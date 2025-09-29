import argparse
from PIL import Image
import numpy as np
import os

def raw_to_png(input_path, output_path, width, height):
    """
    Конвертирует 8-битное монохромное RAW изображение в PNG
    
    Args:
        input_path (str): путь к исходному RAW файлу
        output_path (str): путь для сохранения PNG файла
        width (int): ширина изображения в пикселях
        height (int): высота изображения в пикселях
    """
    try:
        # Читаем RAW файл как байты
        with open(input_path, 'rb') as f:
            raw_data = f.read()
        
        # Проверяем размер файла
        expected_size = width * height
        if len(raw_data) != expected_size:
            print(f"Предупреждение: размер файла ({len(raw_data)} байт) не соответствует ожидаемому ({expected_size} байт)")
        
        # Создаем numpy массив из байтов
        img_array = np.frombuffer(raw_data, dtype=np.uint8)
        
        # Изменяем форму массива согласно размерам изображения
        img_array = img_array[:expected_size].reshape((height, width))
        
        # Создаем изображение из массива
        img = Image.fromarray(img_array, mode='L')  # 'L' - 8-битное монохромное
        
        # Сохраняем как PNG
        img.save(output_path, 'PNG')
        
        print(f"Успешно конвертировано: {input_path} -> {output_path}")
        print(f"Размер: {width}x{height}")
        
    except FileNotFoundError:
        print(f"Ошибка: файл {input_path} не найден")
    except Exception as e:
        print(f"Ошибка при конвертации: {e}")

def main():
    parser = argparse.ArgumentParser(description='Конвертер 8-битных монохромных RAW изображений в PNG')
    parser.add_argument('input', help='Входной RAW файл')
    parser.add_argument('output', help='Выходной PNG файл')
    parser.add_argument('width', type=int, help='Ширина изображения')
    parser.add_argument('height', type=int, help='Высота изображения')
    
    args = parser.parse_args()
    
    # Проверяем существование входного файла
    if not os.path.exists(args.input):
        print(f"Ошибка: файл {args.input} не существует")
        return
    
    # Вызываем функцию конвертации
    raw_to_png(args.input, args.output, args.width, args.height)

if __name__ == "__main__":
    main()
