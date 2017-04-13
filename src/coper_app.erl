%%%-------------------------------------------------------------------
%% @doc coper public API
%% @end
%%%-------------------------------------------------------------------

-module(coper_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([get_props_for_github_user/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    coper_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

get_props_for_github_user(Username) ->
  {ok, {{_, 200, _}, _, Body}} = httpc:request(get, {"https://api.github.com/users/" ++ Username, [
    {"User-Agent", "Mozilla/5.0"}
  ]}, [], []),

  PropsList = jsx:decode(list_to_binary(Body)),
  IdTuple = lists:keyfind(<<"id">>, 1, PropsList),
  CreatedAtTuple = lists:keyfind(<<"created_at">>, 1, PropsList),
  TypeTuple = lists:keyfind(<<"type">>, 1, PropsList),

  output_if_exists(IdTuple),
  output_if_exists(CreatedAtTuple),
  output_if_exists(TypeTuple).

output_if_exists(TupleOrBool) ->
  if
    is_tuple(TupleOrBool) ->
      io:format("  ~p -> ~p.~n", lists:map(fun convert_bin_to_list/1, tuple_to_list(TupleOrBool)));
    true ->
      io:format("Key not present.~n")
  end.

convert_bin_to_list(Item) -> case is_binary(Item) of true -> binary_to_list(Item); _ -> Item end.
