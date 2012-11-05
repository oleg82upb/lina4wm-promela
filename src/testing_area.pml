
/*Array welches die  Queue darstellt (Form: 3-dimensionales Array der Laenge SIZE) das heißt (nx3)-Matrix*/
#define SIZE 5
#define MAX_SIZE 10 

//[zahl] gibt Größe an (also die Dimension)
typedef matrix{int zeile [3]}
mtype = {write, read};
/*Channel der die reads und writes verschickt (Type (also write,read); Adresse; Wert;... )*/
chan channel = [0] of {mtype, int, int, int};
/*Writebuffer*/
matrix queue [SIZE];
matrix memory[MAX_SIZE];

/* ... TODO ... memory initialisieren???? welche Adressen existieren? */
active proctype receiver()
{		
	/*Queue Anfang bzw Ende*/
	int head = -1;
	int tail = -1;
	int adresse, value,c; 
	int i = 0;
	
	/* ----------- read-Test dafür Arrays mit Werten initialisieren -----------*/
	do
	:: i < SIZE ->	queue[i].zeile[1] = 10*i;
		queue[i].zeile[0] = i+42;
		memory[i].zeile[1] = 100*i;
		memory[i].zeile[0] = i+1;
		i++;
	:: else -> break;
	od;
	
	
	/*enqueue-Operation der Queue vom Writebuffer (einfügen in Queue wenn ein write-Befehl geschickt wird) und bei read-Befehl Queue bzw Speicher durchsuchen und Wert zurückgeben */
	
	{
		if
		:: channel ? write(adresse,value,c) ->
			/*error if buffer full*/
			if
			:: (head == 0 && tail == SIZE-1 || head == tail+1) -> printf("Buffer full\n");
			:: else ->	if
		/*Initialisierung, wenn der erste Wert gesetzt wird*/
					:: head == -1 && tail == -1 ->head = 0;	
					::(tail == SIZE-1) -> tail = 0;	
					fi;
					atomic{
						tail ++;
						queue[tail].zeile[0] = adresse;
				 		queue[tail].zeile[1] = value;
				 		queue[tail].zeile[2] = c; 
				 	}
			fi
			
			
		:: channel ? read, adresse, value, c ->
			i=0;
			do
			:: i < SIZE -> if
					/* if Adresse entspricht gesuchter Adresse -> gib zugehörigen Wert zurück*/
					::queue[i].zeile[0] == adresse ->  channel ! read,adresse,queue[i].zeile[1],c;
					::else -> i++;
					fi
			/*Zugriff auf Speicher und Rückgabe des entsprechenden Wertes*/
			::i>=SIZE -> channel ! read,adresse,memory[i].zeile[1],c;
			od
		fi
		
	}	
		

}
active proctype sender()
{
	int x = 1;
	int y = 3;
	int z = 1;
	int key = 1;
	int re_adresse, re_value, re_c;
	printf("%d\n%d\n%d\n",x,y,z); 
	
	again:
	do
		:: key == 1 -> x++; channel ! write,x,y,z; key++; goto again
		:: key == 2 -> z++; channel ! write,x,y,z; key++;goto again
		:: key ==3 -> channel ! read(x,y,z); key++;goto again
		:: channel ? read(re_adresse,re_value,re_c) -> printf("%d\n", re_value)
		:: key == 4 -> channel ? read(x,y,z); key++
		:: key == 5 -> y++; channel ! write,3,y,42; key++
	/* nur reads betrachten*/
		:: key == 6 -> x++; channel ! write,x,y,z; key++
		:: key == 7 -> z++; channel ! write,x,y,z; key++
	od	

}