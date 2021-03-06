/*
author: Annika Mütze <muetze.annika@gmail.com>
date: 09.2012

Litmus-Test
*/

#define ADRESSE_X 1
#define ADRESSE_Y 2
#define BUFF_SIZE 5 	//size of Buffer
#define MEM_SIZE 5		//size of memory 
#include "../sc-model.pml"


/*Channel der die reads und writes verschickt (Type (also write,read); Adresse; Wert;... )*/

short r1 = 0;
short r2 = 0;


proctype process1()
{
	write(ADRESSE_X, 1);
	write(ADRESSE_Y, 1);
	end: skip;
}


proctype process2()
{	
	read(ADRESSE_Y, r1);
	read(ADRESSE_X, r2);
	end: skip;	
}

init
{
	atomic{
	run process1();
	run process2();
	}
}
	// r1 == 1  (r2 == 0)	-> not allowed (x must have been written, wenn y = 1 gelesen wird
	// r1 == 1  (r2 == 1)	-> ok
	// r1 == 0  (r2 == 1)	-> ok
	// r1 == 0  (r2 == 0)	-> ok
	
ltl check_0{ [] (process1 @ end && process2 @ end -> ( ! (r1 == 1 && r2 == 0)))}

ltl check_1{ [] (process1 @ end && process2 @ end -> ( ! (r1 == 0 && r2 == 0)))}
ltl check_2{ [] (process1 @ end && process2 @ end -> ( ! (r1 == 1 && r2 == 1)))}
ltl check_3{ [] (process1 @ end && process2 @ end -> ( ! (r1 == 0 && r2 == 1)))}
