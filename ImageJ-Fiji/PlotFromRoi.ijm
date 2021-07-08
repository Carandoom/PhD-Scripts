// Script to plot signal from ROIs using 2 images containing an identification word

// Check if ROIs have been created 
if (roiManager("count")<2) {
	print("You need to create a least 2 ROIs");
  exit
}

// Get the 2 images
idImage1 = "340";
idImage2 = "380";
titleList = getList("image.titles");
if (titleList.length != 2) {
	print("You should have 2 images");
	exit
}
for (i=0; i<titleList.length; i++) {
	if (indexOf(titleList[i], idImage1)>0) {
		Image1 = titleList[i];
	}
	else if (indexOf(titleList[i], idImage2)>0) {
		Image2 = titleList[i];
	}
}

// Perform ratio image of the Image1 div by Image2
imageCalculator("Divide create 32-bit stack", Image1, Image2);
newName = "Ratio of " + idImage1 + " div " + idImage2;
rename(newName);

// Extract mean fluo from ROIs and plot it
run("Set Measurements...", "mean redirect=None decimal=2");
selectWindow(newName);
roiManager("Multi Measure");
Plot.create("Plot of Results", "x", "Mean1");
title = split(String.getResultsHeadings);
for (i=0; i<title.length; i++) {
	Plot.add("Circle", Table.getColumn("Mean"+i+1, "Results"));
	Plot.setStyle(i, "blue,#9999ff,1.0,Circle");
}
Plot.setLimitsToFit();
