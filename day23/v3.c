#include "stdio.h"

int main() {
	int size  = 1000000;
	int moves = 10000000;
	int next[size+1];
	const int init[9] = {3,8,9,1,2,5,4,6,7};
	int i;
	int first = init[0];
	int current = first;
	int move=1;

	int prev = first;
	for( i=1; i<9; ++i ) {
		next[prev] = init[i];
		prev = init[i];
	}
	for( i=10; i<=size; ++i ) {
		next[prev] = i;
		prev = i;
	}
	next[prev]=first;
	while( move<=moves ) {
		int grab = next[current];
		next[current] = next[next[next[grab]]];
		int dest_label = current-1;
		if( dest_label == 0 ) { dest_label = size; }
		while( dest_label==grab
		    || dest_label==next[grab] 
		    || dest_label==next[next[grab]] ) {
			dest_label--;
			if( dest_label == 0 ) { dest_label = size; }
		}
		int after_dest = next[dest_label];
		next[dest_label] = grab;
		next[next[next[grab]]] = after_dest;

		current=next[current];
		move++;
	}

	printf( "%d x %d = %ld\n", next[1], next[next[1]],(long) next[1]*(long)next[next[1]] );
	return 0;
}
