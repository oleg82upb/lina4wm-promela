/*
	trying to specify the LLVM-compiled Treiber Stack implementation  
*/

#define BUFF_SIZE 8 	//size of Buffer
#define MEM_SIZE 200	//size of memory 
#include "x86_tso_buffer.pml"

//Types for LLVM
short Stack = 0; //= {0};
short Node = 1; //= {0,1};
short I32 = 0; // = {0};

chan channelT1 = [0] of {mtype, short, short, short};

inline getelementptr(type, instance, offset, targetRegister)
{
	//simplified version of what llvm does.
	//we don't need the type as long as we assume our memory to hold only values/pointers etc of equal length. 
	//In this case, the offset directly correspond to adding it to instance address. 
	assert(offset <= type); //offset shouldn't be greater than the type range
	targetRegister = instance + offset;
}

inline alloca(type, targetRegister)
{
	atomic{
	//need c_Code here, but for now we could use this to statically define used addresses
	skip;
	}
}






inline push(this, v)
{
short thisAddr, vAddr, n, ss, v0, v1, v2, v3, v4, v5, v7, v9, v11, this1, val, head, head2, next; 
entry: 
	alloca(Stack, thisAddr);
	alloca(I32, vAddr);
	alloca(Node, n);
	alloca(Node, ss);
	write(thisAddr, this);
	write(vAddr, v);
	read(thisAddr, this1);
	//new Node();
	
invokeCont: 
	write(n, v0);
	read(vAddr, v1);
	read(n, v2);
	getelementptr(Node, n, 0, val);
	write(val, v1);
		 
doBody: 
	getelementptr(Stack, this, 0, head);
	read(head, v3);		// volatile! use mfence() here?;
	write(ss, v3);
	read(ss, v4);
	read(n, v5);
	getelementptr(Node, v5, 1, next);
	write(next, v4);
	
doCond:
	getelementptr(Stack, this1, 0, head2);
	//bitcast head2 to i32 for cas. we don't need this. its local anyway
	read(ss, v7);
	//ptrtoint ...
	read(n, v9);
	cas(head2, v7, v9, v11);
	if 
		:: v11 == false -> goto doBody;
		:: else -> skip;;
	fi
//doEnd: 
//	skip; //done
}

proctype process1(chan ch){
	push(1, 666);
}

init{
	run process1(channelT1);
	run bufferProcess(channelT1);
}