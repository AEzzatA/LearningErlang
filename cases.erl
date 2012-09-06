-module(cases).
-export([beach/1]).
-author("Ahmed Ezzat Afifi").

beach(Temperature) ->
	case Temperature of
		{celsius,N} when N >= 20, N =< 45 ->
		'favorable';
		{kelvin,N} when N >= 293, N =< 318 ->
		'scientifically favorable';
		{fahrenheit,N} when N >= 68, N =< 113 ->
		'favorable in the US';
		_ ->
		'avoid beach'
	end.
