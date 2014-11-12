-module(erlog_ets_tests).
%% Copyright (c) 2014 Zachary Kessin
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-include_lib("eqc/include/eqc.hrl").
-include_lib("eunit/include/eunit.hrl").
-include("erlog_test.hrl").

-compile(export_all).



% erlog_ets_all_test() ->
%     {ok, ERLOG}   = erlog_:new(),
%     ok = erlog:load(ERLOG,erlog_ets),
%     TabId = ets:new(test_ets_table, [bag, {keypos,2}, named_table]),
%     ?assertEqual({succeed,[]},erlog:prove(ERLOG, {ets_all, test_ets_table})),
%     ok.

erlog_empty_ets_test() ->
    {ok, ERLOG}		= erlog:new(),
    {ok, ERLOG1}	= erlog:load(erlog_ets,ERLOG),
    TabId		= ets:new(test_ets_table, [bag, {keypos,2}]),
    {fail,_}	        = erlog:prove( {ets_keys, TabId,{'S'}},ERLOG1),
    {fail,_}	        = erlog:prove({ets_match, TabId,{'S'}},ERLOG1),
    true.

    
     
gnode() ->
    {edge, char(),char()}.

gnodes() ->
    non_empty(list(gnode())).

prop_ets_keys() ->
    ?FORALL({Nodes},
            {gnodes()},
            begin
                {ok, ERLOG}   = erlog:new(),
		{ok, ERLOG1}  = erlog:load(erlog_ets,ERLOG),
		TabId = ets:new(test_ets_table, [bag, {keypos,2}]),
		ets:insert(TabId, Nodes),
		lists:all(fun({edge,S,_E})->
				  {{succeed, []},_} = erlog:prove({ets_keys, TabId, S},ERLOG1),
				  true
			  end, Nodes)
		end).


prop_ets_match_all() ->
    ?FORALL({Nodes},
            {gnodes()},
            begin
                {ok, ERLOG}   = erlog:new(),
		{ok, ERLOG1} = erlog:load(erlog_ets,ERLOG),
		TabId = ets:new(test_ets_table, [bag]),
		ets:insert(TabId, Nodes),

		true = lists:all(fun(Edge = {edge,_,_})->
					 {{succeed, []},_}  = erlog:prove({ets_match, TabId, Edge},ERLOG1),
					 true
			  end, Nodes)
		end).

prop_ets_match() ->
    ?FORALL({Nodes},
            {gnodes()},
            begin
                {ok, ERLOG}   = erlog:new(),
		{ok, ERLOG1}  = erlog:load(erlog_ets,ERLOG),
		TabId         = ets:new(test_ets_table, [bag]),
		ets:insert(TabId, Nodes),

                case  erlog:prove( {ets_match, TabId, {'X'}},ERLOG1) of
                    {{succeed,[{'X', M}]},_} -> 
			lists:member(M,Nodes);
                    _R           -> 
			false
                end
            end).

