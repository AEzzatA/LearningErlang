-module(my_server).
-compile(export_all).

call(Pid, Msg) ->
	Ref = erlang:monitor(process, Pid),
	Pid ! {sync, self(), Ref, Msg},
	receive
		{Ref, Replay} ->
			erlang:demonitor(Ref, [flush]),
			Replay;
		{'DOWN', Ref, process, Pid, Reason} ->
			erlang:error(Reason)
		after 5000 ->
			erlang:error(timeout)
	end.

cast(Pid, Msg) ->
	Pid ! {async, Msg},
	ok.