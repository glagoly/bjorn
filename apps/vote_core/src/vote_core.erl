-module(vote_core).
-compile(export_all).

-record(poll, {alts, prefs}).

new(Alts) -> #poll{alts = sets:from_list([sq | Alts]), prefs = matrix:new([sq | Alts])}.

prefs(Poll) -> matrix:to_list(Poll#poll.prefs).

fold_votes(_, [], Prefs, Rest) -> {Prefs, Rest};
fold_votes(Fun, [Votes | Tail], Prefs, Rest) ->
	Votes2 = sets:intersection(sets:from_list(Votes), Rest),
	Rest2 = sets:subtract(Rest, Votes2),
	Prefs2 = sets:fold(fun (Alt1, Prefs) -> 
		sets:fold(fun (Alt2, Prefs) -> Fun(Alt1, Alt2, Prefs) end, Prefs, Rest2)
	end, Prefs, Votes2),
	fold_votes(Fun, Tail, Prefs2, Rest2).

add_ballot(Up, Down, Poll) -> add_ballot(Up, Down, Poll, 1).

add_ballot(Up, Down, Poll, Weight) -> 
	{Prefs2, Rest} = fold_votes(fun (Alt1, Alt2, Prefs) ->
			matrix:update_counter(Alt1, Alt2, Weight, Prefs)
		end, Up, Poll#poll.prefs, Poll#poll.alts),
	{Prefs3, _} = fold_votes(fun (Alt1, Alt2, Prefs) ->
			matrix:update_counter(Alt2, Alt1, Weight, Prefs)
		end, Down, Prefs2, Rest),
	Poll#poll{prefs = Prefs3}.

key_group([]) -> [];
key_group(L) -> key_group_sorted(lists:keysort(1, L)).

key_group_sorted([{Key, Value} | L]) ->
	{I, Current, Acc} = lists:foldl(fun({Key, Value}, {I, Current, Acc}) -> 
		case Key =:= I of
			true -> {I, [Value | Current], Acc};
			_ -> {Key, [Value], [{I, Current} | Acc]}
		end
	end, {Key, [Value], []}, L),
	[{I, Current} | Acc].

%% Create a UUID v4 (random) as a base64 string
%% "+" are replaced with "-"
%% source avtobiff/erlang-uuid
uuid() ->
    <<U0:32, U1:16, _:4, U2:12, _:2, U3:30, U4:32>> = crypto:rand_bytes(16),
    U = base64:encode_to_string(<<U0:32, U1:16, 4:4, U2:12, 2#10:2, U3:30, U4:32>>),
    lists:sublist(re:replace(U, "\\+", "-", [global, {return, list}]), 22).