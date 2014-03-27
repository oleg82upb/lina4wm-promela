/*
author: Annika Mütze <muetze.annika@gmail.com>
date: 10.2012

writebuffer model. Read, write, flush, fence and CAS
*/

#define NULL 0


/*Buffer as a 2 dimensional array which represents the queue [(nx2)-matrix]*/
typedef matrix{short line [2]}
typedef arrayarray{matrix buffer [BUFF_SIZE]};

mtype = {iWrite, iRead , iMfence, iCas};
/*memory*/
short memory[MEM_SIZE];

/*declaration of global bufferarray*/
arrayarray proc [PROC_NUMBER + 1];


inline write(adr, newValue)
{
	ch ! iWrite, adr, newValue, NULL;
}

inline read(adr, target)
{
	atomic{
	ch ! iRead, adr, NULL, NULL;
	ch ? iRead, adr, target, NULL;
	}
}

inline mfence()
{
	ch ! iMfence, NULL, NULL, NULL;
}	

inline cas(adr, oldValue, newValue, successBit) 
{
	// 2 steps for the executing process, but atomic on memory
	atomic{
		ch ! iCas, adr, oldValue, newValue;
		ch ? iCas, adr, successBit, _; 
	}
}

inline writeB() {
	atomic{
	assert(tail < BUFF_SIZE);
	proc[ _pid-(_pid/2)].buffer[tail].line[0] = address;
	proc[ _pid-(_pid/2)].buffer[tail].line[1] = value;
	tail++;
	}
}


inline readB() {
	i = tail-1;
	do
	:: i >= 0  -> 
			if
			/* if an address in the buffer is equivalent to the searched -> return value*/
			::proc[ _pid-(_pid/2)].buffer[i].line[0] == address 
				->  channel ! iRead,address,proc[ _pid-(_pid/2)].buffer[i].line[1],NULL;
					i = 0;
					break;
			::else -> i--;
			fi
			/*else: access to memory and return value of searched address*/
	::else ->
		channel ! iRead,address,memory[address],NULL;
		i = 0;
		break;
	od
}


inline flushB() {
atomic{
	
	if 
	:: (tail > 0) ->	{
		//write value in memory: memory[address] = value
		memory[proc[ _pid-(_pid/2)].buffer[0].line[0]] = proc[ _pid-(_pid/2)].buffer[0].line[1];
		//move all content one step further
		
		for (i : 1 .. tail-1) {
			proc[ _pid-(_pid/2)].buffer[i-1].line[0] = proc[ _pid-(_pid/2)].buffer[i].line[0];
			proc[ _pid-(_pid/2)].buffer[i-1].line[1] = proc[ _pid-(_pid/2)].buffer[i].line[1];
		} 
		//remove duplicate tail
		proc[ _pid-(_pid/2)].buffer[tail-1].line[0] = 0;
		proc[ _pid-(_pid/2)].buffer[tail-1].line[1] = 0;
		tail--;
		i = 0;
		}
	:: else -> skip;
	fi;
	}
}

inline mfenceB() {
	atomic{	
		do
		::
			if
			::(tail<=0) -> break;	//tail > 0 iff buffer not empty
			::else -> flushB() 
			fi
		od
	}
}
	
inline casB() 
{
	mfenceB();	//buffer must be empty
	atomic{ 
		bit result = false;
		if 
			:: memory[address] == value 
				-> 	memory[address] = newValue;
					result = true;
			:: else -> skip;
		fi
		->
		channel ! iCas, address, result, NULL;
		//reducing state space from here on
	}
	
}

proctype bufferProcess(chan channel)
{		
	/*start resp. end of queue*/
	short tail = 0;
	short i = 0;
	short address = 0;
	short value = 0; 
	short newValue = 0;

	
end:	do 
		::	if
				//WRITE
				:: atomic{channel ? iWrite(address,value, _) -> writeB();}
				//READ
				:: atomic{channel ? iRead, address, value, _ -> readB();}
				//FLUSH
				:: atomic{(tail > 0) -> flushB();}  //tail > 0  iff not empty
				//FENCE
				:: channel ? iMfence, _, _ ,_ -> mfenceB();
				//COMPARE AND SWAP
				:: atomic{channel ? iCas, address , value, newValue -> casB()};
			fi
		od
}