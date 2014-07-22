%%%-------------------------------------------------------------------
%%% @author tihon
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. июн 2014 18:00
%%%-------------------------------------------------------------------
-module(erlog_dict).
-author("tihon").

-behaviour(erlog_storage).

%% erlog callbacks
-export([new/0, new/1,
	add_built_in/2,
	add_compiled_proc/2,
	assertz_clause/2,
	asserta_clause/2,
	retract_clause/2,
	abolish_clauses/2,
	get_procedure/2,
	get_procedure_type/2,
	get_interp_functors/1,
	findall/2]).

%% API
-export([]).

new() -> {ok, dict:new()}.

new(_) -> {ok, dict:new()}.

add_built_in(Db, {Functor}) ->
	{ok, dict:store(Functor, built_in, Db)}.

add_compiled_proc(Db, {{Functor, M, F}}) ->
	{ok, dict:update(Functor,
		fun(built_in) ->
			erlog_errors:permission_error(modify, static_procedure, ec_support:pred_ind(Functor), Db);
			(_) -> {code, {M, F}}
		end, {code, {M, F}}, Db)}.

assertz_clause(Db, {Head, Body0}) ->
	{clause(Head, Body0, Db,
		fun(T, Body, Cs) ->
			{clauses, T + 1, Cs ++ [{T, Head, Body}]}
		end), Db}.

asserta_clause(Db, {Head, Body0}) ->
	{clause(Head, Body0, Db,
		fun(T, Body, Cs) ->
			{clauses, T + 1, [{T, Head, Body} | Cs]}
		end), Db}.

retract_clause(Db, {Functor, Ct}) ->
	{ok, case dict:find(Functor, Db) of
		     {ok, built_in} ->
			     erlog_errors:permission_error(modify, static_procedure, ec_support:pred_ind(Functor), Db);
		     {ok, {code, _}} ->
			     erlog_errors:permission_error(modify, static_procedure, ec_support:pred_ind(Functor), Db);
		     {ok, {clauses, Nt, Cs}} ->
			     dict:store(Functor, {clauses, Nt, lists:keydelete(Ct, 1, Cs)}, Db);
		     error -> Db        %Do nothing
	     end}.

abolish_clauses(Db, {Functor}) ->
	{ok, case dict:find(Functor, Db) of
		     {ok, built_in} ->
			     erlog_errors:permission_error(modify, static_procedure, ec_support:pred_ind(Functor), Db);
		     {ok, {code, _}} -> dict:erase(Functor, Db);
		     {ok, {clauses, _, _}} -> dict:erase(Functor, Db);
		     error -> Db        %Do nothing
	     end}.

get_procedure(Db, {Functor}) ->
	{case dict:find(Functor, Db) of
		 {ok, built_in} -> built_in;    %A built-in
		 {ok, {code, {_M, _F}} = P} -> P;    %Compiled (perhaps someday)
		 {ok, {clauses, _T, Cs}} -> {clauses, Cs};  %Interpreted clauses
		 error -> undefined      %Undefined
	 end, Db}.

get_procedure_type(Db, {Functor}) ->
	{case dict:find(Functor, Db) of
		 {ok, built_in} -> built_in;    %A built-in
		 {ok, {code, _}} -> compiled;    %Compiled (perhaps someday)
		 {ok, {clauses, _, _}} -> interpreted;  %Interpreted clauses
		 error -> undefined      %Undefined
	 end, Db}.

get_interp_functors(Db) ->
	{dict:fold(fun(_Func, built_in, Fs) -> Fs;
		(Func, {code, _}, Fs) -> [Func | Fs];
		(Func, {clauses, _, _}, Fs) -> [Func | Fs]
	end, [], Db), Db}.

clause(Head, Body0, Db, ClauseFun) ->
	{Functor, Body} = case catch {ok, ec_support:functor(Head), ec_body:well_form_body(Body0, false, sture)} of
		                  {erlog_error, E} -> erlog_errors:erlog_error(E, Db);
		                  {ok, F, B} -> {F, B}
	                  end,
	dict:update(Functor,
		fun(built_in) ->
			erlog_errors:permission_error(modify, static_procedure, ec_support:pred_ind(Functor), Db);
			({code, _}) ->
				erlog_errors:permission_error(modify, static_procedure, ec_support:pred_ind(Functor), Db);
			({clauses, T, Cs}) -> ClauseFun(T, Body, Cs)
		end, {clauses, 1, [{0, Head, Body}]}, Db).

findall(State, {Functor}) ->  %TODO implement me!
	erlang:error(not_implemented).
