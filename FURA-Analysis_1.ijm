//	
//	ImageJ/Fiji script
//	
//	Originally design for analysis of FURA-2 experiments using 340 nm and 380 nm files
//	generated from Visiview acquisition software with 2 channels recorded named "340nm" and "380nm"
//	
//	Open tif or stk images and the associated BG (Background) and cell ROIs (Region Of Interest)
//	to remove the BG and extract the average fluorescence signal from the cells ROIs
//	It will export the average fluorescence values in txt files
//	
//	
//	INSTRUCTIONS:
//	Put all the images into a folder named "1_Images"
//	Add an identification at the beginning of each dish name in the format: "Dishxxx"
//	(the capital letter is important)
//	Create 2 set of ROIs to put in a folder named "2_ROIs", 1 for background subtraction and 1 for the cells to measure:
//		with the corresponding identification "Dishxxx" ending with _BG		(Capital letters are important)
//		with the corresponding identification "Dishxxx" ending with _cells	(no capital letter)
//	/!\ The ROI for the background needs to be named with "Dishxxx" directly when you save it from ImageJ/Fiji
//	Open this script in Fiji or ImageJ (drag and drop), click on run (Ctrl + R)
//	
//	You can then stop here or start the second part of this script in Excel (FURA-Analysis_2.xlsm)
//	Works only for FURA-2 experiments with 340 nm and 380 nm files
//	
//	
//	Christopher Henry - V2 - 2020-06-24
//	


// Define the paths
dir1 = getDirectory("Choose Main Directory");
dir2 = dir1 + "1_Images\\";
if (File.exists(dir2)!=1) {
	File.makeDirectory(dir2);
	// move the images to the new folder
	list1 = getFileList(dir1);
	for (i=0; i<list1.length; i++) {
		if (endsWith(list1[i],"stk")>=1 || endsWith(list1[i],"tif")>=1 || endsWith(list1[i],"nd")>=1) {
			File.rename(dir1+list1[i], dir2+list1[i]);
		}
	}
}
dir3 = dir1 + "2_ROIs\\";
if (File.exists(dir3)!=1) {
	File.makeDirectory(dir3);
	// move the ROIs to the new folder
	list1 = getFileList(dir1);
	for (i=0; i<list1.length; i++) {
		if (endsWith(list1[i],".roi")>=1 || endsWith(list1[i],"zip")>=1) {
			File.rename(dir1+list1[i], dir3+list1[i]);
		}
	}
}
dir4 = dir1 + "3_Analysis\\";
if (File.exists(dir4)!=1) {
	File.makeDirectory(dir4);
}

// Get the files from path
list2 = getFileList(dir2);
list3 = getFileList(dir3);

// Set ImageJ/Fiji setting for measurements
run("Set Measurements...", "mean redirect=None decimal=2");
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_column save_row");

for (i=0; i<list2.length; i++) {
		if (endsWith(list2[i],"stk")>=1 || endsWith(list2[i],"tif")>=1) {
// Open stk files in the image folder
		A = dir2+list2[i];
		if (endsWith(list2[i],"stk")>=1) {
			PathTextFile = dir4 + replace(list2[i], ".stk", ".txt");
		}
		else if (endsWith(list2[i],"tif")>=1) {
			PathTextFile = dir4 + replace(list2[i], ".tif", ".txt");
		}
		open(A);
// Extract the dish number to open the right ROIs
		FileName = getTitle();
		FileNameDishIndex = indexOf(FileName, "Dish");
		FileDishNumber = substring(FileName, FileNameDishIndex, FileNameDishIndex + 7);
// Open BG ROI and remove BG
		for (j=0; j<list3.length; j++) {
			TestDish = indexOf(list3[j], FileDishNumber) != -1;
			TestBG = indexOf(list3[j], "BG") != -1 || indexOf(list3[j], "bg") != -1;
			if (TestDish && TestBG) {
				roiManager("open", dir3 + list3[j]);
				roiManager("select", 0);
				roiManager("Multi Measure");
				roiManager("deselect");
				roiManager("Delete");
				run("Select None");
				ColName = split(String.getResultsHeadings);
				for (k=1; k<nSlices+1; k++){
					setSlice(k);
					BgToSub = getResult(ColName[0], k-1);
					run("Subtract...", "value=" + BgToSub);
				}
				j = list3.length;
			}
		}
// Open cells ROI and measure mean intensity
		for (j=0; j<list3.length; j++) {
			TestDish = indexOf(list3[j], FileDishNumber) != -1;
			TestCell = indexOf(list3[j], "cell") != -1 || indexOf(list3[j], "Cell") != -1;
			if (TestDish && TestCell) {
				roiManager("open", dir3 + list3[j]);
				roiManager("Multi Measure");
				String.copyResults;
				TextFileOutput = File.open(PathTextFile);
				print(TextFileOutput, String.paste);
				File.close(TextFileOutput);
				roiManager("Delete");
				j = list3.length;
			}
		}
	close("*");
	close("Results");
	}
}
print("Job done");
selectWindow("Log");
