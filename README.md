**BoutonAnalyzer** is software for detection and tracking of structural changes in *en passant* boutons in time-lapse light-microscopy stacks of images, developed by the Neurogeometry lab. The related publication for this repository:

#### [Computer assisted detection of axonal bouton structural plasticity in in vivo time-lapse images](https://elifesciences.org/articles/29315)
>*Abstact:* The ability to measure minute structural changes in neural circuits is essential for long-term in vivo imaging studies. Here, we propose a methodology for detection and measurement of structural changes in axonal boutons imaged with time-lapse two-photon laser scanning microscopy (2PLSM). Correlative 2PLSM and 3D electron microscopy (EM) analysis, performed in mouse barrel cortex, showed that the proposed method has low fractions of false positive/negative bouton detections (2/0 out of 18), and that 2PLSM-based bouton weights are correlated with their volumes measured in EM (r = 0.93). Next, the method was applied to a set of axons imaged in quick succession to characterize measurement uncertainty. The results were used to construct a statistical model in which bouton addition, elimination, and size changes are described probabilistically, rather than being treated as deterministic events. Finally, we demonstrate that the model can be used to quantify significant structural changes in boutons in long-term imaging experiments.

### Requirements ###

* MATLAB for Mac or Windows, version 2015a or higher

### Installation ###

* Download/clone the repository
* Launch MATLAB and navigate to the software folder
* Type `BoutonAnalyzer` in the MATLAB command window
* Set paths to the Images, Traces, Profiles, and Results folders in the BoutonAnalyzer main window

### User Manual and Demos ###

* User Manual is included in the repository
* [Video demo: Optimize Trace and Generate Profile GUI](https://www.youtube.com/watch?v=-QsEobWRVZE) 
* [Video demo: Detect and Track Boutons GUI](https://www.youtube.com/watch?v=UoGCRKXuuWc)

### Sample Data ###

* Sample data to test the software can be obtained at http://www.northeastern.edu/neurogeometry/resources/bouton-analyzer/
* This dataset includes three image stacks acquired in a time-lapse manner within an hour (courtesy of [Holtmaat Lab](https://neurocenter-unige.ch/research-groups/anthony-holtmaat/)) and traces of three axons reconstructed in all imaging sessions.

### Contact ###

* Rohan Gala rhngla@gmail.com
* Armen Stepanyants a.stepanyants@northeastern.edu

