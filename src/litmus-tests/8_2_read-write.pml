/*
author: Annika Mütze <muetze.annika@gmail.com>
date: 09.2012

Litmus-Test: No reordering of writes 
when a read to the same location procedes*/

#define ADRESSE_X 1
#define ADRESSE_Y 2
#define BUFF_SIZE 5 	//size of Buffer
#define MEM_SIZE 5		//size of memory  

#define PROC_NUMBER 2
#include "../x86_tso_buffer_globalarray.pml"



/*Channel der die reads und writes verschickt (Type (also write,read); Adresse; Wert;... )*/
chan channelT1 = [0] of {mtype, short, short, short};
chan channelT2 = [0] of {mtype, short, short, short};
short r1 = 0;
short r2 = 0;

proctype process1(chan ch)
{
	read(ADRESSE_X, r1);
	write(ADRESSE_Y,1);
	done: skip;
}

proctype process2(chan ch)
{
	read(ADRESSE_Y, r2);
	write(ADRESSE_X,1);
	done: skip;
}

init
{
	atomic{
	run process1(channelT1);
	run bufferProcess(channelT1);
	run process2(channelT2);
	run bufferProcess(channelT2)
	}
}
	// r1 == 1  (r2 == 1)	-> not allowed r1=1 and r2=1*/
	// r1 == 1  (r2 == 0)	-> ok
	// r1 == 0  (r2 == 1)	-> ok
	// r1 == 0  (r2 == 0)	-> ok

ltl check_0 { [] (process1 @ done && process2 @ done ->( ! (r1 == 1 && r2 == 1)))};  

ltl check_1 { [] (process1 @ done && process2 @ done ->( ! (r1 == 0 && r2 == 0)))}; 
ltl check_2 { [] (process1 @ done && process2 @ done ->( ! (r1 == 1 && r2 == 0)))}; 
ltl check_3 { [] (process1 @ done && process2 @ done ->( ! (r1 == 0 && r2 == 1)))};
