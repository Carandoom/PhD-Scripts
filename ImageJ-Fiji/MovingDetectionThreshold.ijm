//
//  ImageJ/Fiji
//
//  Script to detect movement of a signal above a threshold
//  between timepoints. Need a single color channel stack of
//  multiple timepoints.
//
//  Christopher Henry - V1 - 2021-03-01
//

// File extension
Extension = ".nd2";

// Get title and separate the stack into single images
ImageName = getTitle();
selectWindow(ImageName);
run("Stack to Images");
ImageName = replace(ImageName, Extension, "");

//
NbImages = nImages();
for (i=0; i<NbImages-2; i++) {
  // Get image name in the right order
  if (i+1<10) {
			ImageName1 = ImageName + "-000" + i+1;
		}
	else if (i+1>=10) {
			ImageName1 = ImageName + "-00" + i+1;
		}
  if (i+2<10) {
			ImageName1 = ImageName + "-000" + i+2;
		}
	else if (i+2>=10) {
			ImageName1 = ImageName + "-00" + i+2;
		}
  
  
  
}















