//  
//	ImageJ/Fiji script
//  
//  Script to automaticcaly do segmentation of images based on a channel of interest
//  Initially used to detect membrane contact sites within cells acquired
//  on TIRF (Total Internal Reflection Fluorescence) microscopy
//  
//  I need to put single channel .tif into folder 1_Images
//  and to have a folder architecture as such:
//    MainDirectory: 1_Images / 2_ROIs / 3_Analysis
//    1_Images: TIRF_Images
//    2_ROIs: 1_cells / 2_MCS / 3_BG
//  
//  Christopher Henry - V1 - 2020/03/21
//  


// Set paths
dir1 = getDirectory("Choose Main Directory");
dir2 = dir1 + "1_Images\\TIRF_Images\\";
dir3 = dir1 + "2_ROIs\\";
dir3_1 = dir3 + "1_cells\\";
dir3_2 = dir3 + "2_MCS\\";
dir3_3 = dir3 + "3_BG\\";
dir4 = dir1 + "3_Analysis\\";

// Get files from path
list2 = getFileList(dir2);
list3_1 = getFileList(dir3_1);
list3_3 = getFileList(dir3_3);

// Set the extension of the images
Extension = ".tif";
// Create a number of images to open to find maxima
MaximaNumber = 8;


// Open image files
for (i=0; i<list2.length; i++) {
	if (endsWith(list2[i], Extension) >= 1) {
// Open file
		A = dir2 + list2[i];
		run("Open...", "path=A");
// Extract the dish number
		ImageName = getTitle();
		ImageNameDishIndex = indexOf(ImageName, "dish");
		if (ImageNameDishIndex == -1) {
			ImageNameDishIndex = indexOf(ImageName, "Dish");
		}
		ImageDishNumber = substring(ImageName, ImageNameDishIndex, ImageNameDishIndex + 11);
// Clean the image before further processing
		run("Grays");
		setLocation(40, 50);
		
		BgSubNotDone = true;
		for (l=0; l<list3_3.length; l++) {
			TestDish = indexOf(list3_3[l], ImageDishNumber) != -1;
			if (TestDish) {
				BgRoiName = list3_3[l];
				BgFromRoi(dir3_3, ImageName, BgRoiName);
				BgSubNotDone = false;
			}
		}
		if (BgSubNotDone) {
			BgFromRoi_Int(dir3_3, Extension, ImageName);
		}
		
		//run("Subtract Background...", "rolling=10");
		run("Subtract Background...", "rolling=10 disable");
		//run("Unsharp Mask...", "radius=10 mask=0.6");
		run("Enhance Contrast", "saturated=0.1");
		setTool("hand");
		selectWindow(ImageName);
		rename(ImageName + "_NEW");
		x = 1;
// Open the cell ROI and erase signal outside of it (for and if)
		for (j=0; j<list3_1.length; j++) {
			TestDish = indexOf(list3_1[j], ImageDishNumber) != -1;
			if (TestDish) {
// Set values for the while loop
				KeepSegmentation = "false";
				FirstTime = "true";
				run("Duplicate...", "title=" + ImageName);
				roiManager("open", dir3_1 + list3_1[j]);
				roiManager("select", 0);
				run("Clear Outside");
				roiManager("Delete");
				run("Select None");
				while (KeepSegmentation != "Yes") {
					if (FirstTime == "true" || KeepSegmentation == "Back to Maxima") {
					FirstTime = "true";
// Loop to get the right maxima segmentation
						NoNextMaxima = "";
						for (k=0; k<MaximaNumber; k++) {
							selectWindow(ImageName);
							if (NoNextMaxima == "Custom") {
								MaximaNoise = CustomMaxima;
							}
							else {
								MaximaNoise = 250*((k*k)+k+1);
							}
							MaximaMapName = "" + k + "_" + MaximaNoise + "_MaximaMap_Noise";
							run("Duplicate...", "title=" + MaximaMapName);
							run("Enhance Contrast", "saturated=0.1");
							run("Find Maxima...", "noise=" + MaximaNoise + " output=[Point Selection]");
// Open a dialog to ask if we keep this segmentation or not
							setLocation(40, 50);
							waitForUser("Maxima", "Check the Maxima then press ok");
							Dialog.create("Maxima map");
							Dialog.addMessage("Maxima map " + (k+1) + "/" + (MaximaNumber+1) + " with noise set to " + MaximaNoise);
							Dialog.addRadioButtonGroup("Keep this maxima map?",newArray("Yes", "No", "Previous", "Restart", "Custom"),5,1,"No");
							Dialog.show();
							NoNextMaxima = Dialog.getRadioButton();
// Look if we keep this segmentation or if we go to the previous one
							if (NoNextMaxima == "Yes") {
								break;
							}
							else if (NoNextMaxima == "Previous") {
								k = k-2;
							}
							else if (NoNextMaxima == "Restart") {
								k = 0;
							}
							else if (NoNextMaxima == "Custom") {
								Dialog.create("Custom - Maxima map");
								Dialog.addNumber("Custom Maxima",0);
								Dialog.show();
								CustomMaxima = Dialog.getNumber();
								k = k-2;
							}
							close(MaximaMapName);
						}
						run("Find Maxima...", "noise=" + MaximaNoise + " output=[Segmented Particles]");
						close(MaximaMapName);
						rename(MaximaMapName);
					}
					
					
					if (FirstTime == "true" || KeepSegmentation == "Back to Threshold") {
						FirstTime = "true";
// Prepare threshold for the image, manual threshold
						selectWindow(ImageName);
						setLocation(40, 50);
						run("Threshold...");
						setAutoThreshold("Default dark");
						waitForUser("Threshold", "Set the threshold then press ok");
						run("Create Mask");
						Mask1 = "Mask1";
						Mask2 = "Mask2";
						rename(Mask1);
					}
					
					
					if (FirstTime == "true" || KeepSegmentation == "Back to Threshold" || KeepSegmentation == "Back to Binary") {
						FirstTime = "true";
// Do an open on the mask and ask if it's ok
						OpenTest = "No";
						while (OpenTest == "No") {
							selectWindow(Mask1);
							run("Duplicate...", "title=" + Mask2);
							selectWindow(Mask2);
							setLocation(40, 50);
							Dialog.create("Binary open - settings");
							Dialog.addMessage("Set parameters for binary open");
							Dialog.addNumber("iterations:", 1);
							Dialog.addNumber("count:", 7);
							Dialog.show();
							BinaryIterations = Dialog.getNumber();
							BinaryCount = Dialog.getNumber();
							run("Options...", "iterations=" + BinaryIterations + " count=" + BinaryCount + " edm=Overwrite do=Open");
							Dialog.create("Binary open");
							Dialog.addRadioButtonGroup("Keep this mask?",newArray("Yes", "No"),1,2,"Yes");
							Dialog.show();
							OpenTest = Dialog.getRadioButton();
							if (OpenTest == "No") {
								close(Mask2);
							}
						}
					}
					
					
// Use both MaximaMap and BinaryMask to create segmentation
					imageCalculator("AND create", MaximaMapName, Mask2);
					BinaryImageName = "Binary segmentation";
					rename(BinaryImageName);
					run("Create Selection");
					roiManager("Add");
					roiManager("Select", 0);
					roiManager("Split");
					roiManager("Select", 0);
					roiManager("Delete");
					//RoiCount = roiManager("count");
					//roiManager("Select", RoiCount-1);
					//roiManager("Delete");
					roiManager("Show All without labels");
					
					
// Ask if the segmentation is good or not
					selectWindow(ImageName + "_NEW");
					setLocation(40, 50);
					roiManager("Show All without labels");
					waitForUser("Segmentation", "Check the segmentation then press ok");
					FirstTime = "false";
					Dialog.create("Segmentation");
					Dialog.addRadioButtonGroup("Keep this segmentation?",newArray("Yes", "Back to Maxima", "Back to Threshold", "Back to Binary", "Skip cell"),5,1,"Yes");
					Dialog.show();
					KeepSegmentation = Dialog.getRadioButton();
					if (KeepSegmentation != "Yes" && KeepSegmentation != "Skip cell") {
						close(BinaryImageName);
						roiManager("deselect");
						roiManager("delete");
					}
					if (KeepSegmentation == "Back to Maxima") {
						close(MaximaMapName);
						close(Mask1);
						close(Mask2);
					} else if (KeepSegmentation == "Back to Threshold") {
						close(Mask1);
						close(Mask2);
					} else if (KeepSegmentation == "Back to Binary") {
						close(Mask2);
					} else if (KeepSegmentation == "Skip cell") {
						break;
					}
				}
// Save the segmentation and close the images
				if (KeepSegmentation == "Yes") {
					SaveName = replace(ImageName, Extension, "");
					SaveName = replace(SaveName, "_TIRF", "");
					roiManager("deselect");
					roiManager("save", dir3_2 + SaveName + "_cell" + x + "_MCS.zip");
				}
				roiManager("deselect");
				roiManager("delete");
				selectWindow(ImageName + "_NEW");
				close("\\Others");
				close("Results");
				x = x + 1 ;
			}
		}
	}
	close("*");
}
print("job done");


