![AQuA Logo](img/logo1s.png)

----------------------------------

AQuA (**A**strocyte **Qu**antification and **A**nalysis) is a tool to detect signalling events from microscopic time-lapse imaging data of astrocytes or other cell types. The algorithm is data-driven and based on machine learning principles, so, potentially, it can be applied across model organisms, fluorescent indicators, experimental modes, cell types, and imaging resolutions and speeds. 

We have developed its improved version, **A**ctivity **Qu**antification and **A**nalysis, AQuA2. It can be found **[here](https://github.com/yu-lab-vt/AQuA2)**.
.

If you have any feedback or issue, you are welcome to either post issue in Issues section or send email to yug@vt.edu (Guoqiang Yu at Virginia Tech).

- [More about AQuA](#more-about-aqua)
  - [From raw data to events](#from-raw-data-to-events)
  - [Extract features from events](#extract-features-from-events)
  - [Graphical user interface](#graphical-user-interface)
- [Download and installation](#download-and-installation)
  - [MATLAB GUI](#matlab-gui)
  - [MATLAB Without GUI](#matlab-without-gui)
  - [Fiji plugin](#fiji-plugin)
- [Getting started](#getting-started)
- [Example datasets](#example-datasets)
- [Reference](#reference)
- [Updates](#updates)

# More about AQuA
## From raw data to events
* In vivo and ex vivo
* GCaMP, GluSnFr 
* And more

![Event detection pipeline of AQuA](img/pipeline.png)

## Extract features from events
* Size and location
* Duration, delta F/F, rising/falling time, decay time constant
* Propagation direction, speed
* And more

![Feature extraction](img/features.png)

## Graphical user interface
* Step by step guide
* Event viewer
* Feature visualizer
* Proofreading and filtering
* Side by side view
* Region and landmark tool
* And more

![User interface](img/gui1.png)

# Download and installation
## MATLAB GUI

1. Download latest version **[here](https://github.com/yu-lab-vt/AQuA/archive/master.zip)**.
2. Unzip the downloaded file.
3. Start MATLAB.
4. Switch the current folder to AQuA's folder.
5. Double click `aqua_gui.m`, or type `aqua_gui` in MATLAB command line.

We tested on MATLAB versions later than 2017a. Earlier versions are not supported.

## MATLAB Without GUI
### Use aqua_cmd.m file
1. Double click `aqua_cmd.m` file.
2. Set the folder path 'p0' and target dataset name 'f0'.
3. Run the file.
4. The output files will be saved in a subfolder of 'p0'.

### Use aqua_batch.m file
1. Double click `aqua_batch.m` file.
2. Set the folder path 'p0', and for each target dataset, set the parameters in `AQuA/cfg/parameters_for_batch.csv`. Each dataset is corresponding to one parameter setting.
3. Run the file.
4. The output files will be saved in subfolders of 'p0'.

## Fiji plugin

1. Download **[here](https://github.com/yu-lab-vt/AQuA-Fiji/releases)**.
2. Put the downloaded `Aqua.jar` to the plugins folder of Fiji.
3. Open Fiji.
4. In the `Plugins` menu, click `Aqua`.
5. Open movie and choose project path in AQuA GUI.

Some browsers may show a warning when downloading the 'jar' file. Please choose 'keep file'.

Note: 
Our updates are mainly on MATLAB platform, but the latest updates have also been synchronized to the Fiji version. Due to the resolution issue and the implementation (some MATLAB functions cannot be found in Java and implemented by authors), there could be slight differences between the results of Fiji version and MATLAB version. 
The Fiji version does not save the results in 'res' data structure in 'mat' file. If users want to obtain the results and process them by themselves, the MATLAB version is more recommended.


# Getting started
If you are using AQuA for the first time, please read
**[the step by step user guide](https://drive.google.com/open?id=1a3lhe0dUth-5J1-S2fZlPOCZlPbeuvUr)**.

Or you can check the **[details on output files, extracted features, and parameter settings](https://drive.google.com/file/d/1CckDLbrkw16b7MPlOQdYpZciIz80Snm_/view?usp=sharing)**.

# Example datasets
You can try these real data sets in AQuA. These data sets are used in the supplemental of the paper.

**[Ex-vivo GCaMP dataset](https://drive.google.com/open?id=13tNSFQ1BFV__42TY0lZbHd1VYTRfNyfD)**

**[In-vivo GCaMP dataset](https://drive.google.com/open?id=1TjfFzlg_6BxsFX_l3-P92M5Rp_5j6wiM)**

**[GluSnFr dataset](https://drive.google.com/open?id=1XFJBE18sQTa6svXXRV1TidgNPSv-ldtY)**

We also provide some synthetic data sets. These are used in the simulation part of the paper.

**[Synthetic data sets](https://drive.google.com/open?id=1ljh-X7vkT7ryjk0mR7PXli_-nYThqK7h)**


# Reference
Yizhi Wang$, Nicole V. DelRosso$, Trisha V. Vaidyanathan, Michelle K. Cahill, Michael E. Reitman, Silvia Pittolo, Xuelong Mi, Guoqiang Yu#, Kira E. Poskanzer#, *Accurate quantification of astrocyte and neurotransmitter fluorescence dynamics for single-cell and population-level physiology*, Nature Neuroscience, 2019, https://www.nature.com/articles/s41593-019-0492-2 ($ co-first authors, # co-corresponding authors)

Yizhi Wang, Nicole V. DelRosso, Trisha Vaidyanathan, Michael Reitman, Michelle K. Cahill, Xuelong Mi, Guoqiang Yu, Kira E. Poskanzer, *An event-based paradigm for analyzing fluorescent astrocyte activity uncovers novel single-cell and population-level physiology*, BioRxiv 504217; doi: https://doi.org/10.1101/504217. [[Link to BioRxiv]](https://www.biorxiv.org/content/early/2018/12/21/504217)


# Updates

**9/28/2023:** 

This update modifies feature names in the output Excel to eliminate the misunderstanding.

**7/10/2023:** 

This update solves one issue not detected before. In some special cases, two connected distinct signals that have a obviously different rising time difference may be considered as one (super) event. This update is to solve it.

**7/04/2023:** 

The major updates of the AQuA framework have been synchronized to the Fiji version.

**3/17/2021:** 

This update allows AQuA to load data with the format of BIGTIFF.

**3/15/2021:** 

This update makes changes in the reading step. Previous version will report error when the input data is a color image since AQuA can only deal with gray image. This updated version will automatically convert the input color image into gray image to avoid the error.

**8/20/2020:** 

This update makes loading preset step compatible with Matlab 2020b.

**5/13/2020:** 

This update changes the exported table's extension from '.xlsx' to '.csv' to avoid the error when the number of detected events is huge.

**5/9/2020:** 

Some users think the results in first step are all they need. This update allows users to skip step 2,3 and 4 so that the first step can be directly used to extract features.

**5/8/2020:** 

This update changes the estimated noise in step 1. Previous version estimated the noise before smoothing and used it to detect active regions, which created inconsistency since the detection is based on the smoothed data. 
This updated version estimates the noise after smoothing. With the accurate estimation, users can feel safe to set the intensity threshold as 2 or 3 instead of adjusting this parameter extensively and empirically.

**2/5/2020:** 

The update solves the problem that AQuA cannot detect event in the first frame and end frame.

**1/18/2020:** 

Add 'Save waves' button in favorite list part. Users could export the waves data of selected events as '.csv' files. 

**1/17/2020:** 

Add area under the curve feature for each event. Users could find them in 'fts.curve' structure. 
Update **[the step by step user guide](https://drive.google.com/open?id=1a3lhe0dUth-5J1-S2fZlPOCZlPbeuvUr)** and **[details on output files, extracted features, and parameter settings](https://drive.google.com/open?id=1assaXYBP6a0OOHrYGYBWjYO2pgwKR3Iu)**.

**1/16/2020:** 

The update adds the features of favorited events into the '.mat' result.

**12/20/2019:** 

Add new functin for cell regions and landmark reigons. The button "->" in the top-left corner of the GUI can let users to drag regions.

**12/19/2019:** 

Solve the issue that the detected events are forced to merge in "aqua_cmd.m" and "aqua_cmd_batch.m".

**12/18/2019:** 

The update fixes one bug existing in 'fix_events'.

**12/3/2019:** 

The update fixes one bug. Now each time "Update features" in GUI is clicked , the proof reading table will be updated.

**11/25/2019:** 

The update changes the GUI panel. Now users could select whether to output feature table or not.  

**11/22/2019:** 

The update saves the use of memory, while the results will not change.

**10/30/2019:** 

The update adds the random seed and makes the random variables controllable. Now with same parameter setting, AQuA will give same results. (Due to the randomness, the results will have a little difference before.)

**10/19/2019:** 

Repair the bug in Fiji version that 'minimum correlation' in merging step cannot be set to float data.

**10/17/2019:** 

1) The update avoids the error report when nothing is detected for `aqua_batch.m`. 

2) Allow `aqua_batch.m` to read a batch of cell boundaries and landmarks.

**10/16/2019:** 

The update adds the new script `aqua_batch.m` which can let users deal with multiple files. **[MATLAB Without GUI](#matlab-without-gui)** shows how to use it.  
