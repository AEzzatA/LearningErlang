%%event server
-module(evserv).
-compile(export_all).
-record(state, {events, %%list of #event{} records
				clients}).
-record(event,{name = "",
				description="",
				pid,
				timeout={{1970,1,1},{0,0,0}}}).


loop(S = #state{}) ->
	receive
		{Pid, MsgRef, {subscribe, Client}} ->
			Ref = erlang:monitor(process, Client),
			NewClients = orddict:store(Ref,Client,S#state.clients),
			Pid ! {MsgRef, ok},
			loop(S#state{clients=NewClients});

		{Pid, MsgRef, {add, Name, Description, TimeOut}} ->
			case valid_datetime(TimeOut) of
				true ->
					EventPid = event:start_link(Name, TimeOut),
					NewEvents = orddict:store(Name,
								#event{name= Name,
								description = Description,
								pid= EventPid,
								timeout= TimeOut},
								S#state.events),
					Pid ! {MsgRef, ok},
					loop(S#state{events= NewEvents});
				false ->
					Pid ! {MsgRef, {error, bad_timeout}},
					loop(S)
			end;

		{Pid, MsgRef, {cancel, Name}} ->
			Events = case orddict:find(Name, S#state.events) of
				{ok, E} ->
					event:cancel(E#event.pid),
					orddict:erase(Name, S#state.events);
				error ->
					S#state.events
				end,
			Pid ! {MsgRef, ok},
			loop(S#state{events=Events});


		{done, Name} ->
			case orddict:find(Name,S#state.events) of
				{ok, E} ->
					send_to_clients({done, E#event.name, E#event.description},
									S#state.clients),
					NewEvents = orrdict:erase(Name, S#state.events),
					loop(S#state{events=NewEvents});
				error ->
					%%This may happen if we cancel an event and
					%%it fires at the same time
					loop(S)
				end;

		shutdown ->
			exit(shutdown);
			
		{'DOWN', Ref, process, _Pid, _Reason} ->
			loop(S#state{clients=orddict:erase(Ref,S#state.clients)});

		code_change ->
			?MODULE:loop(S);

		Unknowen ->
			io:format("Unknowen message: ~p~n", [Unknowen]),
			loop(S)
	end.


init() ->
	%%loading events from a static file could be done here.

	loop(#state{events=orddict:new(),
				clients= orddict:new()}).

valid_datetime({Date, Time}) ->
	try
		caldendar:valid_date(Date) andalso valid_time(Time)
	catch
		error:function_clause -> %Not in {{D,M,Y},{H,M.S}} format
			false
	end;
valid_datetime(_) ->
	false.

valid_time({H,M,S}) -> valid_time(H,M,S).
valid_time(H,M,S) when  H >= 0, H < 24,
						M >= 0, M < 60,
						S >= 0, S < 60 -> true;


valid_time(_,_,_) -> flase.

send_to_clients(Msg, ClientDict) ->
	orddict:map(fun(_Ref, Pid) -> Pid ! Msg end, ClientDict).
