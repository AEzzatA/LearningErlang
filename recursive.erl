-module(recursive).
-export([tail_fac/1,
	 len/1,
	 fac/1,
	 tail_duplicate/2,
	 duplicate/2,
	 reverse/1,
	 tail_reverse/1
	 ]).
fac(0) -> 1;
fac(N) when N >  0 -> N*fac(N-1).

len([]) -> 0;
len([_|T]) -> 1 + len(T).

tail_fac(N) -> tail_fac(N,1).

tail_fac(0,Acc) -> Acc;
tail_fac(N,Acc) when N > 0 -> tail_fac(N-1,N*Acc).

duplicate(0,_) -> [];
duplicate(N,Term) when N > 0 ->
	[Term|duplicate(N-1,Term)].

tail_duplicate(N,Term) ->
	tail_duplicate(N,Term,[]).
tail_duplicate(0,_,List) ->
	List;
tail_duplicate(N,Term,List) when N > 0 ->
	tail_duplicate(N-1, Term, [Term|List]).

reverse([]) -> [];
reverse([H|T]) -> reverse(T)++[H].

tail_reverse(L) -> tail_reverse(L,[]).
tail_reverse([],Acc) -> Acc;
tail_reverse([H|T],Acc) -> tail_reverse(T, [H|Acc]).

sublist(_,0) -> [];
sublist([],_) -> [];
sublist([H|T],N) when N > 0 ->
	[H|sublist(T,N-1)].

tail_sublist(L,N) -> tail_sublist(L,N,[]).

tail_sublist(_,0,Sublist) -> Sublist;
tail_sublist([],_,Sublist) -> Sublist;
tail_sublist([H|T],N, Sublist) when N > 0 ->
	tail_sublist(T,N-1,[H|Sublist]).
tail_sublist(L,N) -> reverse(tail_sublist(L,N,[])).

