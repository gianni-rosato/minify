#!/bin/bash

# ANSI color codes
YLW='\033[0;33m'
NC='\033[0m'
RESET='\033[0m'
GREEN='\033[0;32m'
GREY='\033[0;37m'
BOLD='\033[1m'

show_usage() {
    echo -e "${BOLD}minify.sh${RESET} | Compact lossless encoding script designed for small images\n"
    echo -e "${GREY}Usage${RESET}:\n\t$0 -i <${YELW}input${RESET}> -o <${YELW}output${RESET}> [${GREY}-c <codec>${RESET}] [${GREY}-e <effort>${RESET}]\n"
    echo -e "${GREY}Options${RESET}:"
    echo -e "\t-i <input>\tInput image file"
    echo -e "\t-o <output>\tOutput image file"
    echo -e "\t-c <codec>\tCodec to use (webp, jxl, png; default: webp)"
    echo -e "\t-e <effort>\tEffort level (1-9 for WebP, 1-10 for JPEG XL, 1-9 for PNG; default: 7. Use 'max' for extreme effort)"
    echo -e "${GREY}Dependencies${RESET}:"
    echo -e "\t- cwebp (WebP)"
    echo -e "\t- cjxl (JPEG XL)"
    echo -e "\t- ect (PNG)"
    echo -e "\t- ffmpeg (Animated WebP)"
    echo -e "\t- gum (CLI spinner)"
    exit 1
}

get_size() {
    local size
    local operating_system
    local input

    operating_system=$(uname)
    input="$1"

    if [ "$operating_system" == "Darwin" ]; then
        size=$(stat -f '%z' "$input")
    else
        size=$(stat --printf=%s "$input")
    fi

    echo "$size"
}

encode_webp() {
    local input
    local output
    local effort

    input="$1"
    output="$2"
    effort="$3"

    # Clamp effort between 1 and 9
    if (( effort < 1 )); then
        effort=1
    elif (( effort > 9 )); then
        effort=9
    fi

    gum spin --spinner points --title "Encoding with Lossless WebP effort $effort ..." -- \
    cwebp -mt -lossless -z "$effort" -alpha_filter best -metadata icc "$input" -o "$output" || \
    eval "$(echo -e "${RED}Failed to encode WebP${NC}" && exit 1)"
    echo -e "WebP Effort ${effort}: $(get_size "$input") -> ${YLW}$(get_size "$output")${NC} bytes"
}

encode_webp_brute() {
    local input
    local output
    local best_size
    local best_effort
    local base_name

    input="$1"
    output="$2"
    base_name="${output%.*}"
    best_size=9999999999
    best_effort=0

    for effort in {1..9}; do
        encode_webp "$input" "${base_name}_z${effort}.webp" "$effort"
        current_size=$(get_size "${base_name}_z${effort}.webp")

        if (( current_size < best_size )); then
            best_size=$current_size
            best_effort=$effort
        fi

        echo -e "Effort $effort: ${YLW}$current_size${NC} bytes"
    done

    # Remove all except the best one
    for effort in {1..9}; do
        if [ "$effort" != "$best_effort" ]; then
            rm "${base_name}_z${effort}.webp"
        fi
    done

    mv "${base_name}_z${best_effort}.webp" "$output"
    echo -e "Best effort: ${GREEN}$best_effort${NC} at ${GREEN}$best_size${NC} bytes"
    echo -e "WebP Max Effort: $(get_size "$input") -> ${YLW}$(get_size "$output")${NC} bytes"
}

encode_webp_anim() {
    local input
    local output

    input="$1"
    output="$2"

    gum spin --spinner points --title "Encoding animated Lossless WebP ..." -- \
    ffmpeg -y -i "$input" -pix_fmt bgra -c:v libwebp_anim -lossless 1 -compression_level 6 "$output" || \
    eval "$(echo -e "${RED}Failed to encode WebP animation${NC}" && exit 1)"
    echo -e "Animated WebP: $(get_size "$input") -> ${YLW}$(get_size "$output")${NC} bytes"
}

encode_jxl() {
    local input
    local output
    local effort

    input="$1"
    output="$2"
    effort="$3"

    # Clamp effort between 1 and 10
    if [ "$effort" == "max" ]; then
        effort=11
    elif (( effort < 1 )); then
        effort=1
    elif (( effort > 10 )); then
        effort=10
    fi

    gum spin --spinner points --title "Encoding with Lossless JPEG XL effort $effort ..." -- \
    cjxl "$input" "$output" -d 0 -e "$effort" --allow_expert_options || \
    eval "$(echo -e "${RED}Failed to encode with cjxl${NC}" && exit 1)"
    echo -e "JXL Effort ${effort}: $(get_size "$input") -> ${YLW}$(get_size "$output")${NC} bytes"
}

optimize_png() {
    local input
    local output
    local effort

    input="$1"
    output="$2"
    effort="$3"

    if [ "$effort" == "max" ]; then
        effort=9999
    elif (( effort < 1 )); then
        effort=1
    elif (( effort > 9 )); then
        effort=9
    fi

    cp "$input" "$output"
    gum spin --spinner points --title "Encoding Optimized PNG at effort $effort ..." -- \
    ect -"${effort}" --mt-deflate -strip "$output" || eval "$(echo -e "${RED}Failed to encode with ect${NC}" && exit 1)"
    echo -e "PNG Effort ${effort}: $(get_size "$input") -> ${YLW}$(get_size "$output")${NC} bytes"
}

codec="webp"
effort=7

while getopts ":i:o:c:e:" opt; do
    case ${opt} in
        i ) input=$OPTARG ;;
        o ) output=$OPTARG ;;
        c ) codec=$OPTARG ;;
        e ) effort=$OPTARG ;;
        \? ) show_usage ;;
    esac
done

# If no input or output, show usage
if [ -z "$input" ] || [ -z "$output" ]; then
    show_usage
fi

main() {
    case $codec in
        webp )
            case $effort in
                "max" )
                    encode_webp_brute "$input" "$output"
                    ;;
                * )
                    encode_webp "$input" "$output" "$effort"
                    ;;
            esac
            ;;
        awebp )
            encode_webp_anim "$input" "$output"
            ;;
        jxl )
            encode_jxl "$input" "$output" "$effort"
            ;;
        png )
            optimize_png "$input" "$output" "$effort"
            ;;
        * )
            echo "Unsupported codec: $codec"
            exit 1
            ;;
    esac
}

main
