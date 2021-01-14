//	
//	ImageJ/Fiji
//	
//	Macro to count number of cells in an image based on DAPI signal
//	Then extract the total fluorescence signal from another channel
//	Files need to be ".tif" and there need to be one file of DAPI and one of fluorescence
//	
//	The number of cells is registered in a txt file and the total fluo value
//	is saved in an Excel file. You need to add in Excel the number of cell
//	and divide the total fluorescence by the number of cells
//	
//	Works nicely for 40x images, 10x is too small and many cells are not properly separated
//	
//	C.Henry, 2019-03-03, V1
//	


// Define Path of the main folder containing subfolders "1_DAPI" and 2_Fluo"
dir1 = getDirectory("Choose Directory Containing the Images");

dir2 = dir1 + "1_DAPI\\";
if (File.exists(dir2)!=1) {
	exit("ERROR, no \"1_DAPI\" folder, create a Folder containing the DAPI images");
}
list2 = getFileList(dir2);

dir3 = dir1 + "2_Fluo\\";
if (File.exists(dir3)!=1) {
	exit("ERROR, no \"2_Fluo\" folder, create a Folder containing the Fluorescence images");
}
list3 = getFileList(dir3);

dir4 = dir1 + "3_ROIs\\";
if (File.exists(dir4)!=1) {
	File.makeDirectory(dir2);
}

// Set the measurements settings
run("Set Measurements...", "integrated redirect=None decimal=2");
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_column save_row");

// Close Log, Results and images windows if open and remove the ROIs if there is any
close("Log");
close("Results");
if (roiManager("count")>0) {
	roiManager("deselect");
	roiManager("delete");
}
if (nImages()>0) {
	close("*");
}

// Determine the number of cells using the DAPI signal
// and save the ROIs to check for the quality of the segmentation
for (i=0; i<list2.length; i++) {
	if (endsWith(list2[i],"tif")>=1) {
		A = dir2+list2[i];
		open(A);
		Title_Image = getTitle();

		// Prepare image for segmentation
		run("8-bit");
		run("Subtract Background...", "rolling=100 sliding");
		run("Subtract Background...", "rolling=10 create sliding");
		
		// Create binary image and separate the cells
		setAutoThreshold("Default dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Watershed");
		
		// Create one ROI for each cell and count them
		run("Create Selection");
		roiManager("Add");
		roiManager("Select", 0);
		roiManager("Split");
		roiManager("Select", 0);
		roiManager("Delete");
		roiManager("Save", dir4 + Title_Image + "_RoiSet.zip");
		nROIs = roiManager("count");
		print (nROIs);
		roiManager("Delete");
		close("*");
	}
}

// Extract fluorescence signal of the whole image (cropped)
for (i=0; i<list3.length; i++) {
	if (endsWith(list3[i],"tif")>=1) {
		A = dir3+list3[i];
		open(A);
		
		// Create a ROI of the image size
		makeRectangle(0, 0, getWidth(), getHeight());
		roiManager("Add");
		
		// Convert and measure fluorescence of the image
		run("8-bit");
		roiManager("measure");
		roiManager("Delete");
		
		close("*");
	}
}

// Save the Logs and Results
selectWindow("Log");
saveAs("Text", dir1 + "CellCountPerImage.txt");
selectWindow("Results");
saveAs("Measurements", dir1 + "FluorescencePerImage.xls");

print ("Job done");
selectWindow("Log");