// Function to remove BG from ROI
// Ask for the path of the ROI and the image name that need to get BG removed
function BgFromRoi(dir3_3, ImageName, BgRoiName) {
	roiManager("open", dir3_3 + BgRoiName);
	selectWindow(ImageName);
	roiManager("measure");
	roiManager("delete");
	BgValue = getResult("Mean");
	selectWindow(ImageName);
	run("Select None");
	run("Subtract...", "value=" + BgValue);
}


// Function to remove BG from RoiCount
// Variation that ask for user to create the ROI
// Ask for the image name that need to get BG removed
function BgFromRoi_Int(dir3_3, Extension, ImageName) {
// Ask user to draw and create the ROI
	setTool("rectangle");
	run("Enhance Contrast", "saturated=0.1");
	CreatedRoi = "false";
	while (CreatedRoi == "false") {
		waitForUser("Select BG", "Create a selection and press on T to create a ROI to remove the BG");
		if (roiManager("count") != 0) {
			CreatedRoi = "true";
		}
	}
	selectWindow(ImageName);
	roiManager("measure");
	
	SaveNameBG = replace(ImageName, Extension, "");
	SaveNameBG = replace(SaveNameBG, "_TIRF", "");
	roiManager("save", dir3_3 + SaveNameBG + "_BG.zip");
	
	roiManager("delete");
	BgValue = getResult("Mean");
	selectWindow(ImageName);
	run("Select None");
	run("Subtract...", "value=" + BgValue);
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Add the previous maxima value if you redo the maxima
// Maxima restart doesn't work (from 250 it went to the next one, 750)
// set param for binary, if cancel it stops the macro / same for keep the mask just after
