#!/bin/sh
#
# This is an example of a post-conversion hook.  This script is always invoked
# with /bin/sh (shebang ignored).
#
# The first parameter is the conversion status.  A value of 0 indicates that
# the video has been converted successfully.  Else, conversion failed.
#
# The second parameter is the full path to the converted video (the output).
#
# The third parameter is the full path to the source file.
#
# The fourth argument is the name of the HandBrake preset used to convert the
# video.
#

CONVERSION_STATUS=$1
CONVERTED_FILE="$2"
SOURCE_FILE="$3"
PRESET="$4"

echo "post-conversion: Status = $CONVERSION_STATUS"
echo "post-conversion: Output File = $CONVERTED_FILE"
echo "post-conversion: Source File = $SOURCE_FILE"
echo "post-conversion: Preset = $PRESET"

if [ "$CONVERSION_STATUS" -eq 0 ]; then
    # Successful conversion.
    CONVERTED_SIZE=$(stat -c%s -- "$CONVERTED_FILE")
    SOURCE_SIZE=$(stat -c%s -- "$SOURCE_FILE")
    if [ $CONVERTED_SIZE -lt $SOURCE_SIZE ]; then
        rm -- "$SOURCE_FILE"
        echo "Deleted larger file '$SOURCE_FILE' (size $SOURCE_SIZE bytes)."
    elif [ $CONVERTED_SIZE -gt $SOURCE_SIZE ]; then
        rm -- "$CONVERTED_FILE"
        echo "Deleted larger file '$CONVERTED_FILE' (size $CONVERTED_SIZE bytes)."
        TARGET_DIR=$(dirname -- "$CONVERTED_FILE")
        mv -- "$SOURCE_FILE" "$TARGET_DIR/"
        echo "Moved '$SOURCE_FILE' into directory '$TARGET_DIR' (kept smaller '$SOURCE_FILE')."
    else
        rm -- "$SOURCE_FILE"
        echo "Both files are the same size ($CONVERTED_SIZE bytes); Deleted $SOURCE_FILE."
    fi
else
    # Failed conversion.
    echo "Conversion of $SOURCE_FILE failed."
fi
