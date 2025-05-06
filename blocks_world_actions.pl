%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blocks_world_actions.pl                         
% Definição das ações can/2,adds/2, deletes/2, imposible/2 para o mundo dos blocos
% Data: Maio/2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(blocks_world_definitions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Mover bloco de uma posição da mesa para outro bloco
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
can(move(Block, FromPlace, ToBlock), [clear(Block), clear(ToBlock), on(Block, FromPlace)]) :-
    block(Block),
    block(ToBlock),
    Block \== ToBlock,
    FromPlace = p([X, Y]),     % Bloco está sobre uma faixa da mesa
    place(X),
    place(Y),
    X < Y,
    size(Block, S_b),
    size(ToBlock, S_t),
    S_b - S_t =< 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Mover bloco de um bloco para outro bloco
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
can(move(Block, FromBlock, ToBlock), [clear(Block), clear(ToBlock), on(Block, FromBlock)]) :-
    block(Block),
    block(FromBlock),
    block(ToBlock),
    Block \== FromBlock,
    Block \== ToBlock,
    FromBlock \== ToBlock,
    size(Block, S_b),
    size(ToBlock, S_t),
    S_b - S_t =< 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Mover bloco de um bloco para outro bloco que esteja apoiado em outro bloco
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
can(move(Block, FromBlock, ToBlock), [clear(Block), clear(ToBlock), on(Block, FromBlock)]) :-
    block(Block),
    (block(FromBlock) ; FromBlock = supports(_, _)),  % permite apoio múltiplo
    block(ToBlock),
    Block \== FromBlock,
    Block \== ToBlock,
    FromBlock \== ToBlock,
    size(Block, S_b),
    size(ToBlock, S_t),
    S_b - S_t =< 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Mover bloco de um bloco para a mesa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
can(move(Block, FromBlock, ToPlace), [clear(Block), on(Block, FromBlock)]) :-
    block(Block),
    block(FromBlock),
    Block \== FromBlock,
    ToPlace = p([X, Y]),
    place(X),
    place(Y),
    X < Y,
    size(Block, S_b),
    S_b is Y - X + 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Mover bloco da mesa para outra posição da mesa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
can(move(Block, FromPlace, ToPlace), [clear(Block), on(Block, FromPlace)]) :-
    block(Block),
    FromPlace = p([Xi, Yi]),
    ToPlace = p([Xf, Yf]),
    Xi < Yi,
    Xf < Yf,
    Xi \== Xf,
    Yi \== Yf,
    size(Block, S_b),
    S_b is Yf - Xf + 1.

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

% Um bloco não pode estar em dois lugares ao mesmo tempo
impossible(on(Block, Place1), Goals) :-
    member(on(Block, Place2), Goals),
    Place1 \== Place2.

% Um bloco não pode estar sobre si mesmo
impossible(on(Block, Block), _).

% Dois blocos não podem ocupar as mesmas posições da mesa
impossible(on(Block1, p([X1,Y1])), Goals) :-
    member(on(Block2, p([X2,Y2])), Goals),
    Block1 \== Block2,
    overlap(p([X1,Y1]), p([X2,Y2])).

% Uma posição não pode estar 'clear' se houver um bloco sobre ela
impossible(clear(P), Goals) :-
    member(on(_, P), Goals)
    ;
    (member(on(_, p([X,Y])), Goals), between(X, Y, P)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicado auxiliar: overlap/2 - verifica se duas faixas se sobrepõem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
overlap(p([X1,Y1]), p([X2,Y2])) :-
    X1 =< Y2,
    X2 =< Y1.