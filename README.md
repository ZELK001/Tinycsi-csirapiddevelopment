# TinyCSI
A rapid development platform for CSI-based sensing systems. TinyCSI provides a Matlab/C-based library and a Graphical User Interface (GUI) for developers to quickly realize their ideas.

## Feature

* The first API library and hide node connection/transmission details to ease the development of these systems.
 
* We provide three working mode for developers to meet different developing requirements: A remote mode for adjusting algorithms or parameters in real time; An efficient mode for maximizing the use of computing resources of sensing nodes and server; A standalone mode for individually producing sensing results on the node in offline environments.
  

## CSI-based Sensing System


In modern WiFi networks, the communication channel using Orthogonal Frequency Division Multiplexing (OFDM) comprises of multiple orthogonal subcarriers at different frequencies. CSI captures how wireless signals propagates from the transmitter to the receiver at a granularity of subcarrier level. Some COTS NICs can report CSI from the driver to upper layer applications. For example, Intel 5300 NIC can report CSI measurements of 30 subcarriers for each received WiFi packet. Each CSI measurement is a complex value representing the signal fading on a specific subcarrier.

Due to the ubiquitous WiFi signals, CSI-based approaches have been widely studied to achieve device-free sensing. CSI based sensing systems record the CSI changes of one or more wireless links and then provide context-aware computations. We classify existing CSI-based sensing systems into three major categories, i.e. motion detection,location awareness and CSI fingerprinting.


# Remote Mode
In the remote mode, TinyCSI provides a GUI for developers to iteratively validate and tune their callback functions. With the API library and visualization of TinyCSI, developers can rapidly determine their callback functions (including both algorithms and parameters) to adapt to different environments.


## Install

### Prerequisites

* Matlab 2014b or later (see uicontrol compatibility for an earlier version).

* Sensing nodes (Humming Board equipped with Intel 5300 NIC. The [CSI tool](http://dhalperi.github.io/linux-80211n-csitool/index.html) is installed on the nodes) and a commercial wireless router (WiFi AP). 

* Network connections between  Matlab machine and Sensing Node.

### Setup
* Copy Tinycsi-csirapiddevelopment\APIcode\Platform\Server\servercode.jar to MATLAB\R2014b\sys\java\jre\win64\jre\lib\ext.

* Init csi sampling code on Sensing Node 


* Startup the sensing node,use ssh to connect to the node and run WiFiStartup.sh to connect to wireless router.

* Then start to collect the csi data:
```
  cd humandetectionusingcsi/code/display/onlineDisplay
  
  ./collectCSIShownRealTime.sh (Sampling Rate) (PC IP Address) (csidata filename)
```
 


### Usage
* Run MatLab,Let's use our MotionDetection as an example. In this example,Matlab server is programmed to ask the 

  connected  device to get real csi data for analyzing the frequency response between Tx and Rx.
  
  Enter the path: Tinycsi-csirapiddevelopment/APIcode/APILibrary

```
  cd Tinycsi-csirapiddevelopment/APIcode/APILibrary
  
```

* Run MotionDetectionMain.m and wait snesing node connect.

* Let Sensing node connect to sensingserver, and start sampling csi.

* Sensingserver receives csi data and analysize the data.


# Efficient Mode
In the efficient mode, TinyCSI seeks the best resource allocation scheme (i.e., which APIs run on the node and which run on the server) to minimize the system sensing delay. The efficient mode is designed for making full use of the computing resources and improve system efficiency.

# Standalone Mode
In the standalone mode, the whole sensing system can be migrated to individual nodes and run without connecting to the remote server. The standalone mode is designed for offline sensing systems when the deployment environment cannot meet networking requirements.
