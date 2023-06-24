# Collaborative_Video_Caching
Decentralized collaborative video caching in edge-caching cellular networks

## Brief Description

In this repository, we provide the MATLAB-based simulation platform for the testing and evaluation of the Collaborative Caching Algorithm (CCA) 
that can minimize the overall video delivery delay through the efficient placement of videos in the caches located in Small-cell Base Stations (SBSs). 

### References:
* S. Mahboob, K. Kar and J. Chakareski, "Decentralized Collaborative Video Caching in 5G Small-Cell Base Station Cellular Networks," 
2021 19th International Symposium on Modeling and Optimization in Mobile, Ad hoc, and Wireless Networks (WiOpt), Philadelphia, PA, USA, 2021,
pp. 1-8, doi: 10.23919/WiOpt52861.2021.9589569.

* S. Mahboob, "Decentralized Collaborative Video Caching in Edge-Caching Cellular Networks." Order No. 28777256, Rensselaer Polytechnic Institute, 
United States -- New York, 2021.

## Datasets

We have used two publicly available datasets based on Netflix [1] and YouTube [2] video streaming platforms which provide various video statistics 
at different timestamps. We have prepared two different types of datasets depending on our own experiment types from these public datasets:

* Video Statistics: These datasets contain statistics for different videos in a .mat file. This file contains a struct that contains
the **"Video ID", "Popularity", and "Video size"**.

* Video Requests: These datasets contain timestamped video requests for different videos in a .txt. file. These requests have the following format:
**"Timestamp", "Video ID", "Video Size", "Requesting SBS ID"**. 

[1] J. Bennett and S. Lanning, “The Netflix Prize,” in Proc. of the KDD Cup Workshop 2007, Aug. 2007, pp. 3–6.

[2] M. Zeni, D. Miorandi, and F. De Pellegrini, “YOUStatAnalyzer: A tool for analyzing the dynamics of YouTube content popularity,” in ValueTools ’13: 
7th Int. Conf. on Perform. Eval. Methodologies and Tools, 2013, p. 286–289. [Online]. Available: https://doi.org/10.4108/icst.valuetools.2013.254391


## Getting Started

### Dependencies

* IBM ILOG CPLEX OPTIMIZATION V12.8 Matlab-connector

### Installation

* Download the files
* Add all the folders with subfolders to the MATLAB path.

### Execution

* run  `main_static_evaluation.m` for static evaluation compared to the optimal solution.
* run  `main_dynamic_evaluation.m` for dynamic evaluation compared to traditional LFU and LRU as well as CCA-Greedy approaches.


### Key Issues to Consider

* Set `dataset` to either `Netflix` or `Youtube` as intended.
* Set `quality` to 0 if different video qualities need not be considered, otherwise put it as 1 (dynamic evaluation)
* If the dependency is not installed, keep `cplex_enabled = 0`, otherwise set it to 1. (static evaluation)

## Authors

Shadab Mahboob

Email: mshadab@vt.edu
