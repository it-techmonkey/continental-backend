import os
from PIL import Image, ImageFilter

def process_image(input_path, output_path, target_size=(1080, 1920)):
    with Image.open(input_path) as img:
        # Create a new background image with target size
        bg = img.resize(target_size, Image.Resampling.LANCZOS)
        bg = bg.filter(ImageFilter.GaussianBlur(radius=20))
        
        # Calculate aspect ratios
        img_aspect = img.width / img.height
        target_aspect = target_size[0] / target_size[1]
        
        # Resize input image to fit within target size (keeping aspect ratio)
        if img_aspect > target_aspect:
            # Image is wider, fit width
            new_width = target_size[0]
            new_height = int(new_width / img_aspect)
        else:
            # Image is taller, fit height
            new_height = target_size[1]
            new_width = int(new_height * img_aspect)
            
        resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Paste centered
        x = (target_size[0] - new_width) // 2
        y = (target_size[1] - new_height) // 2
        
        bg.paste(resized_img, (x, y))
        bg.save(output_path, "PNG")

def main():
    files = [f for f in os.listdir('.') if f.startswith('uploaded_image_') and f.endswith('.jpg')]
    files.sort()
    
    for i, f in enumerate(files):
        out_name = f"tablet_screenshot_{i+1}.png"
        print(f"Processing {f} -> {out_name}")
        process_image(f, out_name)

if __name__ == "__main__":
    main()
