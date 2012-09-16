-module(what_the_if).
-author("Ahmed Ezzat Afifi").
-export([heh_fine/0, oh_god/1,help_me/1, insert/2]).
%% A module to learn if statment in erlang
heh_fine() ->
	if 1 =:= 1 ->
		works
	end,
	if 1 =:=2; 1 =:= 1 ->
		works
	end,
	if 1=:= 2, 1 =:= 1 ->
		fails
	end.

oh_god(N) ->
	if N =:= 2 -> might_succeed;
		true -> always_does
	end.
help_me(Animal) ->
	Talk = if 
		Animal == cat -> "meow";
		Animal == beef -> "mooo";
		Animal == dog -> "bark";
		Animal == tree -> "bark";
		true -> "fgdadfgna"
	end,
	{Animal, "Says " ++ Talk ++ "!"}.

insert(X,[]) ->
	[X];
insert(X,Set) ->
	case lists:member(X,Set) of
		true -> Set;
		false -> [X|Set]
	end.
