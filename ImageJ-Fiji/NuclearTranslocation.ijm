//
//	ImageJ/Fiji script
//	
//	Macro to analyse the translocation of NFAT from cytosol to the nucleus
//	It should work for any other fluorescent molecule that you want to check the nucleus translocation
//	Need a DAPI image stored into a "1_DAPI" folder to identify each cell and its nucleus
//	Need a NFAT image stored into a "2_NFAT" folder to get the NFAT signal and see if it's inside the nucleus or not
//	You end up with txt files containing the integrated pixel values withing each cells for series "A" and "B"
//	"A" correspond to the cytosol + nucleus signal
//	"B" correspond to the nucleus signal only
//	ImageJ/Fiji gives you two numbers, first is "IntDen" and the second is "RawIntDen"
//	Refer to ImageJ/Fiji documentation for further information
//	
//	Works nicely for 40x images, 10x is too small and many cells are not properly separated
//	
//	ALGORITHM STEPS:
//		First, convert the image to 8 bit format
//	1) Duplicate Originale image (DAPI duplicated as IBW)
//	2) Apply gaussian filter on IBW with GaussSigma px (Sigma Gaussian Filter 1)
//	3) Remove gaussian treated image (IBW) from Original image and rename it as CleanDAPI
//	4) Threshold on CleanDAPI and create Mask1 (does not overwrite CleanDAPI)
//	5) Apply binary operation "close" on Mask1 with Iterations=5 and Count=5, rename as "Mask1Modif"
//	6) Duplicate CleanDAPI and apply median filter size MedFilterRadius, rename as "CleanDAPIMedFilter"
//	7) Find maxima on CleanDAPI or CleanDAPIMedFilter depending AlternativeMaximaAuto setting and create segmented particle image called "MAXIMA"
//	8) Image calculator, "Mask1Modif" AND "MAXIMA", rename it as "Seg1"
//	9) Apply gaussian filter with GaussianBlur px (Sigma Gaussian Filter 2) on "CleanDAPI" and rename it as "CleanDAPIGaussFilter"
//	10) Set Threshold 5 to 255 on CleanDAPIGaussFilter, rename as "Mask2", do an image calculator, "MAXIMA" AND "Mask2", rename as "Seg2"
//	11) Open corresponding NFAT image and rename it as "NFATImage"
//	12) Median filter radius 10 on "NFATImage" and threshold from 5 to 255 and create a mask, rename it "MASK PRE FINAL 1",
//		image calculator, "MASK PRE FINAL 1" OR "Seg2", rename it "MASK PRE FINAL 2"
//	13) Create final mask with image calculator, "MASK PRE FINAL 2" AND "MAXIMA", rename as "MASK FINAL"
//	14) Create ROIs (Region Of Interests) on selection from "MASK FINAL" using Analyze Particle size=500-infinity pixels, save them as "A" series
//	15) For each ROI, duplicate "Seg1" as "Seg1Bis" and clear outside of the ROI
//	16) Create a new ROI from "Seg1Bis" using same Analyze Particle settings, keeps only if 1 ROI is found, else it deletes the ROI from "A" series
//	17) Erase the "A" series of ROIs and save the second one as the "B" series
//	18) Extract NFAT signal from the "A" series
//	19) Extract NFAT signal from the "B" series
//	
//	Christopher Henry - V1 - 2020-11-06
//


//	Create a dialog to ask for the different settings to adjust
labels = newArray("Ask Sigma Gaussian Filter 1", "Ask Radius Median Filter", "Ask Sigma Gaussian Filter 2",
	"Check Threshold", "Alternative Maxima Map", "Automatic Alternative Maxima Map");
