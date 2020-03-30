%% @author Karl Marklund <karl.marklund@it.uu.se>

-module(tutorial).

-export([hello/0, hello/1,
	 fac/1, fac_tr/1,
	 right_triangles/1,
	 simpsons/0, simpsons/1,
	 char_to_upper/1, char_to_lower/1,
	 str_to_upper/1, str_to_lower/1,
	 max/1, count/2,
	 odd_and_even/1
	]).


%% @doc Prints "Hello!" to the terminal.
-spec hello() -> ok.

hello() ->
    io:format("Hello!~n").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Recursive functions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc Function writing "Hello" N number of times
-spec hello(N::integer()) -> ok.

hello(0) ->
    ok;
hello(N) ->
    io:format("~p Hello!~n", [N]),
    hello(N-1).

%% @doc The factorial function.
%% === Example ===
%% <div class="example">```
%% 25> [{N,tutorial:fac(N)} || N <- lists:seq(0,10)].
%% [{0,1},
%%  {1,1},
%%  {2,2},
%%  {3,6},
%%  {4,24},
%%  {5,120},
%%  {6,720},
%%  {7,5040},
%%  {8,40320},
%%  {9,362880},
%%  {10,3628800}]'''
%% </div>
-spec fac(N::integer()) -> integer().

fac(0) -> 1;
fac(N) -> N*fac(N-1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Tail Recursive functions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc The factorial function, implemented using tail recursion.
-spec fac_tr(N::integer()) -> integer().

fac_tr(N) -> %% Pattern matchingen börjar ju med denna och kallar då sig självt med N, 1
    fac_tr(N,1).

fac_tr(0, Acc) -> %% Om N är 0 så returnas Acc
    Acc;
fac_tr(N, Acc) -> %% Annars denna som då gör den klassiska recursionen, N-1 samtidigt som NewAcc blir N*Acc
    fac_tr(N-1,N*Acc).

%% Den blir tail recursive eftersom vi sparar i en temporär variabel så att vi bara behöver ha två variablar i minnet
%% I en vanlig recursion är vi ju beroende av evaluation av deras andra parter
%% Så 1 + len(rest) behöver resultatet av len(rest) som behöver resultatet av osv osv. Dessa stackas.

%% tail_fac(4)    = tail_fac(4,1)
%% tail_fac(4,1)  = tail_fac(4-1, 4*1)
%% tail_fac(3,4)  = tail_fac(3-1, 3*4)
%% tail_fac(2,12) = tail_fac(2-1, 2*12)
%% tail_fac(1,24) = tail_fac(1-1, 1*24)
%% tail_fac(0,24) = 24

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  List Comprehensions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% @doc Generates a list of tuples {A,B,C} such that A and B are sides
%% in a right triangle with hypotenuse C, where `A,B,C <= N'.
%% === Example ===
%% <div class="example">```
%% > tutorial:right_triangles(10).
%% [{3,4,5},{4,3,5},{6,8,10},{8,6,10}]'''
%% </div>
-spec right_triangles(N) -> [{A,B,C}] when
      N::integer(),
      A::integer(),
      B::integer(),
      C::integer().

right_triangles(N) ->
    L = lists:seq(1, N), %% Gör en lista med en sequence [1,2...,N]
    [{A, B, C} ||  C <- L, 
    A <- L, B <- L, math:pow(A,2) + math:pow(B,2) =:= math:pow(C,2) %% Lägger bara till de som uppfyller predikatet A^2 + B^2 == C^2
    ].

%% Syntax: {2n : n in L} (mängdlära) => 1> [2*N || N <- [1,2,3,4]]. i erlang 

%% @doc Returns a list of tuples, where each tuple describes a caracter in the Simposon family.
%%
%% === Example ===
%% <div class="example">```
%% > tutorial:simpsons().
%% [{person,male,"Bart"},
%%  {cat,female,"Snowball II"},
%%  {person,male,"Homer"},
%%  {person,female,"Lisa"},
%%  {dog,male,"Santa's Little Helper"},
%%  {person,female,"Marge"},
%%  {pig,male,"Spider Pig"}]'''
%% </div>
-spec simpsons() -> [{Type, Gender, Name}] when
      Type::person|cat|dog|pig,
      Gender::male|female,
      Name::string().

simpsons() ->
    [
     {person, male, "Bart"},
     {cat, female, "Snowball II"},
     {person, male, "Homer"},
     {person, female, "Lisa"},
     {dog, male, "Santa's Little Helper"},
     {person, female, "Marge"},
     {pig, male, "Spider Pig"}
    ].

%% @doc Returns a filtered list of names of characters in the Simpson family.
%% === Example ===
%% <div class="example">```
%% > tutorial:simpsons(names).
%% ["Bart","Snowball II","Homer","Lisa",
%%  "Santa's Little Helper","Marge","Spider Pig"]
%% > tutorial:simpsons(females).
%% ["Snowball II","Lisa","Marge"]
%% > tutorial:simpsons(males).
%% ["Bart","Homer","Santa's Little Helper","Spider Pig"]
%% > tutorial:simpsons(pets).
%% ["Snowball II","Santa's Little Helper","Spider Pig"]'''
%% </div>

-spec simpsons(Filter) -> [Name] when
      Filter::names|males|females|pets,
      Name::string().

