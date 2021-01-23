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
