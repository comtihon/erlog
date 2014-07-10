-module(erlog_lists_tests).
-include_lib("eqc/include/eqc.hrl").
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

prop_append_lists() ->
    ?FORALL(
       {A,B},
       {list(int()), list(int())},
       begin
           Term      = {append,A,B,{'Z'}},
           {ok, E}    = erlog:start_link(),
           case  E({prove,Term}) of
               {{succeed, [{'Z', Z}]},E1} when is_function(E1) ->
                   Z =:= lists:append(A,B);
               fail ->
                   false
           end
       end).


prop_append_list() ->
    ?FORALL(
       L,
       list(int()),
       begin
           Term = {append,{'A'},{'B'},L},
           {ok, E}    = erlog:start_link(),
           case  erlog:prove(E,Term) of
               {{succeed, [{'A', A},
                          {'B', B}]},E1} when is_function(E1) ->
                   L =:= lists:append(A,B);
               fail ->
                   false
           end
       end).


prop_reverse_list() ->
    ?FORALL(L, list(int()),
            begin
                Term      =  {reverse,L,{'Y'}},
                {ok, E}    = erlog:start_link(),
                case  erlog:prove(E,Term) of
                    {{succeed, [{'Y', Y}]},_E1} ->
                        L =:= lists:reverse(Y);
                    fail ->
                        false
                end
            end).



prop_reverse_list_valid() ->
    ?FORALL(L, list(int()),
            begin
                Term =  {reverse,L,lists:reverse(L)},
                {ok, PID} = erlog:start_link(),
                case  erlog:prove(PID,Term) of
                    {succeed, _} ->
                        true;
                    fail ->
                        false
                end
            end).


prop_reverse_list_invalid() ->
    ?FORALL(L, non_empty(list(int())),
            begin
                Term =  {reverse, [1|L], lists:reverse(L)},
                {ok, PID} = erlog:start_link(),
                case  erlog:prove(PID,Term) of
                    {succeed, _} ->
                        false;
                    fail ->
                        true
                end
            end).


prop_last_list() ->
    ?FORALL(L,
            non_empty(list(int())),
            begin
                Term =  {last, lists:last(L),L},
                {ok, PID} = erlog:start_link(),
                case  erlog:prove(PID,Term) of
                    {succeed, _} ->
                        false;
                    fail ->
                        true
                end
            end).

prop_member_list() ->
    ?FORALL({M,L,C},
            {int(), list(int()), oneof([member, memberchk])},
            begin
                Term =  {C, M, L},
                {ok, PID} = erlog:start_link(),
                case  erlog:prove(PID,Term) of
                    {succeed, _} ->
                        lists:member(M,L);
                    fail ->
                        not(lists:member(M,L))

                end

            end).

prop_sort_list1() ->
    ?FORALL({L},
            { list(int())},
            begin
                Term =  {sort, L, {'Sort'}},
                {ok, PID} = erlog:start_link(),
                case  erlog:prove(PID,Term) of
                    {succeed, [{'Sort', Sort}]} ->
			lists:usort(L) =:= Sort;
                    fail ->
			false
                end
            end).

prop_sort_list2() ->
    ?FORALL({L},
            { list(int())},
            begin
                Term =  {sort, L, lists:usort(L)},
                {ok, PID} = erlog:start_link(),
                case  erlog:prove(PID,Term) of
                    {succeed, _} ->
			true;
                    fail ->
			false
                end
            end).


