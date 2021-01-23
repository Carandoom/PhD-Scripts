//	
//	ImageJ/Fiji
//	
//	Tutorial to create scripts in ImageJ/Fiji
//	Part 1
//	
//	1.1:
//	1.2:
//	1.3:
//	1.4:
//	1.5:
//	

//---------------------------------------------------------------------//

//		Before starting
//	To write code in ImageJ/Fiji, you just need a text file that you
//	can drag into ImageJ/Fiji window and then Run the code from there.
//	I advice you to use the Record mode accessible from ImageJ/Fiji
//	when you want to do some automatisation of the same process you
//	usually do over and over, it will show you how to write the code
//	needed to do what you did manually.

//---------------------------------------------------------------------//

//		Part 1.1
//	First step, learn the synthax in ImageJ, a comment (not taking 
//	into account by thescript) is marked with "//". Another way to
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

//		Part 1.2
//	Here we will open a file from ImageJ/Fiji, the way to do it is
//	via a function available in ImageJ/Fiji. This function is called
//	"open()" and needs an argument which is here the path of the file
//	you want to open. Don't forget to put the extension of the file
//	at the end of its name if you write it manually. For this exercice
//	we will write the path of the file and its extention into the
//	function open. You can download the file "ImageJ_Fiji_File1.stk"

open("C:\\Users\\henryc\\Desktop\\ImageJ_Fiji_Tutorial\\Part1\\ImageJ_Fiji_File1.stk");

//	You can see something curious, instead of a single "\" there is a
//	double "\\". The reason is because the single one is used to insert
//	special characters such as ". Note also that here we don't have
//	spaces in the path name but it is possible to include them without
//	any problem (which is not always the case in other programming
//	languages). So here we opened a specific file in a given folder
//	but it is possible to use functions to choose the folder and
//	extract all the files withing it.

//---------------------------------------------------------------------//



dir1 = getDirectory("Choose Directory Containing the Images");
list1 = getFileList(dir1);
open(dir1+file1[0]);
