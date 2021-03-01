//
//	ImageJ/Fiji
//
//	Script to detect movement of a signal above a threshold
//	between timepoints. Need a single color channel stack of
//	multiple timepoints.
//
//	Christopher Henry - V1 - 2021-03-01
//

//	File extension
Extension = ".nd2";

//	Get title and prepare threshold
ImageName = getTitle();
selectWindow(ImageName);
setAutoThreshold("Default dark");
waitForUser("Threshold", "Check the Threshold then press ok");
getThreshold(lower, upper);

	
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
  
	selectWindow();
  run("Create Mask");
	rename("Mask1");
	
  
}















