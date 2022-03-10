# Rodent Tracker

[![View <File Exchange Title> on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/####-file-exchange-title)  

![Alt-Text](https://github.com/mathworks/Rodent-Tracker/blob/main/Rodent%20Tracker_resources/RodentTrackerApp.png?raw=true)

## Setup 

1. Run Rodent Tracker.mlappinstall to install the app
2. Select the Rodent Tracker under the Apps tab wihin MATLAB

or

1. Make sure downloaded files are within your path
2. Run RodentTracker.mlapp


### MathWorks Products (http://www.mathworks.com)

Requires MATLAB release R2021b or newer
- [Image Processing Toolbox&trade;](https://www.mathworks.com/products/image.html)

### System Requirements

[Operating System requirements](https://www.mathworks.com/support/requirements/previous-releases.html)

## Getting Started 

### Description

The multi-window Rodent Tracker app can track the movement of a rodent in overhead view videos that have a contrasting background.
The program overlays an ellipse around the body of the rodent and a trace of the rodent's centroid is graphically recorded.
A spreadsheet of spatial temporal metrics is provided after analysis, which includes speed, eccentricity, x and y coordinates, orientation, major and minor axis length, and area.

### Workflow

1. Open the app after installation.
2. Open video or Multi-TIFF file of a rodent with a contrasting background using the load button provided on the userinterface or select File>Load Video from the menu.
3. Enter the dimensions of the video recording and the video's frame rate.
4. Use sliders or their respective edit fields to adjust the binary threshold, structural element size, and time.
5. Change the Colors of ellipse, centroid marker, or trace by selecting Edit>Analysis Preview>Ellipse>Color, Edit>Analysis Preview>Centroid>Color, and Edit>Trace>Color, respectively. (optional)
6. Adjust algorithm based on video's background contrast by selecting either Dark or Light radio buttons. (optional)
7. Select play to preview analysis over time. (optional)
8. Use the clear trace button to remove scatterpoints in the trace window. (optional)
9. Click the Analyze button or File>Analyze in the menu to analyze the entire video and generate a spreadsheet of results.
10. A window will appear given the user the option of saving video(s) of the tracker and/or the trace. The tracker video contains the original video with an ellipse and centroid overlayed on the rodent. The trace video shows progressive centroid markers of the rodent on top of a black background over time. 

### Video Specifications

Supported video formats include Multi-TIFF files as well as those listed below.
All Platforms: AVI, including uncompressed, indexed, grayscale, and Motion JPEG-encoded video (.avi), Motion JPEG 2000 (.mj2)
All Windows: MPEG-1 (.mpg), Windows Media Video (.wmv, .asf, .asx), Any format supported by Microsoft® DirectShow®
Windows 7 or later: MPEG-4, including H.264 encoded video (.mp4, .m4v), Apple QuickTime Movie (.mov), Any format supported by Microsoft Media Foundation
Macintosh: Most formats supported by QuickTime Player, including: MPEG-1 (.mpg), MPEG-4, including H.264 encoded video (.mp4, .m4v), Apple QuickTime Movie (.mov), 3GPP, 3GPP2, AVCHD, DV
Note: For OS X Yosemite (Version 10.10) and later, MPEG-4/H.264 files play correctly, but display an inexact frame rate.

## License

The license is available in the License file within this repository.

## Community Support
[MATLAB Central](https://www.mathworks.com/matlabcentral)

Copyright 2022 The MathWorks, Inc.

