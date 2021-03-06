/*
*author: Annika Mütze <muetze.annika@gmail.com>
*date: 11.2012
*
*
*/

#define ADRESSE_X 1
#define ADRESSE_Y 2
#define ADRESSE_Z 3
#define BUFF_SIZE 5 	//size of Buffer
#define MEM_SIZE 5		//size of memory 

#define PROC_NUMBER 4
#include "../x86_tso_buffer_globalarray.pml"

/*Channel der die reads und writes verschickt (Type (also write,read); Adresse; Wert;... )*/
chan channelT1 = [0] of {mtype, short, short, short};
chan channelT2 = [0] of {mtype, short, short, short};
chan channelT3 = [0] of {mtype, short, short, short};
chan channelT4 = [0] of {mtype, short, short, short};

short r1 = 0;
short r2 = 0;
short r3 = 0;
short r4 = 0;

proctype process1(chan ch)
{
	write(ADRESSE_Y, 1);
	write(ADRESSE_X, 1);
	done:skip;	
}

proctype process2(chan ch)
{
	write(ADRESSE_X, 2);
	write(ADRESSE_Z, 1);
	done:skip;
}

proctype process3(chan ch)
{
	read(ADRESSE_X, r1);
	read(ADRESSE_X, r2);
	done:skip;
}
proctype process4(chan ch)
{
	read(ADRESSE_Z, r3);
	read(ADRESSE_Y, r4);
	done:skip;
}

init {
	atomic{
	run process1(channelT1);
	run bufferProcess(channelT1);
	run process2(channelT2);
	run bufferProcess(channelT2);
	run process3(channelT3);
	run bufferProcess(channelT3);
	run process4(channelT4);
	run bufferProcess(channelT4);
	}
}
ltl check {[]((process1 @ done && process2 @ done && process3 @ done && process4 @ done)
			-> !(r1 == 1 && r2 == 2 && r3 == 1 && r4 == 0))};
