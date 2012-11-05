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
bit r1 = 0;
bit r2 = 0;
bit r3 = 0;

active proctype process1()
{
	channelT1 ! iWrite,ADRESSE_X,1,NULL;	
}

active proctype process2()
{
	atomic{
	channelT2 ! iRead, ADRESSE_X, NULL, NULL;
	channelT2 ? iRead, ADRESSE_X, r1, _;
	}
	channelT2 ! iWrite, ADRESSE_Y, 1, NULL;
}

active proctype process3()
{
	atomic{
	channelT3 ! iRead, ADRESSE_Y, NULL, NULL;
	channelT3 ? iRead, ADRESSE_Y, r2, _;
	}
	atomic{
	channelT3 ! iRead, ADRESSE_X, NULL,NULL;
	channelT3 ? iRead, ADRESSE_X, r3, _; 
	}
	atomic{ r1 == 1 && r2 == 1 -> assert (r3 == 1)};
	//atomic{ r1 == 1 && r2 == 1 -> assert (r3 == 0)}
}

init {
	atomic{
	run bufferProcess(channelT1);
	run bufferProcess(channelT2);
	run bufferProcess(channelT3)
	}
}