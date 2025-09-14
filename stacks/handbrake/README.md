# HandBrake Video Size Converter

This project provides a tool to automate video conversion using HandBrake.
It re-encodes videos in a watched folder to any preset you define in the web ui, as well as offering customization options for specific conversions through the web browser.

Included in the `examples` folder is an automation script designed to be placed inside `/config/hooks`.
This script automatically compares and selects the smallest version between source and converted video while deleting the larger version.
