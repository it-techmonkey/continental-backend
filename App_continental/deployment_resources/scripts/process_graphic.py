from PIL import Image

def resize_and_crop(image_path, output_path, size):
    with Image.open(image_path) as im:
        # Get dimensions
        width, height = im.size
        target_width, target_height = size
        
        # Calculate aspect ratios
        aspect = width / height
        target_aspect = target_width / target_height
        
        if aspect > target_aspect:
            # Image is wider than target
            new_height = target_height
            new_width = int(aspect * new_height)
        else:
            # Image is taller than target
            new_width = target_width
            new_height = int(new_width / aspect)
            
        resized_im = im.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Center crop
        left = (new_width - target_width) / 2
        top = (new_height - target_height) / 2
        right = (new_width + target_width) / 2
        bottom = (new_height + target_height) / 2
        
        cropped_im = resized_im.crop((left, top, right, bottom))
        cropped_im.save(output_path)

if __name__ == "__main__":
    resize_and_crop("feature_graphic_raw.png", "feature_graphic.png", (1024, 500))
    print("Feature graphic created: feature_graphic.png")
