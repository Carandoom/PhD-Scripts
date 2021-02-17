//	
//	ImageJ/Fiji
//	
//	Tutorial to create scripts in ImageJ/Fiji
//	
//	Part 1
//	1.1: Synthax, comments and print function
//	1.2: Open file
//	1.3: Select folder and extract files
//	1.4: Loop for
//	1.5: Open files in a batch
//	1.6: Open files in a batch upon condition
//	

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//

//		Before starting
//	To write code in ImageJ/Fiji, you just need a text file that you
//	can drag into ImageJ/Fiji window and then Run the code from there.
//	I advice you to use the Record mode accessible from ImageJ/Fiji
//	when you want to do some automatisation of the same process you
//	usually do over and over, it will show you how to write the code
//	needed to do what you did manually.

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//

//		Part 1.1
//	First step, learn the synthax in ImageJ, a comment (not taken 
//	into account by the script) is marked with "//". Another way to
//	create a comment block is by starting a line with /* and end the
//	block of comments with */.
//	Here you can see a very simple function to write something into
//	a Log window, in this case it's "Hello World" that will appear
//	to the Log window.
//	As you can see, at the end of the statement, I wrote ";" which
//	is a very important symbol for ImageJ/Fiji. With this it will
//	know your this line is ended and it can go to the next one.
//	There is few exceptions with some statements like "for" or "if"
//	that will end with "{" instead of ";" as we will see later.

print("Hello World");

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//

//		Part 1.2
//	Here we will open a file from ImageJ/Fiji, the way to do it is
//	via a function available in ImageJ/Fiji. This function is called
//	"open()" and needs an argument which is here the path of the file
//	you want to open. Don't forget to put the extension of the file
//	at the end of its name if you write it manually. For this exercice
//	we will write the path of the file and its extention into the
//	function open. You can download the file "ImageJ_Fiji_File1.tif"

open("C:\\Users\\henryc\\Desktop\\ImageJ_Fiji_Tutorial\\Part1\\ImageJ_Fiji_File1.tif");

//	You can see something curious, instead of a single "\" there is a
//	double "\\". The reason is because the single one is used to insert
//	special characters such as ". Note also that here we don't have
//	spaces in the path name but it is possible to include them without
//	any problem (which is not always the case in other programming
//	languages). So here we opened a specific file in a given folder
//	but it is possible to use functions to choose the folder and
//	extract all the files withing it.

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//

//		Part 1.3
//	To select the folder containing the files we want to open, we can
//	use "getDirectory" function which is going to open a window asking
//	to select a folder. We can write the title we want the window
//	together have within parenthesis. We can then obtain the list of
//	files within this folder using the "getFileList" function which
//	extract all the files contained in a folder.

title = "Choose Directory Containing the Images";
dir1 = getDirectory(title);
list1 = getFileList(dir1);

//	It is important to understand that "list1" is a list. It means there
//	is more than one value that can be stored in it. We can access the
//	different values stored in the list using indexing. Let say your
//	list contain 2 values, to get the first one, you need to type
//	list[0]. As you can notice, the list index starts from 0 and not 1.
//	And to get the second value you would type list1[1].
//	We can now open the file of interest, if there is only the image
//	file in your folder, then you can access it using list1[0]. To
//	open the file, we need to use the "open" function and to give it
//	the path and the name of the file. To note, list1[0] will give the
//	file name and its extension.

open(dir1+list1[0]);

//	You can see for the "open" function, we used "+" which is a way to
//	combine variables. You can also use "++" to add a number to another
//	whereas "+" will bee to combine variables (strings in general).
//	A "string" is a type of variable, this is a chain of characters
//	and "integer" represents numbers. There is more variable type that
//	you will discover with the time.

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//

//		Part 1.4
//	Now, what if you want to open many files one after the other ? There
//	is different ways to do it, a common one is via loops. There is
//	different way to create loops and here we will see the "for" method.
//	The idea is to do something in a repetitive manner for a number of 
//	time or until a condition is reached. What we do here is to say we
//	want to create a variable called "i" that start with a value of zero.
//	And we want the loop to end when i = 5. At each loop, we increase the
//	value of "i" by one. It is indicated by "i++" which means we add 1
//	to i at the end of the loop. You can see that the loop is defined
//	after "for" by "{" ... "}". What is inside these signs are the 
//	commands that are going to be repeated at each loop. An advantage
//	is that you can use i as a variable that changes every loop and this
//	way you can do something different each loop.
//	In this example we just print a string "Test" associated to the
//	variable "i" changing every loop. We will obtain 5 lines of Test
//	values from "Test0" to "Test4".

for (i=0; i<5; i++) {
	print("Test"+i);
}

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//

//		Part 1.5
//	From what we have seen so far, we can now write a code that will
//	open files in a batch mode. To do so we need to use again this code.

title = "Choose Directory Containing the Images";
dir1 = getDirectory(title);
list1 = getFileList(dir1);

//	And now we need to add a loop to open all the files within this
//	folder. There is an interesting feature associated to the lists,
//	you can extract the lenght of it via a "method". To make it simple,
//	a method is like a function but associated to an object, here the list.
//	This method is called "list.length" and return the length of the list.
//	This length correspond to the number of files it contains. For each
//	file of the list, we will do the commands inside the loop "for". First,
//	we define "A" as variable containing the path and the file name. The
//	variable "A" will get updated at the beginning of each loop and will
//	contain the path + the name of the file to open. After, we use the
//	function "open()" associated with the variable "A". This way, the
//	files are going to be opened one by one, one after the other.

for (i=0; i<list1.length; i++) {
	A = dir1+list1[i];
	open(A);
}

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//

//		Part 1.6
//	Usually, in a folder you don't have only files you want to open to
//	work with them, it could be that some files are Excel or that you
//	also have subfolders. The approach we used will try to open each
//	element within the folder we selected. To avoid errors we can add
//	a condition to open only the files corresponding to the images we
//	are interested in.
//	The way to do it is via the "if" statement, you can use it to test
//	a condition and do a series of command only if the conditions is
//	meet (true) or something else if the condition is not meet (false).
//	Again, we start by choosing our folder and extract the file list.

title = "Choose Directory Containing the Images";
dir1 = getDirectory(title);
list1 = getFileList(dir1);

//	We create a for loop as we done previously but we will add a way
//	to detect the extension of the element stored into our list1.
//	We can use the function called "endsWith(string, suffix)", it takes
//	two arguments as inputs, "string" which is in what you look for 
//	and "suffix" which is what you are looking for in "string".
//	This way we can get list1[i] and see if we find ".tif" which
//	is the file extension we are looking for.
//	If the function endsWith find the "suffix" in "string", the result
//	of this function is "true" or 1. If it does not find it, it returns
//	"false" or 0. And now we have a condition that allows us to open
//	the file only if it ends with the extension we are interested in.

for (i=0; i<list1.length; i++) {
	if (endsWith(list1[i],".tif")>=1) {
		A = dir1+list1[i];
		open(A);
	}
}

//	If you want to test the opening of multiple files with this code
//	example, you can duplicate the "ImageJ_Fiji_File1.tif" file and
//	see if you manage to open all these files with the script we just
//	wrote.

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//
