//
//	ImageJ/Fiji
//
//	Script to detect movement of a signal above a threshold
//	between timepoints. Need a single color channel stack of
//	multiple timepoints.
//
//	Christopher Henry - V1 - 2021-03-01
//

//	Settings and file extension
close("Log");
close("Results");
if (nImages()>1) {
	print("ERROR, only one stack can be open, close the other images and start again");
	exit
}
if (roiManager("count")>0) {
	roiManager("deselect");
	roiManager("delete");
}
run("Set Measurements...", "integrated redirect=None decimal=2");
Extension = ".nd2";

//	Get title, gaussian blur and prepare threshold
ImageName = getTitle();
selectWindow(ImageName);
rename("Temp");

run("Gaussian Blur...", "sigma=2 stack");
run("Duplicate...", "title=BG duplicate");
run("Gaussian Blur...", "sigma=75 stack");
imageCalculator("Subtract create stack", "Temp", "BG");
rename(ImageName);

close("BG");
close("Temp");

run("Threshold...");
setAutoThreshold("Default dark");
waitForUser("Threshold", "Check the Threshold then press ok");
run("Convert to Mask", "method=Default background=Dark calculate black");
makeRectangle(0, 0, 512, 512);
roiManager("Add");

	
//	Separate the stack into single images
run("Stack to Images");
ImageName = replace(ImageName, Extension, "");

//	
NbImages = nImages();
for (i=0; i<NbImages-2; i++) {
  //	Get image name in the right order
	if (i+1<10) {
		ImageName1 = ImageName + "-000" + i+1;
	}
	else if (i+1>=10) {
		ImageName1 = ImageName + "-00" + i+1;
	}
  	if (i+2<10) {
		ImageName2 = ImageName + "-000" + i+2;
	}
	else if (i+2>=10) {
		ImageName2 = ImageName + "-00" + i+2;
	}
	
  	//	Do the difference of image i+1 and i+2
	imageCalculator("Difference create", ImageName1, ImageName2);
	rename("Stack-" + i+1);
	run("Subtract...", "value=254");
	roiManager("Select", 0);
	roiManager("Measure");	
}

close(ImageName+"*");
roiManager("Deselect");
roiManager("Delete");

run("Images to Stack", "name=" + ImageName + " title=Stack use");
run("Enhance Contrast", "saturated=0.35");










