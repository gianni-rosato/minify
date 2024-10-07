# minify.sh

Make tiny images even tinier.

A powerful and flexible image minification script designed for lossless compression of small images.

## Features

- Supports **multiple codecs**: WebP, JPEG XL, & PNG
- **Adjustable effort levels** for fine-tuned compression
- **Animated WebP** support
- **Brute force option for WebP** to find the optimal compression settings

## Dependencies

- `cwebp` (for WebP encoding)
- `cjxl` (for JPEG XL encoding)
- `ect` (for PNG optimization)
- `ffmpeg` (for animated WebP encoding)
- `gum` (for progress spinners)

Ensure these dependencies are installed and available in your system's PATH.

## Usage

```md
**minify.sh** | Compact lossless encoding script designed for small images

Usage:
	minify.sh -i <input> -o <output> [-c <codec>] [-e <effort>]

Options:
	-i <input>	Input image file
	-o <output>	Output image file
	-c <codec>	Codec to use (webp, jxl, png; default: webp)
	-e <effort>	Effort level (1-9 for WebP, 1-10 for JPEG XL, 1-9 for PNG; default: 7. Use 'max' for extreme effort)
Dependencies:
	- cwebp (WebP)
	- cjxl (JPEG XL)
	- ect (PNG)
	- ffmpeg (Animated WebP)
	- gum (CLI spinner)
```

### Options

- `-i <input>`: Input image file
- `-o <output>`: Output image file
- `-c <codec>`: Codec to use (webp, jxl, png; default: webp)
- `-e <effort>`: Effort level (1-9 for WebP, 1-10 for JPEG XL, 1-9 for PNG; default: 7. Use 'max' for extreme effort)

### Examples

1. Compress an image using default settings (WebP, default effort):
   ```bash
   ./minify.sh -i input.png -o output.webp
   ```

2. Use JPEG XL codec with maximum effort:
   ```bash
   ./minify.sh -i input.png -o output.jxl -c jxl -e max
   ```

3. Optimize a PNG with effort level 5:
   ```bash
   ./minify.sh -i input.png -o output.png -c png -e 5
   ```

4. Create an animated WebP:
   ```bash
   ./minify.sh -i input.gif -o output.webp -c awebp
   ```

## Features Explained

- **WebP Encoding**: Uses `cwebp` for standard WebP compression and `ffmpeg` for animated WebP.
- **JPEG XL Encoding**: Utilizes `cjxl` for high-quality, next-generation image compression.
- **PNG Optimization**: Employs `ect` for efficient PNG compression.
- **Effort Levels**: Allows fine-tuning of compression intensity across all supported codecs.
- **Max Effort**: Max-effort WebP actually brute forces all effort options from 1 through 9, as effort 9 isn't always the best with `cwebp`.

## Output

The script provides colorized output showing:
- The encoding process being used
- Input and output file sizes
- Best effort level (for WebP max effort mode)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions, issues, and feature requests are welcome.
