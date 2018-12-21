![AQuA Logo](img/logo1s.png)

----------------------------------

AQuA (**A**strocyte **Qu**antification and **A**nalysis) is a tool to detect events from microscopic time-lapse imaging data of astrocytes. The algorithm is data-driven and based on machine learning principles, so it can potentially be applied across model organisms, fluorescent indicators, experimental modes, cell types, and imaging resolutions and speeds.

- [More about AQuA](#more-about-aqua)
  - [From raw data to events](#from-raw-data-to-events)
  - [Extract features from events](#extract-features-from-events)
  - [Graphical user interface](#graphical-user-interface)
- [Download and installation](#download-and-installation)
  - [MATLAB GUI](#matlab-gui)
  - [Fiji plugin (coming soon)](#fiji-plugin-coming-soon)
- [Getting started](#getting-started)
- [Example datasets](#example-datasets)
- [Reference](#reference)

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

## Fiji plugin (coming soon)

1. Download **[here]()**.
2. Put the downloaded `Aqua.jar` to the plugins folder of Fiji.
3. Open Fiji.
4. In the `Plugins` menu, click `Aqua`.
5. Open movie and choose project path in AQuA GUI.

Some browsers may show a warning when downloading the 'jar' file. Please choose 'keep file'.
**The Fiji plugin is still under testing**.

# Getting started
If you are using AQuA for the first time, please read
**[the step by step user guide](https://drive.google.com/open?id=1vUZP44KG3B4m4LZXfzcauiyp-Sqd0eJ1)**.

Or you can check the **[details on output files, extracted features, and parameter settings](https://drive.google.com/open?id=1U3oJpEFwv0lXdax6efSnoifcYjJuRzj3)**.

# Example datasets
You can try these real data sets in AQuA. These data sets are used in the supplemental of the paper.

**[Ex-vivo GCaMP dataset](https://drive.google.com/open?id=13tNSFQ1BFV__42TY0lZbHd1VYTRfNyfD)**

**[In-vivo GCaMP dataset](https://drive.google.com/open?id=1TjfFzlg_6BxsFX_l3-P92M5Rp_5j6wiM)**

**[GluSnFr dataset](https://drive.google.com/open?id=1XFJBE18sQTa6svXXRV1TidgNPSv-ldtY)**

We also provide some synthetic data sets. These are used in the simulation part of the paper.

**[Synthetic data sets](https://drive.google.com/open?id=1ljh-X7vkT7ryjk0mR7PXli_-nYThqK7h)**


# Reference
Paper draft in preparation.

