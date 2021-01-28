//	
//	ImageJ/Fiji
//	
//	When a stack of 2 channels is open and 1 ROI is created,
//	it will crop the image based on the ROI and remove the outside signal
//	Then segmentate the second channel based on the desired threshold,
//	measure the mean intensity signal on the first channel and save
//	the results in a text file.
//	To note, it's not possible to duplicate your stack and run again the
//	script, it will not automatically detect the file path and won't save
//	the intensity signal.
//	
//	Christopher Henry - V1 - 2021-01-28
//	


//	Get File name and use one ROI created to crop out and remove signal outside of the ROI
FileName = getTitle();
dir1 = getDir("image");
Extension = substring(FileName,indexOf(FileName, "."));

roiManager("Select", 0);
run("Clear Outside", "stack");
run("Crop");
roiManager("deselect");
roiManager("delete");

//	Split channels and apply threshold
run("Split Channels");
selectWindow("C2-" + FileName);

//	Ask for background subtraction if desired
waitForUser("BG subtraction", "Apply background subtraction if needed then press ok");

selectWindow("C2-" + FileName);
run("Threshold...");
setAutoThreshold("Default dark");
waitForUser("Threshold", "Check the Threshold then press ok");
selectWindow("C2-" + FileName);
run("Convert to Mask", "method=Default background=Dark calculate black");

//	Get a ROI for every slice and measure the signal in the other channel
selectWindow("C2-" + FileName);
for (i = 1; i <= nSlices() ; i++) {
	selectWindow("C2-" + FileName);
	setSlice(i);
	run("Create Selection");
	roiManager("Add");
	selectWindow("C1-" + FileName);
	roiManager("Select", 0);
	roiManager("Measure");
	roiManager("Delete");
}

//	Save the results
String.copyResults;
TextFileOutput = File.open(dir1+replace(FileName,".nd2",".txt"));
print(TextFileOutput, String.paste);
File.close(TextFileOutput);
close("Results");
close("C1-" + FileName);
close("C2-" + FileName);
