/*
author: Annika Mütze <muetze.annika@gmail.com>
date: 10.2012

Litmus-Test: Stores Are Seen in a Consistent Order by Other Processors
 */

#define ADRESSE_X 1
#define ADRESSE_Y 2
#define BUFF_SIZE 5 	//size of Buffer
#define MEM_SIZE 5		//size of memory 
#include "sc-model.pml"


short r1 = 0;
short r2 = 0;
short r3 = 0;
short r4 = 0;

proctype process1()
{
	write(ADRESSE_X, 1);	
}

proctype process2()
{
	write(ADRESSE_Y, 1);
}

proctype process3()
{
	read(ADRESSE_X, r1);
	read(ADRESSE_Y, r2);
	done:skip;
}
proctype process4()
{
	read(ADRESSE_Y, r3);
	read(ADRESSE_X, r4);
	done:skip;
}

init {
	atomic{
	run process1();
	run process2();
	run process3();
	run process4();
	}
}
	/* (r1 == 1) && (r2 == 0) && (r3 == 1) && (r4 == 0)	-> not allowed */
ltl check_0 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 1 && r2 == 0 && r3 == 1 && r4 == 0)))};
	
ltl check_1 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 1 && r2 == 0 && r3 == 0 && r4 == 0)))}; 
ltl check_2 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 1 && r2 == 0 && r3 == 0 && r4 == 1)))};

ltl check_3 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 1 && r2 == 1 && r3 == 0 && r4 == 0)))};
ltl check_4 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 1 && r2 == 0 && r3 == 1 && r4 == 1)))};
ltl check_5 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 1 && r2 == 1 && r3 == 1 && r4 == 0)))};
ltl check_6 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 1 && r2 == 1 && r3 == 0 && r4 == 1)))};
ltl check_7 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 1 && r2 == 1 && r3 == 1 && r4 == 1)))};
ltl check_8 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 0 && r2 == 0 && r3 == 0 && r4 == 0)))};
ltl check_9 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 0 && r2 == 0 && r3 == 0 && r4 == 1)))};
ltl check_10 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 0 && r2 == 0 && r3 == 1 && r4 == 0)))};
ltl check_11 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 0 && r2 == 1 && r3 == 0 && r4 == 0)))};
ltl check_12 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 0 && r2 == 0 && r3 == 1 && r4 == 1)))};
ltl check_13 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 0 && r2 == 1 && r3 == 1 && r4 == 0)))};
ltl check_14 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 0 && r2 == 1 && r3 == 0 && r4 == 1)))};
ltl check_15 { [] ((process3 @ done && process4 @ done) ->( ! (r1 == 0 && r2 == 1 && r3 == 1 && r4 == 1)))};
