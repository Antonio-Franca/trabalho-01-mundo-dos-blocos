%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blocks_world_planner.pl                         
% Planejador regressivo para o mundo dos blocos
% Data: Maio/2025
% Adaptado de:  Prolog Programming for AI, Ivan Bratko, 4th edition
%          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blocks_world_planner.pl   
:- use_module(blocks_world_definitions).
:- use_module(blocks_world_actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plan(+State, +Goals, -Plan)
% Gera um plano para alcançar os objetivos a partir do estado atual
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Passo recursivo: seleciona uma ação que ajuda a alcançar um objetivo
plan(State, Goals, []) :-
    satisfied(State, Goals), !.

plan(State, Goals, Plan) :-
    select(Goal, Goals, _),
    achieves(Action, Goal),
    preserves(Action, Goals),
    can(Action, Preconditions),
    satisfied(State, Preconditions),
    regress(Goals, Action, NewGoals),
    plan(State, NewGoals, PrePlan),
    append(PrePlan, [Action], Plan).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% satisfied(+State, +Goals)
% Verifica se todos os objetivos estão satisfeitos no estado atual
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

satisfied(_, []).
satisfied(State, [Goal|Goals]) :-
    member(Goal, State),
    satisfied(State, Goals).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% satisfied(+State, +Goals)
% Verifica se todos os objetivos estão satisfeitos no estado atual
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

satisfied(_, []).
satisfied(State, [Goal|Goals]) :-
    member(Goal, State),
    satisfied(State, Goals).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select(+Goal, +Goals, -RestGoals)
% Seleciona um objetivo da lista
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

select(Goal, [Goal|Rest], Rest).
select(Goal, [H|T], [H|Rest]) :-
    select(Goal, T, Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% achieves(+Action, +Goal)
% Verifica se uma ação adiciona o objetivo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
achieves(Action, Goal) :-
    adds(Action, Added),
    member(Goal, Added),
    % Garante que a ação é relevante para o goal específico
    ( Goal = on(Block,_) -> 
        Action = move(Block, _, _)
    ; true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preserves(+Action, +Goals)
% Garante que a ação não apague nenhum objetivo ainda não alcançado
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A ação preserva os objetivos se nenhum fato deletado está nos objetivos
preserves(Action, Goals) :-
    deletes(Action, Deletes),
    \+ (member(F, Deletes), member(F, Goals)),
    \+ (member(F, Deletes), impossible(F, Goals)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% regress(+Goals, +Action, -RegressedGoals)
% Retorna os objetivos anteriores após aplicar a ação em reverso
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
regress(Goals, Action, RegressedGoals) :-
    adds(Action, Added),
    deletes(Action, Deleted),
    subtract(Goals, Added, RestGoals),
    append(Deleted, RestGoals, TentativeGoals),
    sort(TentativeGoals, RegressedGoals),
    % Nova linha: filtra estados impossíveis
    \+ (member(Fact, RegressedGoals), impossible(Fact, [])).