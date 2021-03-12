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
titleLog = "Data Results";
if (isOpen(titleLog)) {
	close(titleLog);
}
Width = getWidth();
Height = getHeight();
run("Table...", "name=["+titleLog+"] width=350 height=500");
setLocation(750, 460);
titleLog = "["+ titleLog +"]";
print(titleLog, "\\Headings:Cell\tSlice\tDensity\tArea\tNbDots");
roiManager("deselect");
selectWindow("ROI Manager");
setLocation(1250, 575);
run("Brightness/Contrast...");
selectWindow("B&C");
setLocation(1275, 175);
run("Set Measurements...", "area integrated redirect=None decimal=2");

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

//	Relocate the windows
selectWindow("C3-" + ImageName);
setLocation(75, 200);
selectWindow("C2-" + ImageName);
setLocation(75, 200);

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
	setLocation(75, 200);
// Open a dialog to ask if we keep this segmentation or not
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
	setSlice(i+1);
	run("Find Maxima...", "prominence=" + CustomMaxima + " output=[Segmented Particles]");
	rename("Stack-" + y);
	y = y + 1;
}
run("Images to Stack", "name=MaximaMap title=Stack use");
setLocation(75, 200);

//	Set threshold on the red stack
selectWindow("C2-" + ImageName);
setLocation(75, 200);
run("Threshold...");
selectWindow("Threshold");
setLocation(750, 175);
setAutoThreshold("Default dark");
waitForUser("Threshold", "Check the Threshold then press ok");
run("Convert to Mask", "method=Default background=Dark black");
run("Options...", "iterations=1 count=5 black do=Open stack");
setLocation(75, 200);

//	Loop for each cell
title1 = "tempGreen";
title2 = "tempRed";
ContinueLoop = true;
x = 1;
while (ContinueLoop) {
//	create ROI around the cell using the green channel
	selectWindow("C3-" + ImageName);
	run("Duplicate...", "title=" + title1 + " duplicate");
	selectWindow(title1);
	setLocation(75, 200);
	resetMinAndMax();
	waitForUser("ROI", "Create a ROI around the cell then press ok");
	if (roiManager("count")!=1) {
		print("ERROR, you need to create one ROI and then press OK");
		close(title1);
		continue
	}
	selectWindow(title1);
	roiManager("Select", 0);
	run("Clear Outside", "stack");
	roiManager("Delete");
	run("Select None");
	
//	Median filter on the croped cell and get the threshold based on the green channel
	run("Median...", "radius=20 stack");
	run("Threshold...");
	setLocation(750, 175);
	getMinAndMax(min, max);
	setThreshold(100, max);
	waitForUser("Threshold", "Check the Threshold then press ok");
	run("Convert to Mask", "method=Default background=Dark black");
	run("Options...", "iterations=1 count=5 black do=[Fill Holes] stack");
	
//	get selection from green channel for each slice
	AreaGreen = newArray(NbSlices);
	AnySignal = newArray(NbSlices);
	makeRectangle(0, 0, Width, Height);
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("Multi Measure");
	headings = split(String.getResultsHeadings);
	for (i=0; i<NbSlices; i++) {
		AnySignal[i] = getResult(headings[2], i);
	}
	run("Clear Results");
	roiManager("Select", 0);
	roiManager("Delete");
	run("Select None");
	y = 0;
	for (i=0; i<NbSlices; i++) {
		if (AnySignal[i]<1) {
			AreaGreen[i] = 0;
			continue
		}
		setSlice(i+1);
		run("Create Selection");
		roiManager("add");
		roiManager("select", y);
		roiManager("measure");
		headings = split(String.getResultsHeadings);
		AreaGreen[i] = getResult(headings[0], y);
		y = y + 1;
	}
	
//	remove outside green threshold in red channel
	selectWindow("C2-" + ImageName);
	run("Duplicate...", "title=" + title2 + " duplicate");
	y = 0;
	for (i=0; i<NbSlices; i++) {
		setSlice(i+1);
		if (AreaGreen[i]<1) {
			makeRectangle(0, 0, Width, Height);
			setBackgroundColor(0, 0, 0);
			run("Clear", "slice");
			run("Select None");
			continue
		}
		roiManager("Select", y);
		run("Clear Outside", "slice");
		y = y + 1;
	}
	roiManager("Deselect");
	roiManager("Delete");
	
//	Use maxima map and threshold on the red channel
	imageCalculator("AND create stack", title2, "MaximaMap");
	rename("ThrMaxRed");
	setLocation(75, 200);
	
//	for each slice, create ROI from selection
	NbSlicesToSplit = NbSlices;
	NbDots = newArray(NbSlices);
	AnySignal = newArray(NbSlices);
	selectWindow("ThrMaxRed");
	makeRectangle(0, 0, Width, Height);
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("Multi Measure");
	headings = split(String.getResultsHeadings);
	for (i=0; i<NbSlices; i++) {
		AnySignal[i] = getResult(headings[2], i);
	}
	run("Clear Results");
	roiManager("Select", 0);
	roiManager("Delete");
	run("Clear Results");
	for (i=0; i<NbSlices; i++) {
		setSlice(i+1);
		if (AnySignal[i]<1) {
			NbSlicesToSplit = NbSlicesToSplit - 1;
			NbDots[i] = 0;
			continue
		}
		run("Create Selection");
		roiManager("Add");
	}
		
// for each slice with signal, split the ROI
	CumulativeCount = 0;
	for (i=0; i<NbSlices; i++) {
		if (NbDots[i]==0) {
			continue
		}
		if (AreaGreen[i]<1) {
			continue
		}
		roiManager("Select", 0);
		if (matches(Roi.getType, "composite")==1) {
			roiManager("Split");
		}
		NbDots[i] = roiManager("count") - CumulativeCount - NbSlicesToSplit;
		CumulativeCount = CumulativeCount + NbDots[i];
		roiManager("Select", 0);
		if (matches(Roi.getType, "composite")==1) {
			roiManager("Select", 0);
			roiManager("Delete");
			NbSlicesToSplit = NbSlicesToSplit - 1;
		}
	}

//	save ROIs
	if (roiManager("count")==0) {
		continue
	}
	SaveName = replace(ImageName, Extension, "");
	roiManager("deselect");
	roiManager("save", dir1 + SaveName + "_cell" + x + ".zip");
	roiManager("Delete");
	close(title1);
	close(title2);
	for (i=0; i<NbSlices; i++) {
		print(titleLog, x + "\t" + i+1 + "\t" + NbDots[i]/AreaGreen[i] + "\t" + AreaGreen[i] + "\t" + NbDots[i]);
	}
	x = x +1;
	ContinueLoop = getBoolean("Select another cell ?");
}
if (isOpen("Results")) {
	close("Results");
}
if (isOpen("B&C")) {
	close("B&C");
}
if (isOpen("ROI Manager")) {
	close("ROI Manager");
}
if (isOpen("Threshold")) {
	close("Threshold");
}
close("*");
