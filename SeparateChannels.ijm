//
//	ImageJ/Fiji script
//
//	Open images with a specific extension, separate the channels
//	And save them into a separated folder with a identification number
//
//	REQUIREMENTS: For ImageJ users, Bio-Formats Importer plugin is needed
//
//	Christopher Henry - V1 - 2020-06-04
//


// Ask for the file extension
Dialog.create("Enter File Extension");
Dialog.addString("File Extension without \".\"", "");
Dialog.show();
Extension = Dialog.getString(); //".czi";

// Define path containing the files
dir1 = getDirectory("Choose Directory Containing the Images");

// Check if the folder to store new images exist, else create it
dir2 = dir1 + "Separated_Images\\";
if (File.exists(dir2)!=1) {
	File.makeDirectory(dir2);
}

// Get files in dir1
list1 = getFileList(dir1);


for (i=0; i<list1.length; i++) {
	if (endsWith(list1[i],Extension)>=1) {
		
		// Open files via Bio-Formats Importer and gets the image name
		A = dir1+list1[i];
		run("Bio-Formats Importer", "open=[" + A +"]");
		Path_Image = getDirectory("image");
		Title_Image1 = getTitle();
		
		// Module to replace spaces in the file name by underscores
		/*
		if (indexOf(Title_Image1," ")>0) {
			Title_Image1 = replace(Title_Image1," ","_");
			rename(Title_Image1);
		}
		*/
		
		// Split the channels and save them in the new folder
		run("Split Channels");
		NbImages = nImages();
		for (j=1; j<NbImages+1; j++) {
			Title_Image2 = Title_Image1;
			Title_Image2_1 = replace(Title_Image2, Extension, "_" + j);
			
			selectWindow("C" + j + "-" + Title_Image1);
			saveAs("tiff", dir2 + Title_Image2_1);
		}
		
		close("*");
	}
}

print("Job done");
