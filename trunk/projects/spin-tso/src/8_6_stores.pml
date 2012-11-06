/*
author: Annika Mütze <muetze.annika@gmail.com>
date: 10.2012

Litmus-Test: Stores Are Transitively Visible
 */

#define ADRESSE_X 1
#define ADRESSE_Y 2
#define SIZE 5 			//size of Buffer
#define MAX_SIZE 5		//size of memory 
#include "x86_tso_buffer.pml"


/*Channel der die reads und writes verschickt (Type (also write,read); Adresse; Wert;... )*/
chan channelT1 = [0] of {mtype, short, short, short};
chan channelT2 = [0] of {mtype, short, short, short};
chan channelT3 = [0] of {mtype, short, short, short};
short r1 = 0;
short r2 = 0;
short r3 = 0;

proctype process1(chan ch)
{
	write(ADRESSE_X, 1);
}

proctype process2(chan ch)
{
	read(ADRESSE_X, r1);
	write(ADRESSE_Y, 1);
}

proctype process3(chan ch)
{
	read(ADRESSE_Y, r2);
	read(ADRESSE_X, r3);
	
	atomic{ r1 == 1 && r2 == 1 -> assert (r3 == 1)};
	//atomic{ r1 == 1 && r2 == 1 -> assert (r3 == 0)}
}

init {
	atomic{
	run process1(channelT1);
	run process2(channelT2);
	run process3(channelT3);
	run bufferProcess(channelT1);
	run bufferProcess(channelT2);
	run bufferProcess(channelT3)
	}
}

