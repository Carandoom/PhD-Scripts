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
//close("C3-" + ImageName);

//	BG sub from fiji menu
selectWindow("C2-" + ImageName);
run("Subtract Background...", "rolling=5 stack");
resetMinAndMax();

//	Z projection: Max projection
run("Z Project...", "projection=[Max Intensity]");
rename("Main");

//	find maxima
// Loop to get the right maxima segmentation
NoNextMaxima = "";
CustomMaxima = 1000;
while (NoNextMaxima!="Yes") {
	selectWindow("Main");
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
run("Find Maxima...", "prominence=" + CustomMaxima + " output=[Segmented Particles]");
rename("Segmented_Image");

//	Set threshold
selectWindow("Main");
setLocation(40, 50);
run("Threshold...");
setAutoThreshold("Default dark");
waitForUser("Threshold", "Check the Threshold then press ok");
run("Convert to Mask", "method=Default background=Dark calculate black");
rename("mask");

//	Separate the mask based on the maxima map
imageCalculator("AND create", "mask", "Segmented_Image");
rename("ResultOfMask");

title = "temp";
ContinueLoop = true;
x = 1;
while (ContinueLoop) {
	selectWindow("ResultOfMask");
	run("Duplicate...", "title="+title);
	selectWindow("C3-" + ImageName);
	setLocation(40, 50);
	waitForUser("ROI", "Create a ROI around the cell then press ok");
	if (roiManager("count")!=1) {
		print("ERROR, you need to create one ROI and then press OK");
		close(title);
		continue
	}
	selectWindow(title);
	roiManager("Show All without labels");
	roiManager("Select", 0);
	run("Clear Outside");
	roiManager("Delete");
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
	close(title);
	x = x +1;
	ContinueLoop = getBoolean("Select another cell ?");
}

close("*");


