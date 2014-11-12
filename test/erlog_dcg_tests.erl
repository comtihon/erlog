-module(erlog_dcg_tests).
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
-compile(export_all).
-include("erlog_test.hrl").

finite_dcg_test() ->
    {ok, ERLOG_STATE}		= erlog:new(),
    {ok, ERLOG_STATE1}		= erlog:consult("../test/finite_dcg.pl",ERLOG_STATE),
    {{succeed,_},ERLOG_STATE2}	= erlog:prove({s,[the,woman,shoots,the,man],[]},ERLOG_STATE1),
    {{succeed,_},ERLOG_STATE3}	= erlog:prove({s,[the,man,shoots,a,man],[]},ERLOG_STATE2),
    case erlog:prove( {s, {'X'},[]},ERLOG_STATE3) of
	{{succeed, [{'X',List}]},_ERLOG_STATE4} ->
	    ?assertEqual([the,woman,shoots,the,woman], List);
	fail ->
	    false
    end.


