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


//		Before starting
//	To write code in ImageJ/Fiji, you just need a text file that you
//	can drag into ImageJ/Fiji window and then Run the code from there.
//	I advice you to use the Record mode accessible from ImageJ/Fiji
//	when you want to do some automatisation of the same process you
//	usually do over and over, it will show you how to write the code
//	needed to do what you did manually.


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
