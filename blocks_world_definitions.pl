%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blocks_world_definitions.pl                         
% Definições do mundo dos blocos 
% Data: Maio/2025          
% Adaptado de:  Prolog Programming for AI, Ivan Bratko, 4th edition
%          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------
% 1. Definições básicas do mundo
%----------------------------------------------
% Blocos disponíveis
block(a).
block(b).
block(c).
block(d).

% Blocos e seus tamanhos (unidades de comprimento)
size(a, 1).  % Bloco 'a' ocupa 1 unidade
size(b, 1).  % Bloco 'b' ocupa 1 unidade
size(c, 2).  % Bloco 'c' ocupa 2 unidades
size(d, 3).  % Bloco 'd' ocupa 3 unidades

% Posições disponíveis (eixos X=1..6)
place(1). place(2). place(3). place(4). place(5). place(6).

%----------------------------------------------
% 2. Estados iniciais 
%----------------------------------------------

% Posicionamento inicial dos blocos descrito para o trabalho
%              d d d
%    	 c c   a   b
%    	 -----------
% place  1 2 3 4 5 6

% Estado inicial - Cada bloco tem apenas um local
initial_state([
    on(c, p([1,2])),         % c está sobre as posições 1-2 da mesa
    on(a, 4),                % a está sobre a posição 4
    on(b, 6),                % b está sobre a posição 6
    on(d, supports(a,b)),    % d está sobre os blocos a e b
    clear(c),                % c está livre
    clear(d),                % d está livre
    clear(3),                % posição 3 está livre
    clear(5)                 % posição 5 está livre
]).

%----------------------------------------------
% 2. Estado final   
%----------------------------------------------
% Posicionamento final dos blocos descrito para o trabalho
%        a    
%    	 c c d d d b
%    	 -----------
% place  1 2 3 4 5 6
goal_state([
    on(a, c),               % a está sobre c
    on(d, p([3,4,5])),      % d está sobre as posições 3-5
    on(b, 6),               % b está sobre a posição 6
    clear(a), % a está livre
    clear(b), % b está livre
    clear(d)  % d está livre
]).