defaults = newArray(false, false, false, false, true, true);
Dialog.create("Settings");
Dialog.addCheckboxGroup(6, 1, labels, defaults);
Dialog.addNumber("Sigma for Gaussian Filter 1", 75);
Dialog.addNumber("Radius for Median Filter", 15);
Dialog.addNumber("Sigma for Gaussian Filter 2", 10);
Dialog.show();
//	Retrieve the settings from the dialog
GaussSigmaYesNo = Dialog.getCheckbox();
MedFilterRadiusYesNo = Dialog.getCheckbox();
GaussianBlurYesNo = Dialog.getCheckbox();
CheckThresholdYesNo = Dialog.getCheckbox();
AlternativeMaxima= Dialog.getCheckbox();
AlternativeMaximaAuto= Dialog.getCheckbox();
GaussSigma = Dialog.getNumber();		// Pixel size of the gaussian filter used in 2)
MedFilterRadius = Dialog.getNumber();	// Array size of the median filter used in 6)
GaussianBlur = Dialog.getNumber();		// Pixel size of the gaussian blur used in 9)

// Define the paths and gets files in it, also check if folders are missing
dir1 = getDirectory("Choose Main Directory");
dir2 = dir1 + "1_DAPI\\";
if (File.exists(dir2)!=1) {
	exit("ERROR, no \"1_DAPI\" folder, create a Folder containing the DAPI images");
}
list2 = getFileList(dir2);
dir3 = dir1 + "2_NFAT\\";
if (File.exists(dir3)!=1) {
	exit("ERROR, no \"2_NFAT\" folder, create a Folder containing the DAPI images");
}
list3 = getFileList(dir3);
dir4 = dir1 + "3_ROIs\\";
if (File.exists(dir4)!=1) {
	File.makeDirectory(dir4);
}
dir5 = dir1 + "4_Analysis\\";
if (File.exists(dir5)!=1) {
	File.makeDirectory(dir5);
}

// Set the measurements settings
run("Set Measurements...", "integrated redirect=None decimal=2");
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_column save_row");

//	Close everything before starting
close("Log");
close("Results");
if (nImages()>0) {
	close("*");
}
if (roiManager("count")>0) {
	roiManager("deselect");
	roiManager("delete");
}

