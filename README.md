# Rodent Tracker

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=mathworks/Rodent-Tracker)
[![View Rodent-Tracker on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/107759-rodent-tracker)

Rodent Tracker is a MATLAB&reg; app for measuring the movement of a single
rodent in overhead recordings with a contrasting background. It displays the
segmented animal, an ellipse around its body, and a trace of its centroid,
then produces tables of position, speed, and body shape measurements.

Use rectangular regions of interest (ROIs) to measure occupancy and crossings,
or compare stretch-attend posture (SAP) classifications with manually labeled
frames.

![Rodent Tracker showing tracking controls, image-processing previews, a centroid trace, and measurement results](Rodent%20Tracker_resources/RodentTrackerApp.png)

## Features

- **Tracking preview**: Inspect the original image, binary segmentation,
  tail-removal preview, and fitted ellipse before analyzing a recording.
- **Spatial and temporal measurements**: Export centroid coordinates, speed,
  eccentricity, orientation, area, and ellipse axis lengths.
- **ROI analysis**: Draw rectangles, generate a grid, or use the open-field
  and elevated-plus-maze setup controls.
- **SAP comparison**: Apply eccentricity and speed thresholds and compare
  detections with a supplied ground-truth vector.
- **Results export**: Save measurement tables and preview images, with
  optional tracker and trace videos during analysis.

## Setup

### Start from the Repository

1. Download and extract the complete repository, or clone it.
2. Set the MATLAB **Current Folder** to the repository root, which contains
   `startRodentTracker.m`.
3. Run:

```matlab
app = startRodentTracker;
```

The launcher runs the repository source directly, adds the required folders,
and selects the app format for your MATLAB release. On R2026b or newer it
opens the editable `.m` app in `R2026b`; on earlier releases it opens the
original `.mlapp` app in `Code`.
Keep both folders and `Rodent Tracker_resources` in the repository layout.
The main app creates its companion windows as needed.

The launcher sets **Current Folder** to `R2026b` for the `.m` app, or to the
repository root for the original `.mlapp` app. This keeps file lookup
consistent. Its path additions apply to the current MATLAB session.

To select a format explicitly, use one of these commands:

```matlab
app = startRodentTracker("m");      % MATLAB R2026b or newer
```

```matlab
app = startRodentTracker("mlapp");  % Original App Designer files
```

Use one format per MATLAB session. Close the app and restart MATLAB before
switching formats or switching from an installed copy to the repository
copy. The launcher checks for conflicting copies instead of silently
opening a different version.

### Edit the App in MATLAB R2026b

The [R2026b](R2026b) folder contains the main app and companion apps as
editable `.m` App Designer files, along with their layout XML files and
shared analysis helpers. Keep each app's `.m` and XML files together.
Open [R2026b/RodentTracker.m](R2026b/RodentTracker.m) in App Designer to edit
the main app; launch the app with `startRodentTracker` so that its resources
are available.

The original `.mlapp` files remain in [Code](Code). Changes to one format
are not automatically synchronized to the other.

### Historical Packaged App

[Rodent Tracker.mlappinstall](Rodent%20Tracker.mlappinstall) is an optional
older package, built with MATLAB R2022a. Its bundled code differs from the
current repository source, including some window layouts and menus. The
installer is retained unchanged and has not been rebuilt. The workflow
below describes the repository source.

To use that package, open it in MATLAB, complete the installation dialog,
and select **Rodent Tracker** from the **Apps** tab. If installation or
launching the installed app gives problems, use `startRodentTracker` with a
fresh MATLAB session and the complete repository download.

### MathWorks Products

All formats require
[Image Processing Toolbox&trade;](https://www.mathworks.com/products/image.html).
App Designer is included with MATLAB.

| App format | MATLAB release |
| --- | --- |
| Editable `.m` apps in `R2026b` | R2026b or newer. |
| Original `.mlapp` source in `Code` | Original documented minimum: R2021b. |
| Historical `.mlappinstall` package | R2022a or newer, as declared by its installer metadata. |

Launcher startup was verified on MATLAB R2026a for the original `.mlapp`
files and on R2026b for the editable `.m` files.

See the [MATLAB system requirements](https://www.mathworks.com/support/requirements/previous-releases.html)
for supported operating systems. Video decoding also depends on the formats
and codecs supported by your MATLAB installation.

## Prepare a Recording

Provide your own overhead recording; sample recordings are not included.
Use a fixed camera and a background that contrasts with the animal.

| Input | Preparation |
| --- | --- |
| Video | Use a format supported by [`VideoReader`](https://www.mathworks.com/help/matlab/ref/videoreader.html), such as AVI or a supported MP4 encoding. The app reads the frame rate from the video. |
| Multi-page TIFF | Use a `.tif` stack with one frame per page and provide its frame rate when prompted. |
| Physical dimensions | Measure the width and height of the complete image field in consistent units, such as centimeters. These values calibrate coordinates and speed. |
| Background frame | Make the final frame an unobstructed view of the arena, with the animal removed and the camera unchanged. The app uses this frame as its background reference. |

The final frame is excluded from measurement results. A recording with `N`
frames therefore has `N-1` analyzed frames. The entire recording is loaded
into memory, so start with a short clip when checking a new recording setup.

## Getting Started

1. **Load the recording.** Click the folder button or select **File > Load
   Video**. Enter the physical image width, height, and units. The second
   dimension prompt is currently labeled **Enter image/frame name:**; enter
   the height there. For a TIFF stack, also enter **FPS**.
2. **Check the background and calibration.** Confirm the displayed width,
   height, and FPS. Use **View > Video Background (Last frame)** to inspect
   the reference image. Choose **Dark** or **Light** to match the background.
3. **Inspect the segmentation.** Adjust **Binary Threshold** while viewing
   the analysis preview. The animal should form a distinct foreground
   region. **Structural Element Size** controls the morphological opening
   displayed in **Remove Tail**; see the
   [measurement notes](doc/AnalysisGuide.md#measurement-notes) for how the
   exported measurements are calculated.
4. **Check several points in the recording.** Use **Time (s)** or **Play**
   to inspect tracking over time. **Clear Trace** removes the accumulated
   preview points. The **Edit** menu provides ellipse, centroid, and trace
   color controls.
5. **Define ROIs if needed.** Open **View > ROI Selector**, click **Select
   ROI**, draw a rectangle, and click **Set ROI**. Define these regions
   before running the analysis. See the
   [ROI guide](doc/AnalysisGuide.md#regions-of-interest) for grid and maze
   controls.
6. **Analyze the recording.** Click **Analyze** or select **File > Analyze**.
   In **Analysis Video Settings**, leave both video-save options unchecked
   for a table-only run, then click **Analyze** in that dialog. To request
   optional videos, select their save options and set the directories,
   filenames, and output FPS before continuing.
7. **Save the results.** When analysis finishes, use **File > Save as...**
   in the **Spreadsheet** window. Save ROI results separately in the
   **ROI Results** window. Analysis displays tables but does not
   automatically save them to disk.

The original illustrated Live Editor guide is available in
[doc/GettingStarted.mlx](doc/GettingStarted.mlx). After using the launcher,
open it with:

```matlab
repoFolder = fileparts(which("startRodentTracker"));
open(fullfile(repoFolder, "doc", "GettingStarted.mlx"))
```

Use the installation instructions above for the files supplied in this
repository.

## Results and Export

| Result | Contents | How to save |
| --- | --- | --- |
| Main spreadsheet | One row per analyzed frame: `Eccentricity`, `Speed`, `xcoord`, `ycoord`, `Orientation`, `Area`, `MajorAxisLength`, and `MinorAxisLength`. | **Spreadsheet > File > Save as...** supports MAT, CSV, XLS, and XLSX. MAT files contain a table named `t`. |
| ROI results | Region name and color, time and percentage spent inside, and entry/exit counts. | **ROI Results > File > Save as...** supports the same formats. MAT files contain a table named `ROI_Results`. |
| Preview and trace images | Current analysis-preview window or centroid-trace view. | **File > Save as...** in the respective window supports PNG and JPG. |
| Optional videos | Original frames with a fitted ellipse, or accumulating centroid points on a black background. | Select tracker and/or trace output in **Analysis Video Settings**. Files use Motion JPEG AVI. |

Coordinates use the entered physical units, and speed uses those units per
second. Ellipse axis lengths remain in **pixels** and area remains in
**square pixels**. See the [analysis guide](doc/AnalysisGuide.md) for the full
column definitions, frame timing, ROI counting rules, SAP input format, and
current implementation limitations.

To load a main-spreadsheet MAT file that you saved as `tracking-results.mat`:

```matlab
results = load("tracking-results.mat", "t");
measurements = results.t;
```

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| The installer gives problems, or MATLAB cannot find an app or icon. | Download the complete repository and run `startRodentTracker` from its root. Keep `R2026b`, `Code`, and `Rodent Tracker_resources` together. |
| The launcher reports a loaded-copy or path conflict. | Close Rodent Tracker, restart MATLAB, and run `startRodentTracker` from the intended repository. Avoid adding every subfolder with `genpath`, which mixes app formats. |
| The `.m` app will not open on an earlier release. | The editable `.m` App Designer format requires R2026b or newer. Use `startRodentTracker("mlapp")` for the original files. |
| The ellipse follows an artifact or the animal is not detected. | Inspect the final background frame, choose the appropriate Dark/Light setting, and adjust Binary Threshold. The app selects one region by the largest product of major and minor axis lengths. |
| Speed or coordinates have an unexpected scale. | Check physical dimensions and FPS. Restart the app before loading a recording with different calibration; some calibration values are reused within a session. |
| A result window is hidden. | Use **View > Results > Main Spreadsheet** or **ROI results** after analysis, or **View > Video Window / Trace Window** for previews. |
| A file fails to load or MATLAB runs out of memory. | Check that `VideoReader` can open the encoding, or use a multi-page `.tif`. Try a shorter recording because loading reads all frames into memory. |
| Optional video export or SAP statistics fail. | Consult the [current implementation notes](doc/AnalysisGuide.md#current-implementation-notes). Save the main measurement table before further analysis. |

## Repository Contents

| Path | Purpose |
| --- | --- |
| [startRodentTracker.m](startRodentTracker.m) | Launcher that selects the app format and sets up paths and resources. |
| [R2026b](R2026b) | Editable `.m` App Designer apps, layout XML files, and analysis helpers for R2026b or newer. |
| [Code/RodentTracker.mlapp](Code/RodentTracker.mlapp) | Original main app, tracking callbacks, and measurement calculations. |
| [Code](Code) | Original `.mlapp` companion windows and video-loading/statistics helpers. |
| [Rodent Tracker.mlappinstall](Rodent%20Tracker.mlappinstall) | Historical R2022a app installer; its code differs from the repository source. |
| [Code/Rodent Tracker.prj](Code/Rodent%20Tracker.prj) | Historical app packaging configuration, including paths from the original build machine. |
| [doc/GettingStarted.mlx](doc/GettingStarted.mlx) | Original illustrated guide for the MATLAB Live Editor. |
| [doc/AnalysisGuide.md](doc/AnalysisGuide.md) | Measurement definitions, ROI and SAP workflows, and implementation notes. |
| [Rodent Tracker_resources](Rodent%20Tracker_resources) | App icons and the screenshot used above. |

## Community Support

Use [MATLAB Central](https://www.mathworks.com/matlabcentral) for community
questions. For a reproducible issue, include your MATLAB release, input
format, calibration values, and the steps leading to the problem.

## License and Security

See [license.txt](license.txt) for the BSD 3-Clause license and
[SECURITY.md](SECURITY.md) for security vulnerability reporting instructions.

Copyright 2022 The MathWorks, Inc.