simpsons(names) ->
    L = simpsons(),
    [Name || {Species, Gender, Name} <- L]; %% Säger att alla ska komma från L som är Simpsons. Alltså alla namn
simpsons(males) ->
    L = simpsons(),
    [Name || {Species, Gender, Name} <- L, Gender == male]; %% Lägger till predikatet att Gender måste vara Male
simpsons(females) ->
    L = simpsons(),
    [Name || {Species, Gender, Name} <- L, Gender == female]; %% Predikatet att Gender måste vara female
simpsons(pets) ->
    L = simpsons(),
    [Name || {Species, Gender, Name} <- L, Species /= person]. %% Predikatet inte person

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Guarded Functions  %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc Convert a character to upper case.
%% === Example ===
%% <div class="example">```
%% > tutorial:char_to_upper($a).
%% 65
%% > tutorial:char_to_upper($@).
%% 64'''
%% </div>
-spec char_to_upper(char()) -> char().
%% Lower char har ascii 97 – 122
char_to_upper(Char) when Char < 97; Char > 122 -> %% Om karaktären är mindre än 97 och större än 122 är det inte lower
    Char;
char_to_upper(Char) -> %% Annars tar vi bort 32 för att få rätt
    Char - 32.

%% @doc Convert a character to lower case.
%% === Example ===
%% <div class="example">```
%% > tutorial:char_to_lower($A).
%% 97
%% > tutorial:char_to_lower($@).
%% 64'''
%% </div>
-spec char_to_lower(char()) -> char().

%% Stora char har ascii 65 - 90

char_to_lower(Char) when Char < 65; Char > 90 -> %% Kollar om inputen är mindre än 65 eller Större än 90, då är det inte upper case så bara att returna
    Char;
char_to_lower(Char) ->
    Char + 32.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Map  %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% HINT: Use the char_to_upper() and char_to_lower().

%% @doc Convert a string to upper case.
%% === Example ===
%% <div class="example">```
%% > tutorial:str_to_upper("Erlang").
%% "ERLANG"'''
%% </div>
-spec str_to_upper(string()) -> string().

str_to_upper(String) ->
   %% [char_to_upper(X) || X <- String].
   lists:map(fun tutorial:char_to_upper/1, String). %% Map kör en function på alla värden (String är en list av ascii-världen)

%% @doc Convert a string to lower case.
%% === Example ===
%% <div class="example">```
%% 7> tutorial:str_to_lower("Upper + Lower").
%% "upper + lower"'''
%% </div>
-spec str_to_lower(string()) -> string().

str_to_lower(String) ->
    lists:map(fun tutorial:char_to_lower/1, String).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Fold %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc Returns the max value M in a list L.
%% === Example ===
%% <div class="example">```
%% 8> tutorial:max([4,-1,8, 0, 3]).
%% 8'''
%% </div>
-spec max(L) -> M when
      L::[integer()],
      M::integer().


   %% What you return in your function F will be the new value of Acc, and eventually the value lists:foldl/3 will return.
   %% Fold bygger upp ett ackumelerat värde genom att köra F på alla i listan. Därför returnar F max av det värdet vi
   %% är på i listan och det tidigare acc. Sen returnar vi det större och kollar detta genom hela.
max([H | T]) ->
    F = fun(L, A) -> max(L, A) end, %% Should be an anon function --> Syntax: fun (arg1,...argn) -> ... end 
    lists:foldl(F, H, T). %% Foldl(Fun, Acc0, List)


%% @doc Returns the number of times Char occurs in String.
%% === Example ===
%% <div class="example">```
%% > tutorial:count("Operating systems and process oriented programming", $p).
%% 3'''
%% </div>

-spec count(String, Char) -> integer() when
    String::string(),
    Char::char().

count(String, Char) ->

%% What you return in your function F will be the new value of Acc, and eventually the value lists:foldl/3 will return.
%% Här startar vi då med acc 0, sedan kör vi med case som kollar om X är samma som Char: returnar Acc + 1
%% Annars går vi bara vidare
    F = fun(X, A) -> case X of
                        Char -> A+1;
                        _ -> A end
                        end,

    lists:foldl(F, 0, String).


%% @doc Returns a tuple {{odd, Odd}, {even, Even}} where Odd and Even
%% are lists with all the odd and even numbers in List.
%% === Example ===
%% <div class="example">```
%% > tutorial:odd_and_even(lists:seq(1,10)).
%% {{odd,[9,7,5,3,1]},{even,[10,8,6,4,2]}}'''
%% </div>
-spec odd_and_even(List) -> {{odd, Odd},{even, Even}} when
      List::[integer()],
      Odd::[integer()],
      Even::[integer()].

odd_and_even(List) ->
    F = fun(X, {{odd, Odd}, {even, Even}}) when X rem 2 == 0 -> %% JÄMNT
                {{odd, Odd}, {even, [X | Even]}}; %% Lägger ju då bara till X som huvudet på tailen Even :D
            (X, {{odd, Odd}, {even, Even}})  ->  %% Annars är det ju udda
                {{odd, [X | Odd]}, {even, Even}} %% Lägger då bara till X som huvudet på ODd
        end,

    lists:foldl(F, {{odd, []}, {even, []}}, List). %% Acc är alltså en tuple här 
