/*
* author: Annika Mütze <muetze.annika@gmail.com>
* date: 09.2012
*
* Litmus-Test: Shows that there is no reordering of reads
* with older writes to the same location.
*/

#define ADRESSE_X 1
#define BUFF_SIZE 5 	//size of Buffer
#define MEM_SIZE 5		//size of memory 
#include "../sc-model.pml"


short r1 = 0;

proctype process1(){
	write(ADRESSE_X, 1);
	read(ADRESSE_X, r1);
	/* not allowed to reorder with earlier write to same location*/ 
	//assert (r1 == 1);
	done: skip;
}

init{
	run process1();
}

//no reordering of reads with older write to same location
ltl check_0 { [] (process1 @ done -> !(r1 == 0 ))}; 
ltl check_1 { [] (process1 @ done -> !(r1 == 1 ))};
