#!/usr/bin/env bash
#
# Author:   Max Rosin
#
# pdfenlarger adds additional white space to a given PDF-file
#
# depends on poppler (pdfinfo) and texlive-core (pdfjam)
#
#

help()
{
    echo "
    Sometimes you need additional white space in your PDF-file. (e.g. for taking notes in Xournal)
    pdfenlarger will do this for you. Just choose the size of the additional space.
    You can also pass a side where the additional space should be added. (Default is right.)

    usage: pdfenlarger.sh <input.pdf> <output.pdf> <additional_space> [top|right|bottom|left]
    example: pdfenlarger.sh input.pdf output.pdf 200 left
    "
}

if [[ ${#} < 3 ]]
then
    help
    exit
fi

input_file=${1}
output_file=${2}
additional_space=${3}

# pdfinfo will give us: Page size:      720 x 540 pts
# so we need do extract the numbers
size=$(pdfinfo ${input_file} | grep -F "Page size" | sed 's/.* \([0-9]\{1,\}\) x \([0-9]\{1,\}\) .*/\1 \2/')
width=$(awk '{print $1}' <<< ${size})
height=$(awk '{print $2}' <<< ${size})

offset_raw=$(( additional_space / 2 ))

# define all parameters for pdfjam to add additional space at the right side
new_height=${height}
new_width=$(( width + additional_space ))
offset_horizontal=$(( -offset_raw ))
offset_vertical=0

# if a fourth parameter is given, we need to check, where the additional space should be added
if [ ${#} == 4 ]
then
    case ${4} in
        top)
            new_height=$(( height + additional_space ))
            new_width=${width}
            offset_horizontal=0
            offset_vertical=$(( -offset_raw ))
        ;;
        right)
            #nothing to do
        ;;
        bottom)
            new_height=$(( height + additional_space ))
            new_width=${width}
            offset_horizontal=0
            offset_vertical=${offset_raw}
        ;;
        left)
            new_height=${height}
            new_width=$(( width + additional_space ))
            offset_horizontal=${offset_raw}
            offset_vertical=0
        ;;
        *)
            help
            exit
        ;;
    esac
fi

pdfjam "${input_file}" -o "${output_file}" --papersize "{${new_width}pt,${new_height}pt}" --offset "${offset_horizontal}pt ${offset_vertical}pt"
