//	
//	ImageJ/Fiji Script
//	
//	Open all the series of images in a file with a specific extension
//	Save each series as one tif file
//	Ask to perform a Z-Projection and save it as .tif
//	The Z-Projection will add the name of the projection at the beginning of the file name.
//	
//	REQUIREMENTS: For ImageJ users, Bio-Formats Importer plugin is needed
//	
//	Christopher Henry - V1 - 2018-05-12
//	


// Ask for the file extension
/*
Dialog.create("Enter File Extension");
Dialog.addString("File Extension without \".\"", "");
Dialog.show();
Extension = "." + Dialog.getString();
*/
Extension = ".nd2";

// Ask for the z-projection to do
items = newArray("No Projection", "Average Intensity", "Max Intensity", "Max Intensity","Sum Slices","Standard Deviation","Median");
Dialog.create("Enter File Extension");
Dialog.addChoice("Select the Z-Projection to perform", items);
Dialog.show();
zProjection = Dialog.getChoice();

// Define path containing the files
dir1 = getDirectory("Choose Directory Containing the Images");
list1 = getFileList(dir1);

// Check if the folder to store new images exist, else create it
dir2 = dir1 + "Tif_Images\\";
if (File.exists(dir2)!=1) {
	File.makeDirectory(dir2);
}

for (j=0; j<list1.length; j++) {
	if (endsWith(list1[j], Extension)>=1) {
		A = dir1 + list1[j];
		run("Bio-Formats Importer", "open=[" + A + "] open_all_series");
		n = nImages;
		for (i=0; i<n; i++) {
			nameImage = getInfo("image.filename");
			if (n == 1) {
				saveAs("tiff",dir2 + replace(nameImage,Extension,""));
			}
			else if (n != 1) {
			nameImageTIF = nameImage + "-Field" + n-i;
			saveAs("tiff",dir2 + nameImageTIF);
			}
			
			if (zProjection != "No Projection") {
				run("Z Project...", "projection=[" + zProjection + "] all");
				
				nameImageZprojection = replace(zProjection, " ", "_") + "_" + nameImage;
				saveAs("tiff",dir2 + nameImageZprojection);
				close();
			}
			close();
		}
	}
}
print("Job done");
