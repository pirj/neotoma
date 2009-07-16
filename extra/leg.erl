-module(leg).
-export([parse/1,file/1]).
-include_lib("neotoma/include/peg.hrl").

rule(grammar) ->
  peg:seq([peg:optional(fun space/2), peg:label('head', fun row/2), peg:label('tail', peg:zero_or_more(peg:seq([fun space/2, fun row/2])))]);

rule(row) ->
  peg:seq([fun atom/2, peg:optional(fun space/2), peg:string("="), peg:optional(fun space/2), fun value/2]);

rule(value) ->
  peg:choose([fun array/2, fun dict/2, fun simple/2]);

rule(simple) ->
  peg:choose([fun number/2, fun atom/2]);

rule(array) ->
  peg:seq([peg:string("["), peg:optional(fun space/2), peg:label('array', peg:seq([peg:label('head', fun simple/2), peg:label('tail', peg:zero_or_more(peg:seq([peg:string(","), peg:optional(fun space/2), fun simple/2])))])), peg:optional(fun space/2), peg:string("]")]);

rule(dict) ->
  peg:seq([peg:string("{"), peg:optional(fun space/2), peg:label('dict', peg:seq([peg:label('head', fun pair/2), peg:label('tail', peg:zero_or_more(peg:seq([peg:string(","), peg:optional(fun space/2), fun pair/2])))])), peg:optional(fun space/2), peg:string("}")]);

rule(pair) ->
  peg:seq([fun atom/2, peg:optional(fun space/2), peg:string(":"), peg:optional(fun space/2), fun simple/2]);

rule(number) ->
  peg:choose([peg:seq([fun non_zero_digit/2, peg:one_or_more(fun digit/2)]), fun digit/2]);

rule(atom) ->
  peg:one_or_more(peg:charclass("[a-z]"));

rule(non_zero_digit) ->
  peg:charclass("[1-9]");

rule(digit) ->
  peg:charclass("[0-9]");

rule(space) ->
  peg:zero_or_more(peg:charclass("[ \t\n\s\r]")).

% Transforms
transform(dict, Node, _Index) -> lists:nth(3, Node);

transform(array, Node, _Index) -> lists:nth(3, Node);

transform(row, Node, _Index) -> {lists:nth(1, Node), lists:nth(5, Node)};



transform(_,Node,_Index) -> Node.