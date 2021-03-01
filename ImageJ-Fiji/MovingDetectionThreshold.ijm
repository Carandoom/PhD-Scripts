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
run("Set Measurements...", "integrated redirect=None decimal=2");
Extension = ".nd2";

//	Get title and prepare threshold
ImageName = getTitle();
selectWindow(ImageName);
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
	roiManager("Select", 0);
	roiManager("Measure");
  	
	
	
}