for (i=0; i<list2.length; i++) {
	if (endsWith(list2[i],"tif")>=1) {
		//	Open tif files in the DAPI folder and convert it in 8 bit image
		A = dir2+list2[i];
		open(A);
		run("8-bit");
		//	Extract the DAPI file name to open the corresponding NFAT file
		FileName = getTitle();
		FileDishNumber = substring(FileName, 0, lengthOf(FileName));

//	1) Duplicate Originale image (DAPI duplicated as IBW)
		run("Duplicate...", "title=IBW");
		
//	2) Apply gaussian filter on IBW with GaussSigma px (Sigma Gaussian Filter 1)
		if (GaussSigmaYesNo==true) {
			NoNextMaxima = "No";
			while (NoNextMaxima=="No") {
				run("Gaussian Blur...", "sigma=" + GaussSigma);
				run("Enhance Contrast", "saturated=0.1");
				setLocation(40, 50);
				waitForUser("Gaussian", "Check the Gaussian then press ok");
				Dialog.create("Gaussian");
				Dialog.addMessage("Gaussian using a sigma of " + GaussSigma);
				Dialog.addRadioButtonGroup("Keep this gaussian sigma?",newArray("Yes", "No"),2,1,"No");
				Dialog.show();
				NoNextMaxima = Dialog.getRadioButton();
				if (NoNextMaxima == "Yes") {
					break;
				}
				else if (NoNextMaxima == "No") {
					Dialog.create("Custom - Gaussian sigma");
					Dialog.addNumber("Custom sigma",50);
					Dialog.show();
					GaussSigma = Dialog.getNumber();
					close("IBW");
					run("Duplicate...", "title=IBW");
				}
			}
		}
		else if (GaussSigmaYesNo==false) {
			run("Gaussian Blur...", "sigma=" + GaussSigma);
		}
//	3) Remove gaussian treated image (IBW) from Original image and rename it as CleanDAPI
		imageCalculator("Subtract", FileName,"IBW");
		rename("CleanDAPI");		
		
//	4) Threshold on CleanDAPI and create Mask1 (does not overwrite CleanDAPI)
		setThreshold(5, 255);
		setOption("BlackBackground", false);
		run("Create Mask");
		rename("Mask1");
		
//	5) Apply binary operation "close" on Mask1 with Iterations=5 and Count=5, rename as "Mask1Modif"
		run("Options...", "iterations=5 count=5 do=Close");
		rename("Mask1Modif");
		
//	6) Duplicate CleanDAPI and apply median filter size MedFilterRadius, rename as "CleanDAPIMedFilter"
		if (AlternativeMaxima==false) {
			selectWindow("CleanDAPI");
			run("Duplicate...", "title=CleanDAPIMedFilter");
			if (MedFilterRadiusYesNo==true) {
				NoNextMaxima = "No";
				while (NoNextMaxima=="No") {
					run("Median...", "radius=" + MedFilterRadius);
					run("Enhance Contrast", "saturated=0.1");
					setLocation(40, 50);
					waitForUser("MedFilter", "Check the MedFilter then press ok");
					Dialog.create("MedFilter");
					Dialog.addMessage("MedFilter using a radius of " + MedFilterRadius);
					Dialog.addRadioButtonGroup("Keep this MedFilter radius?",newArray("Yes", "No"),2,1,"No");
					Dialog.show();
					NoNextMaxima = Dialog.getRadioButton();
					if (NoNextMaxima == "Yes") {
						break;
					}
					else if (NoNextMaxima == "No") {
						Dialog.create("Custom - MedFilter radius");
						Dialog.addNumber("Custom radius",5);
						Dialog.show();
						MedFilterRadius = Dialog.getNumber();
						close("CleanDAPIMedFilter");
						selectWindow("CleanDAPI");
						run("Duplicate...", "title=CleanDAPIMedFilter");
					}
				}
			}
			else if (MedFilterRadiusYesNo==false) {
				run("Median...", "radius=" + MedFilterRadius);
			}
		}
		
//	7) Find maxima on CleanDAPI or CleanDAPIMedFilter depending AlternativeMaximaAuto setting and create segmented particle image called "MAXIMA"
		if (AlternativeMaximaAuto==true) {
			selectWindow("CleanDAPI");
			run("Duplicate...", "title=CleanDAPI-2");
			run("Gaussian Blur...", "sigma=25");
			run("Duplicate...", "title=CleanDAPI-3");
			run("Gaussian Blur...", "sigma=15");
			imageCalculator("Subtract", "CleanDAPI-2","CleanDAPI-3");
			rename("CleanDAPIAlternative");
			MaximaNoise = 1;
		}
		else if (AlternativeMaximaAuto==false) {
			Dialog.create("Custom - Maxima map");
			Dialog.addNumber("Custom Maxima",0);
			Dialog.show();
			CustomMaxima = Dialog.getNumber();
			NoNextMaxima = "No";
			while (NoNextMaxima=="No") {
				if (AlternativeMaxima==false) {
					selectWindow("CleanDAPIMedFilter");
				}
				else if (AlternativeMaxima==true) {
				//	Alternative cleaning for MAXIMA using blur followed by second blur and remove the second one from the first one
					selectWindow("CleanDAPI");
					run("Duplicate...", "title=CleanDAPI-2");
					run("Gaussian Blur...", "sigma=25");
					run("Duplicate...", "title=CleanDAPI-3");
					run("Gaussian Blur...", "sigma=15");
					imageCalculator("Subtract", "CleanDAPI-2","CleanDAPI-3");
					rename("CleanDAPIAlternative");
				}
				MaximaNoise = CustomMaxima;
				MaximaMapName = MaximaNoise + "_MaximaMap_Noise";
				run("Duplicate...", "title=" + MaximaMapName);
				run("Enhance Contrast", "saturated=0.1");
				run("Find Maxima...", "noise=" + MaximaNoise + " output=[Point Selection]");
				//	Open a dialog to ask if we keep this segmentation or not
				setLocation(40, 50);
			//	waitForUser("Maxima", "Check the Maxima then press ok");
				Dialog.create("Maxima map");
				Dialog.addMessage("Maxima map with noise set to " + MaximaNoise);
				Dialog.addRadioButtonGroup("Keep this maxima map?",newArray("Yes", "No"),2,1,"No");
				Dialog.show();
				NoNextMaxima = Dialog.getRadioButton();
				//	Look if we keep this segmentation or if we go to the previous one
				if (NoNextMaxima == "Yes") {
					break;
				}
				else if (NoNextMaxima == "No") {
					Dialog.create("Custom - Maxima map");
					Dialog.addNumber("Custom Maxima",0);
					Dialog.show();
					CustomMaxima = Dialog.getNumber();
				}
				close(MaximaMapName);
			}
		}
		run("Find Maxima...", "prominence=" + MaximaNoise + " output=[Segmented Particles]");
		rename("MAXIMA");
		
//	8) Image calculator, "Mask1Modif" AND "MAXIMA", rename it as "Seg1"
		imageCalculator("AND create", "Mask1Modif","MAXIMA");
		rename("Seg1");
		
//	9) Apply gaussian filter with GaussianBlur px (Sigma Gaussian Filter 2) on "CleanDAPI" and rename it as "CleanDAPIGaussFilter"
		selectWindow("CleanDAPI");
		run("Duplicate...", "title=CleanDAPIGaussFilter");
		if (GaussianBlurYesNo==true) {
			NoNextMaxima = "No";
			while (NoNextMaxima=="No") {
				run("Gaussian Blur...", "sigma=" + GaussianBlur);
				run("Enhance Contrast", "saturated=0.1");
				setLocation(40, 50);
				waitForUser("Gaussian", "Check the Gaussian then press ok");
				Dialog.create("Gaussian");
				Dialog.addMessage("Gaussian using a sigma of " + GaussianBlur);
				Dialog.addRadioButtonGroup("Keep this gaussian sigma?",newArray("Yes", "No"),2,1,"No");
				Dialog.show();
				NoNextMaxima = Dialog.getRadioButton();
				if (NoNextMaxima == "Yes") {
					break;
				}
				else if (NoNextMaxima == "No") {
					Dialog.create("Custom - Gaussian sigma");
					Dialog.addNumber("Custom sigma",10);
					Dialog.show();
					GaussianBlur = Dialog.getNumber();
					close("CleanDAPIGaussFilter");
					selectWindow("CleanDAPI");
					run("Duplicate...", "title=CleanDAPIGaussFilter");
				}
			}
		}
		else if (GaussianBlurYesNo==false) {
			run("Gaussian Blur...", "sigma=" + GaussianBlur);
		}

//	10) Set Threshold 5 to 255 on CleanDAPIGaussFilter, rename as "Mask2", do an image calculator, "MAXIMA" AND "Mask2", rename as "Seg2"
		setThreshold(5, 255);
		setOption("BlackBackground", false);
		if (CheckThresholdYesNo==true) {
			waitForUser("Threshold", "Check the Threshold then press ok");
		}
		run("Create Mask");
		rename("Mask2");
		imageCalculator("AND", "Mask2","MAXIMA");
		rename("Seg2");
		
//	11) Open corresponding NFAT image and rename it as "NFATImage"
		for (j=0; j<list3.length; j++) {
			TestDish = indexOf(list3[j], FileDishNumber) != -1;
			if (TestDish) {
				B = dir3+list3[i];
				open(B);
				rename("NFATImage1");
				j = list3.length;
			}
		}
		if (nImages()<1) {
			break;
		}
		
//	12) Median filter radius 10 on "NFATImage" and threshold from 5 to 255 and create a mask, rename it "MASK PRE FINAL 1",
//		image calculator, "MASK PRE FINAL 1" OR "Seg2", rename it "MASK PRE FINAL 2"
		selectWindow("NFATImage1");
		run("Duplicate...", "title=NFATImage2");
		run("Median...", "radius=10");
		setThreshold(5, 255);
		setOption("BlackBackground", false);
		run("Create Mask");
		rename("MASK PRE FINAL 1");
		imageCalculator("OR", "MASK PRE FINAL 1","Seg2");
		rename("MASK PRE FINAL 2");
		
//	13) Create final mask with image calculator, "MASK PRE FINAL 2" AND "MAXIMA", rename as "MASK FINAL"
		imageCalculator("AND", "MASK PRE FINAL 2","MAXIMA");
		rename("MASK FINAL");
		
//	14) Create ROIs (Region Of Interests) on selection from "MASK FINAL" using Analyze Particle size=500-infinity pixels, save them as "A" series
		run("Analyze Particles...", "size=500-Infinity pixel exclude add");
		PathROIa = dir4 + replace(list2[i], ".tif", "_A.zip");		
		
//	15) For each ROI, duplicate "Seg1" as "Seg1Bis" and clear outside of the ROI
		NbROIs = roiManager("count");
		for (j=0; j<NbROIs; j++){
			NbROIsBefore = roiManager("count");
			selectWindow("Seg1");
			run("Duplicate...", "title=Seg1Bis");
			selectWindow("Seg1Bis");
			run("Invert");
			roiManager("select", j);
			run("Clear Outside");
			roiManager("deselect");
			run("Invert");
			
//	16) Create a new ROI from "Seg1Bis" using same Analyze Particle settings, keeps only if 1 ROI is found, else it deletes the ROI from "A" series
			run("Analyze Particles...", "size=500-Infinity pixel add");
			close("Seg1Bis");
			NbROIsAfter = roiManager("count");
			NbROIsTest = NbROIsAfter - NbROIsBefore;
			if (NbROIsTest != 1) {
				roiManager("select",j);
				roiManager("delete");
				NbROIs = NbROIs-1;
				j = j-1;
				if (NbROIsTest>1) {
					for (k=0; k<NbROIsTest; k++) {
						NbROIsToErase = roiManager("count");
						roiManager("select",NbROIsToErase-1);
						roiManager("delete");
					}
				}
			}
		}
		ROIsSetA = newArray(NbROIs);
		for (j=0; j<NbROIs; j++) {
			ROIsSetA[j] = j;
		}
		roiManager("select",ROIsSetA);
		roiManager("Save selected", PathROIa);
		roiManager("delete");

//	17) Erase the "A" series of ROIs and save the second one as the "B" series
		PathROIb = dir4 + replace(list2[i], ".tif", "_B.zip");
		roiManager("Save", PathROIb);
		roiManager("deselect");
		roiManager("delete");
		
//	18) Extract NFAT signal from the "A" series
		selectWindow("NFATImage1");
		roiManager("open", PathROIa);
		roiManager("multi-measure measure_all");
		PathAnalysis = dir5 + replace(list2[i], ".tif", "_A.txt");
		String.copyResults;
		TextFileOutput = File.open(PathAnalysis);
		print(TextFileOutput, String.paste);
		File.close(TextFileOutput);
		roiManager("deselect");
		roiManager("delete");
		
//	19) Extract NFAT signal from the "B" series
		roiManager("open", PathROIb);
		roiManager("multi-measure measure_all");
		PathAnalysis = dir5 + replace(list2[i], ".tif", "_B.txt");
		String.copyResults;
		TextFileOutput = File.open(PathAnalysis);
		print(TextFileOutput, String.paste);
		File.close(TextFileOutput);
		roiManager("deselect");
		roiManager("delete");
		if (nImages()>0) {
			close("*");
		}
	}
}
print("Job done");
selectWindow("Log");
