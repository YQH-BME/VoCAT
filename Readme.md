This document explains how to use VoCAT:

# VoCAT is recommended to run on MATLAB R2024b or higher versions.

# There are two ways to run VoCAT: 
1. Install the VoCAT App using the 'VoCATApp.mlappinstall'file in MATLAB. After installation, the app is ready for use.
2. Run it through the VoCAT.exe file located in the 'VoCATApp' folder, which requires MATLAB Runtime to be installed on the computer. 
The first method is recommended by the authors as it offers better performance.

# VoCAT is used to analyze 3D chip microvascular fluorescence images. The recommended workflow is as follows:
1. Click the "Data Load" button and select a 3D microvascular image in tif or tiff format.
2. Set basic parameters, including Pixel Size, downsampling ratio, and the range for vessel radius and diameter.
3. Click the "Segment" button. If you choose the Deep Learning segmentation method, a file selection window will pop up to choose the segmentation network. You can select the LUNet.mat file from the Trained Network folder, or if you have trained your own network, you can select that.
4. After segmentation is complete, you can click the "Preview" button to preview the segmentation results or click the "Vessel Analysis" button to analyze vascular feature parameters.
5. After analysis, you can click "Save Result" to save the morphological feature parameters locally in xlsx, or right-click the "Preview" button under the "Analysis Results Figure" to generate a vascular skeleton feature map.

# Finally, for users with basic programming knowledge, the 'VoCAT_process_batch.m' script can be used to process large batches of image data. The segmented and analyzed results will be saved as .mat files in the same directory as the image data, and use the 'Data_Convert.m' to transfer the analysis results to xlsx.