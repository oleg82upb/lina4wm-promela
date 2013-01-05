
#define NULL -1

/*Array welches die  Queue darstellt (Form: 3-dimensionales Array der Laenge SIZE) das heißt (nx3)-Matrix*/
typedef matrix{short line [3]}
/*Speicher*/
short memory[MEM_SIZE];


inline write(adr, value)
{
	memory[adr] = value;
}

inline read(adr, target)
{
	target = memory[adr];
}


inline flush() {
	skip;	// no action
}

inline mfence() {
	skip; //no action
}
	
inline cas(adr, oldValue, newValue, returnValue) {
	atomic{
	if 	:: memory[adr] == oldValue
			-> {
				memory[adr] = newValue;
				returnValue = true;
				}
		:: returnValue = false;
	fi
	}
}
		