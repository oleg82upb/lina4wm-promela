/*
author: Annika Mütze <muetze.annika@gmail.com>
date: 10.2012

writebuffer model. Read, write, flush, fence and CAS
*/

#define NULL 0

/*Buffer as a 2 dimensional array which represents the queue [(nx2)-matrix]*/
typedef matrix{short line [2]}

mtype = {iWrite, iRead , iMfence, iCas};
/*memory*/
short memory[MEM_SIZE];


inline write(adr, newValue)
{
	ch ! iWrite, adr, newValue, NULL;
}

inline read(adr, target)
{
	atomic{
	short readValue;
	ch ! iRead, adr, NULL, NULL;
	ch ? iRead, adr, readValue, NULL;
	target = readValue;
	}
}

inline mfence()
{
	ch ! iMfence, NULL, NULL, NULL;
}	

inline cas(adr, oldValue, newValue, returnValue) 
{
	// 2 steps for the executing process, but atomic on memory
	bit success;
	ch ! iCas, adr, oldValue, newValue;
	ch ? iCas, adr, success, _; 
	returnValue = success;
}

inline writeB() {
	/* if
		//buffer full, need to flush first
	:: (((tail+1) % BUFF_SIZE) == head && !isEmpty) -> flushB()	
	:: else -> isEmpty = false; skip;
	fi
		-> */	
	assert(!(((tail+1) % BUFF_SIZE) == head && !isEmpty)); //buffer should never be full
	isEmpty = false;
 	tail = (tail+1) % BUFF_SIZE;
	buffer[tail].line[0] = address;
	buffer[tail].line[1] = value;
}


inline readB() {
	short i = tail;
	if 
		:: tail < head && !isEmpty -> i = i + BUFF_SIZE;
	   	:: else -> skip;
	fi
	->
	do
	:: i >= head  -> 
			if
			/* if an address in the buffer is equivalent to the searched -> return value*/
			::buffer[i%BUFF_SIZE].line[0] == address 
				->  channel ! iRead,address,buffer[i%BUFF_SIZE].line[1],NULL;
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
	/*write value in memory: memory[address] = value*/
	memory[buffer[head].line[0]] = buffer[head].line[1];
	/*empty write buffer*/
	buffer[head].line[0] = 0;
	buffer[head].line[1] = 0;
						
	/*moving head*/
	head = (head+1) % BUFF_SIZE;
			
	if
	::(head == ((tail+1) % BUFF_SIZE))-> isEmpty = true;
	:: else -> skip;
	fi;
}

inline mfenceB() {
	do
	:: atomic{
			if
			::isEmpty -> break;
			::else -> flushB() 
			fi
		}
	od
}
	
inline casB() 
{
	mfenceB();	//buffer must be empty
	atomic{ 
		bit result = false;
		if 
			:: memory[address] == old 
				-> 	memory[address] = new;
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
	short head = 0;
	short tail = -1;
	bit isEmpty = true;

	short address = 0;
	short value = 0; 
	short old = 0;
	short new = 0;
	
	/*writebuffer*/
	matrix buffer [BUFF_SIZE];

	
end:	do 
		::	/*
		atomic{ 
				if
				//WRITE
				:: channel ? iWrite(address,value, _) -> writeB();
				//READ
				:: channel ? iRead, address, value, _ -> readB();
				//FLUSH
				:: !isEmpty -> flushB();
				//FENCE
				:: channel ? iMfence, _, _ ,_ -> mfenceB();
				//COMPARE AND SWAP
				:: channel ? iCas, address , old, new -> casB();
				fi
			} */
			if
				//WRITE
				:: atomic{channel ? iWrite(address,value, _) -> writeB();}
				//READ
				:: atomic{channel ? iRead, address, value, _ -> readB();}
				//FLUSH
				:: atomic{!isEmpty -> flushB();}
				//FENCE
				:: channel ? iMfence, _, _ ,_ -> mfenceB();
				//COMPARE AND SWAP
				:: channel ? iCas, address , old, new -> casB();
			fi
		od
}