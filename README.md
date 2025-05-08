# TP1 - Mundo dos blocos

## Equipe
- **Disciplina**: Inteligência Artificial IEC034/ICC265 - 2025/1  
- **Curso**: Ciência/Engenharia da Computação - Turmas CO01 e CB500  

- **Integrantes**:

  - Antonio Mileysson França Bragança - 21850963
  - Jessica de Figueredo Colares - 22060036
  - Lucas Vinícius Gonçalves Gadelha - 22050517

---
## Descrição do Projeto
Este projeto apresenta a implementação de um planejador em Prolog, com base no conceito de manipulação de blocos descrito no Capítulo 17, do livro Prolog *Programming for Artificial Intelligence*, 
 de Ivan Bratko. O objetivo é simular um sistema de planejamento baseado em ações, utilizando lógica de Prolog para mover blocos entre diferentes estados enquanto satisfaz metas definidas. O sistema opera com blocos identificados pelas letras **a, b, c** e **d** , permitindo sua movimentação entre posições numeradas e entre si, de acordo com o estado inicial e os objetivos definidos. 

## Descrição Geral

O projeto implementa um sistema de planejamento no "Mundo dos Blocos", no qual diferentes blocos estão posicionados, com posições livres ou ocupadas. O sistema permite:

- Planejar movimentos de blocos de uma configuração inicial para uma final.
- Executar ações que movem blocos, garantindo que as restrições (como posições livres e pré-condições) sejam respeitadas.
- Verificar se todas as metas foram alcançadas, regredir metas e planejar com base nas pré-condições de ações.

### Regras Básicas do Mundo dos Blocos

- **Estados**: Um estado é uma configuração que descreve onde cada bloco está localizado. Os blocos podem estar sobre o grid em posições únicas ou em pilhas que ocupam múltiplas posições.
- **Ações**: As ações consistem em mover blocos de uma posição para outra, respeitando as pré-condições, como se o bloco está livre para ser movido e se a nova posição está desocupada.
- **Metas**: As metas descrevem o estado final desejado, que pode incluir posições específicas para os blocos ou se um bloco está empilhado sobre outro.

## Estruturas Principais

1. **Estado Inicial**: Define onde cada bloco está no início da execução.

2. **Estado Final**: Define o objetivo final, onde cada bloco deve estar após a execução do plano.

## Funcionamento do Código
O fluxo básico do sistema é o seguinte:
1. **Seleção de Metas**: O sistema primeiro verifica as metas que precisam ser alcançadas.
2. **Planejamento de Ações**: Para cada meta, o sistema seleciona uma ação que possa satisfazê-la, verificando as pré-condições necessárias. Se uma ação não puder ser executada, o sistema regressa as metas e recalcula os passos.
3. **Execução de Ações**: As ações são executadas em sequência, movendo blocos de uma posição para outra. Cada movimento atualiza o estado do mundo dos blocos.

### Exemplo de Execução

Dado o estado inicial:
```prolog
initial_state([
  on(c, p([1,2])),        % c está sobre as posições 1-2 da mesa
  on(a, 4),              % a está sobre a posição 4
  on(b, 6),              % b está sobre a posição 6
  on(d, supports(a,b)),  % d está sobre os blocos a e b
  clear(c),              % c está livre
  clear(d),              % d está livre
  clear(3),              % posição 3 está livre
  clear(5)               % posição 5 está livre
 ]).
```

E o estado final desejado:

```prolog
goal_state([
    on(a, c),               % a está sobre c
    on(d, p([3,4,5])),      % d está sobre as posições 3-5
    on(b, 6),               % b está sobre a posição 6
    clear(a), % a está livre
    clear(b), % b está livre
    clear(d)  % d está livre
]).

```
O sistema gera um plano que moverá os blocos de acordo com as metas definidas. 

## Como Executar

1. Acesse o [SWISH](https://swish.swi-prolog.org/), um ambiente online para Prolog.

2. Coloque os códigos de `blocks_world_definitions.pl`, `blocks_world_actions.pl` e `blocks_world_planner.pl` em um único arquivo, removendo:
```prolog
:- use_module(blocks_world_definitions).
:- use_module(blocks_world_actions).
```

3. Defina o estado inicial e o estado final.

4. Chame o predicado `plan/3`:
  ```prolog
    ?- initial_state(State), goal_state(Goals), plan(State, Goals, Plan).
   ```

5. Aperte o botão `run` para executar o plano.

O sistema gerará e executará o plano de ações necessário para mover os blocos.


## Como Executar no SWI-Prolog

1. Instale o SWI-Prolog no seu computador, se ainda não tiver feito isso. Você pode baixar a versão mais recente no site oficial: [SWI-Prolog Downloads](https://www.swi-prolog.org/Download.html).
2. Após a instalação, abra o terminal (Linux ou macOS) ou o prompt de comando (Windows).
3. Navegue até o diretório onde o seu arquivo .pl (arquivo Prolog) está salvo.
4. Inicie o SWI-Prolog com o comando:

```prolog
swipl
```

Carregue o seu arquivo Prolog utilizando o comando:

```prolog
?- [nome_do_arquivo].
```
No nosso caso, são três arquivos, nessa ordem:

```prolog
?- [blocks_world_definitions].
   [blocks_world_actions].
   [blocks_world_planner].
```

Defina o estado inicial e o estado final e chame o predicado plan/3 para gerar o plano:

```prolog
 ?- initial_state(State), goal_state(Goals), plan(State, Goals, Plan).
```

O sistema calculará o plano de ações necessário para alcançar o estado final a partir do estado inicial.

Há também passos intermediários que podem ser observados:

```prolog
?- initial_state(S0), apply_action(move(c,p([1,2]), d), S0, S1).
```
```prolog
?- initial_state(S0), possible(move(a, 4, c), S0).
```