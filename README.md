# Analysis of Swiss National Air Pollution Monitoring Network (NABEL) Measurements

This module is an exercise for analyzing NABEL air quality monitoring network data assigned in the Air Pollution and Climate Change (ENV-400) Masters class at EPFL. Students are assumed to have a little programming background, mostly in MATLAB/Octave.

<center>
<figure>
<img src="./contents/figures/NABEL_Network.png" alt="from _Stations de mesure NABEL_" width="50%"/>
</figure>
<figcaption>
Image source: *Stations de mesure NABEL* report available at [this site](http://www.bafu.admin.ch/luft/00612/00625/index.html?lang=en)
</figcaption>
</center>
<br>

In many fields of environmental engineering, a central task is to make sense of large amounts of monitoring data. We wish to summarize these observations in ways that are useful to a) scientists and b) people who make regulatory decisions. To this end, this module introduces methods for generating concise descriptions of temporal and spatial patterns (of individual variables or their relationships), and explaining changes in concentrations due to emissions and atmospheric processes. We introduce some useful concepts for structuring and operating on such data sets that will facilitate exploratory analysis and rapid testing of hypotheses.

Topics addressed are the following:

1. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/01_Rintro.html" target="_blank">Motivating Example</a>
2. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/02_projectdef.html" target="_blank">Assignment definition</a>
3. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/03_Rbasics.html" target="_blank">R basics</a>
4. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/04_tseriesviz.html" target="_blank">Visualizing time series</a>
5. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/05_correlations.html" target="_blank">Correlations and cross-correlations</a>
6. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/06_signal.html" target="_blank">Autocorrelation and periodicity</a>
7. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/07_stochastic.html" target="_blank">Stochastic processes and random variables</a>
8. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/08_inferential.html" target="_blank">Inferential statistics and hypothesis testing</a>
9. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/09_extremevals.html" target="_blank">Extreme values: detection and accommodation</a>
10. <a href="http://rawgit.com/stakahama/aprl-env400-assignment/master/contents/10_wind.html" target="_blank">Considering meteorology (wind directions)</a>

We recommend interfacing with R through [RStudio](http://rstudio.com/), which you can also download on your own machine. You can set `Sessions -> Set Working Directory -> To Source File Location` so that input/output of files will be managed through this working directory on your computer.

The R code in this module is partially written with pedagogical intentions, so may not be the most efficient.
