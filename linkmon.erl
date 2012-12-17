-module(linkmon).
-compile([export_all]).

myproc() ->
	timer:sleep(5000),
	exit(reason).
	
chain(0) ->
	receive
		_ -> ok
	after 2000 ->
		exit("chain dies here")
	end;
chain(N) ->
	Pid = spawn(fun() -> chain(N -1) end),
	link(Pid),
	receive
		_ -> ok
	end.

start_critic() ->
	spawn(?MODULE, critic, []).

judge(Pid, Band, Album) ->
	Pid ! {self(), {Band, Album}},
	receive
		{Pid, Criticism} -> Criticism
	after 2000 ->
		timeout
	end.
critic() ->
	receive
		{From, {"Rage Against the Turing Machine", "Unit Testify"}} ->
			From ! {self(), "They are great!"};

		{From, {"System of a Downtime", "Memorize"}} ->
			From ! {self(), "They're not jhonny chash but they're good."};

		{From, {"Jhonny Crash", "The token Ring of Fire"}} ->
			From ! {self(), "Simply incredible."};

		{From, {_Band, _Album}} ->
			From ! {self(), "They are terrible!"}
		end,
		critic().

start_critic2() ->
	spawn(?MODULE, restarter, []).

restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, critic2, []),
	register(critic, Pid),
	receive
		{'EXIT', Pid, normal} -> % not a crash
			ok;
		{'EXIT', Pid, shutdown} -> % manual termination, not a crash
			ok;
		{'EXIT', Pid, _} ->
		restarter()
	end.

judge(Band, Album) ->
	critic ! {self() , {Band, Album}},
	Pid = whereis(critic),
	receive
		{Pid, Criticism} -> Criticism
	after 2000 ->
	timeout
	end.

%%%%%%%%%%%%%%%%%%%%%

judge2(Band, Album) ->
	Ref = make_ref(),
	critic ! {self(), Ref, {Band, Album}},
	receive
		{Ref, Criticism} -> Criticism
	after 2000 ->
		timeout
	end.

critic2() ->
	receive
		{From, Ref, {"Rage against the Turing Machine", "Unit Testifu"}} ->
			From ! {Ref, "They are Great"};
		
		{From, Ref, {"System of a Downtime", "Memoize"}} ->
			From ! {Ref, "They are not Jhonny Crash but they're good."};
		{From, Ref, {"Jhonny Crash", "The Token Ring of Fire"}} ->
			From ! { Ref, "Simply Incredible."};
		
		{From, Ref, {_Band, _Album}} -> 
			From ! {Ref, "They are terible!"}
	end,
	critic2().

