%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % blocks_world_actions.pl                          
% Definições das ações e pré-condições do mundo dos blocos 
% Data: Maio/2025          
% Adaptado de:  Prolog Programming for AI, Ivan Bratko, 4th edition
%          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(blocks_world_definitions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 1. Mover bloco de uma posição da mesa para outro bloco
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
can(move(Block, From, To), Pre) :-
    % Verificação estrutural primeiro
    block(Block), block(To),
    dif(Block, To),  % Garante que são diferentes desde o início
    nonvar(From), From = p([X,Y]),
    X < Y, place(X), place(Y),
    % Pré-condições
    Pre = [clear(Block), clear(To), on(Block, From)],
    % Verificação de tamanho
    size(Block, Sb), size(To, St),
    Sb =< St + 2.    % Permite diferença de até 2 unidades

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 2. Mover bloco de um bloco para outro bloco
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
can(move(Block, From, To), Pre) :-
    block(Block), block(From), block(To),
    dif(Block, From), dif(Block, To), dif(From, To),
    Pre = [clear(Block), clear(To), on(Block, From)],
    size(Block, Sb), size(To, St),
    Sb =< St + 2.

% 2.1 Caso especial para supports(a,b)
can(move(Block, supports(A,B), To), Pre) :-
    block(Block), block(To),
    dif(Block, To),
    Pre = [clear(Block), clear(To), on(Block, supports(A,B))],
    size(Block, Sb), size(To, St),
    Sb =< St + 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 3. Mover bloco de um bloco com suporte múltiplo para outro bloco
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
can(move(Block, FromBlock, ToPlace), [clear(Block), on(Block, FromBlock)]) :-
    block(Block),
    (block(FromBlock) ; FromBlock = supports(_,_)),
    nonvar(ToPlace), ToPlace = p([X,Y]),
    integer(X), integer(Y), X < Y,
    place(X), place(Y),
    size(Block, S_b),
    S_b =:= Y - X + 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 4. Mover bloco de um bloco para a mesa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
can(move(Block, FromBlock, ToPlace), [clear(Block), on(Block, FromBlock)]) :-
    block(Block),
    block(FromBlock),
    dif(Block, FromBlock),
    nonvar(ToPlace),  % Garante instanciação
    ToPlace = p([X, Y]),
    integer(X), integer(Y), X < Y,  % Verificação segura
    place(X), place(Y),
    size(Block, S_b),
    S_b =:= Y - X + 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 5. Mover bloco da mesa para outra posição da mesa 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
can(move(Block, FromPlace, ToPlace), [clear(Block), on(Block, FromPlace)]) :-
    block(Block),
    nonvar(FromPlace), nonvar(ToPlace),  % Garante instanciação
    FromPlace = p([Xi, Yi]),
    ToPlace = p([Xf, Yf]),
    integer(Xi), integer(Yi), integer(Xf), integer(Yf),  % Verificação de tipos
    Xi < Yi,
    Xf < Yf,
    \+ (Xi =:= Xf, Yi =:= Yf),
    size(Block, S_b),
    S_b =:= Yf - Xf + 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicado auxiliar: position_clear(X, Y, State)
% Verifica se todas as posições entre X e Y estão marcadas como clear/1 no estado.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
position_clear(X, Y, State) :-
    between(X, Y, P),
    (place(P); true),
    member(clear(P), State),
    !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicado auxiliar: block_clear(X, State)
% Verifica se um bloco está livre (clear(X) está no estado).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
block_clear(X, State) :-
    block(X),
    member(clear(X), State).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicado auxiliar: possible(Action, State) 
% Verifica se é possível o movimento.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
possible(Action, State) :-
    can(Action, Preconditions),
    forall(member(P, Preconditions), member(P, State)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definição dos efeitos das ações (adds/2 e deletes/2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% adds(Action, NewFacts) - o que entra no estado após a ação
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
adds(move(Block, p([X,Y]), To), [on(Block, To), clear(p([X,Y]))]).
adds(move(Block, From, To), [on(Block, To), clear(From)]).
adds(move(Block, supports(A,B), To), [on(Block, To), clear(supports(A,B))]).
adds(move(Block, From, p([X,Y])), [on(Block, p([X,Y])), clear(From)]).
adds(move(Block, p([Xi,Yi]), p([Xf,Yf])), [on(Block, p([Xf,Yf])), clear(Xi), clear(Yi)]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deletes(Action, OldFacts) - o que sai do estado após a ação
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deletes(move(Block, p([X,Y]), To), [on(Block, p([X,Y])), clear(To)]).
deletes(move(Block, From, To), [on(Block, From), clear(To)]).
deletes(move(Block, From, p([X,Y])), [on(Block, From), clear(X), clear(Y)]).
deletes(move(Block, supports(A,B), To), [on(Block, supports(A,B)), clear(To)]).
deletes(move(Block, p([Xi,Yi]), p([Xf,Yf])), [on(Block, p([Xi,Yi])), clear(Xf), clear(Yf)]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicado auxiliar: apply_action/3 e remove_all
% Aplica a ação e remove elementos de uma lista, 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
remove_all([], _, []).
remove_all([H|T], Remove, Result) :-
    (member(H, Remove) -> Result = R ; Result = [H|R]),
    remove_all(T, Remove, R).

apply_action(Action, StateIn, StateOut) :-
    adds(Action, Added),
    deletes(Action, Deleted),
    remove_all(StateIn, Deleted, TempState),
    append(Added, TempState, StateOut).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      
% Regras de integridade do mundo dos blocos
% impossible: impede estados inválidos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% (2) Um bloco não pode estar sobre si mesmo
impossible(on(Block, Block), _) :- !.

% (1) Bloco não pode estar em múltiplos lugares diferentes
impossible(on(Block, _), Goals) :-
    findall(P, member(on(Block, P), Goals), Ps),
    sort(Ps, Sorted),
    length(Sorted, L), L > 1.

% (3) Dois blocos não podem estar na mesma posição exata
impossible(on(B1, Pos), Goals) :-
    member(on(B2, Pos), Goals),
    dif(B1, B2).

% (4) Uma posição não pode estar 'clear' se houver algo sobre ela
impossible(clear(P), Goals) :-
    member(on(_, P), Goals).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicado auxiliar: overlap/2 - verifica se duas faixas se sobrepõem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
overlap(p([X1,Y1]), p([X2,Y2])) :-
    X1 =< Y2,
    X2 =< Y1.