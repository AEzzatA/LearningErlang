-module (hotload).
-export([server/1, upgrade/1]).

server(State) ->
	receive
		update ->
			NewState = ?MODULE:upgrade(State),
			?MODULE:server(NewState); %%loop in the new version
			%%of code
		SomeMessage ->
			%%do something here
			server(State) %stay in the same version no mattar what.
	end.

upgrade(OldState) -> OldState.
%%transform and return the state here