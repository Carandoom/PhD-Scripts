//	
//	ImageJ/Fiji script
//	
//	Made to analyse DuoLink experiment:
//	3 channel image is open and the 2nd channel is kept
//	it is used to perform a z projection (max projection)
//	and then, we segmentate the image containing dots 
//	to finally count them
//	Cell restriction mask allow to work within a range
//	I need to add a scale for the find maxima
//	


//	Settings and file extension
close("Log");
close("Results");
if (roiManager("count")>0) {
	roiManager("deselect");
	roiManager("delete");
}

//	Split the channels and keep only red (duolink) and green (positive cells)
ImageName = getTitle();
dir1 = getDir("image");
Extension = ".czi";
run("Split Channels");
close("C1-" + ImageName);

//	BG sub from fiji menu
selectWindow("C2-" + ImageName);
NbSlices = nSlices();
run("Subtract Background...", "rolling=5 stack");
resetMinAndMax();

//	find maxima
// Loop to get the right maxima segmentation
waitForUser("Maxima", "Choose the slice for maxima preview then press ok");
NoNextMaxima = "";
CustomMaxima = 1000;
while (NoNextMaxima!="Yes") {
	selectWindow("C2-" + ImageName);
	MaximaMapName = "" + CustomMaxima + "_MaximaMap_Noise";
	run("Duplicate...", "title=" + MaximaMapName);
	run("Enhance Contrast", "saturated=0.1");
	run("Find Maxima...", "noise=" + CustomMaxima + " output=[Point Selection]");
// Open a dialog to ask if we keep this segmentation or not
	setLocation(40, 50);
	waitForUser("Maxima", "Check the Maxima then press ok");
	Dialog.create("Maxima map");
	Dialog.addMessage("Maxima map with noise set to " + CustomMaxima);
	Dialog.addRadioButtonGroup("Keep this maxima map?",newArray("Yes", "Custom"),2,1,"Custom");
	Dialog.show();
	NoNextMaxima = Dialog.getRadioButton();
// Look if we keep this segmentation or if we go to the previous one
	if (NoNextMaxima == "Yes") {
		close(MaximaMapName);
		break;
	}
	else if (NoNextMaxima == "Custom") {
		Dialog.create("Custom - Maxima map");
		Dialog.addNumber("Custom Maxima",0);
		Dialog.show();
		CustomMaxima = Dialog.getNumber();
		close(MaximaMapName);
	}
}

//	Get the maxima map for each slice
y = 1;
for (i=0; i<NbSlices; i++) {
	selectWindow("C2-" + ImageName);
	setSlice(i);
	run("Find Maxima...", "prominence=" + CustomMaxima + " output=[Segmented Particles]");
	rename("Stack-" + y);
	y = y + 1;
}
run("Images to stack", "name=MaximaMap title=Stack use");

//	Set threshold on the red stack
selectWindow("C2-" + ImageName);
setLocation(40, 50);
run("Threshold...");
setAutoThreshold("Default dark");
waitForUser("Threshold", "Check the Threshold then press ok");
run("Convert to Mask", "method=Default background=Dark black");















title1 = "tempGreen";
title2 = "tempRed";
ContinueLoop = true;
x = 1;
while (ContinueLoop) {
//	create ROI around the cell using the green channel
	selectWindow("C3-" + ImageName);
	run("Duplicate...", "title="+title1);
	setLocation(40, 50);
	waitForUser("ROI", "Create a ROI around the cell then press ok");
	if (roiManager("count")!=1) {
		print("ERROR, you need to create one ROI and then press OK");
		close(title1);
		continue
	}
	selectWindow(title1);
	roiManager("Select", 0);
	run("Clear Outside");
	roiManager("Delete");
	
//	Median filter on the croped cell and get the threshold based on the green channel
	run("Median...", "radius=20 stack");
	setAutoThreshold("Default dark");
	waitForUser("Threshold", "Check the Threshold then press ok");
	run("Convert to Mask", "method=Default background=Dark black");
	
//	get selection from green channel for each slice
	for (i=0, i<NbSlices; i++) {
		setSlice(i);
		run("create selection");
		roiManager("add");
	}
	
//	remove outside green threshold in red channel
	
	
	
	
	
//	Create the selection
	run("Create Selection");
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("Split");
	roiManager("Select", 0);
	roiManager("Delete");
	roiManager("Show All without labels");
	SaveName = replace(ImageName, Extension, "");
	roiManager("deselect");
	roiManager("save", dir1 + SaveName + "_cell" + x + ".zip");
	roiManager("Delete");
	close(title1);
	x = x +1;
	ContinueLoop = getBoolean("Select another cell ?");
}

close("*");












//	Separate the mask based on the maxima map
imageCalculator("AND create", "mask", "Segmented_Image");
rename("ResultOfMask");














