:- encoding(utf8).
:- set_prolog_flag(encoding, utf8).

% IST1118678 Pedro Maria Vilhena Almeida
:- style_check(-discontiguous). % para nao se queixar descontinuidade da BD
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas          
:- ['codigoAuxiliar.pl']. % Ficheiro dado
:- ['bd_estudantes.pl']. % Ficheiro dado
:- ['listas_palavras.pl']. % Ficheiro dado
% O teu código deve começar na próxima linha

/*
Executar testes públicos:

["testes_publicos.plt"].
run_tests.
47/47 testes passados
*/

/*
Parte 1: Manipulação de bases de conhecimento sobre a base de dados.
Aqui são implementados predicados para calcular a média, frequências e alertas,
de acordo com a base de dados fornecida.

Estrutura da BD:
estudante(IdAluno, Idade, Genero).
atividade(IdAluno, AbsentismoNãoJustificado, Atrasos, Frequencia).
saude(IdAluno, HorasSono, EstadoGeral, MinSono, MaxSono).
exame(IdAluno, Nota).

Calcula a média aritmética de uma lista de valores numéricos,
arredondando para duas casas decimais.
Trata o caso de lista vazia retornando 0.
*/
media([], 0):- !.
media(Lista, Media):-
    sum_list(Lista, Soma),
    length(Lista, N),
    N > 0,
    Media is round(Soma / N * 100) / 100.

%Função auxiliar para somar elementos de uma lista de forma recursiva
soma([], 0).
soma([Cabeca|Cauda], Total):-
    soma(Cauda, Subtotal),
    Total is Cabeca + Subtotal.

%Função auxiliar para calcular o comprimento de uma lista de forma recursiva.
comprimento([], 0).
comprimento([_|Cauda], N):-
    comprimento(Cauda, N1),
    N is N1 + 1.


/*
Calcula a média das notas dos alunos dentro de um intervalo de idades específico.
Usa findall para coletar notas relevantes e depois aplica a média.
*/
mediaNotasPorIdade(IdadeMin, IdadeMax, Media):-
    findall(Nota,
            (estudante(IdAluno, Idade, _),
             Idade > IdadeMin,
             Idade =< IdadeMax,
             exame(IdAluno, Nota)),
            ListaNotas),
    media(ListaNotas, Media).


/*
Calcula a média da frequência às aulas para alunos de um género específico.
Coleta as frequências com findall e computa a média.
*/
freqPorGenero(Genero, MediaFreq):-
    findall(Freq,
            (estudante(IdAluno, _, Genero),    
             atividade(IdAluno, _, _, Freq)),
            ListaFreq),
    media(ListaFreq, MediaFreq).

%Estados qualitativos de alimentação para valores numéricos para facilitar comparações.
estadoParaNumero(fraca, 1).
estadoParaNumero(razoavel, 2).
estadoParaNumero(boa, 3).

/*
Identifica alunos em risco de saúde com base em critérios de sono,
exercício e saúde mental.
Coleta IDs com findall, filtra por alimentação fraca e ordena a lista final.
*/
alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos):-
    findall(IdAluno,
            (saude(IdAluno, HorasSonoReal, EstadoGeral, MinSono, MaxSono),
             estadoParaNumero(EstadoGeral, Nivel),
             HorasSonoReal < HorasSono,
             MinSono < Exercicio, 
             Nivel == 1,
             MaxSono < SaudeMental),
            ListaDesordenada),
    sort(ListaDesordenada, ListaAlunos).


/*
Calcula a probabilidade condicional de notas altas dado tempo excessivo em ecrãs.
Usa contagens de alunos que satisfazem condições A e B, arredondando o resultado.
*/
probEcraNotasAltas(HorasEcra, Nota, Probabilidade):-
    % Conta alunos com Atrasos > HorasEcra E nota > Nota
    findall(IdAluno,
            (atividade(IdAluno, _, Atrasos, _),
             exame(IdAluno, NotaExame),
             Atrasos > HorasEcra,
             NotaExame > Nota),
            AlunosAB),
    comprimento(AlunosAB, NumAB),
    
    % Conta alunos com Atrasos > HorasEcra
    findall(IdAluno,
            (atividade(IdAluno, _, Atrasos, _),
             Atrasos > HorasEcra),
            AlunosB),
    comprimento(AlunosB, NumB),
    
    % Calcula probabilidade
    (NumB > 0 ->
        Temp is NumAB / NumB * 100,
        Probabilidade is round(Temp) / 100
    ;
        Probabilidade is 0
    ).

%-------------------o Coeficiente de Correlação de Pearson-----------------------%

/*
Secção para o cálculo do coeficiente de correlação de Pearson.
Implementa funções auxiliares para desvios, soma de quadrados e produto escalar.

Subtrai um valor constante de cada elemento de uma lista: gera uma nova lista.
*/
subtraiValorDeLista([], _, []).
subtraiValorDeLista([Cabeca|Cauda], Valor, [NovaCabeca|NovaCauda]):-
    NovaCabeca is Cabeca - Valor,
    subtraiValorDeLista(Cauda, Valor, NovaCauda).

%Soma os quadrados dos elementos de uma lista de forma recursiva
somaQuadrados([], 0).
somaQuadrados([Cabeca|Cauda], Total):-
    somaQuadrados(Cauda, Subtotal),
    Total is Subtotal + Cabeca * Cabeca.

%Calcula o produto escalar entre duas listas de mesmo tamanho
produtoEscalar([], [], 0).
produtoEscalar([Cabeca1|Cauda1], [Cabeca2|Cauda2], Resultado) :-
    produtoEscalar(Cauda1, Cauda2, Resto),
    Resultado is Cabeca1 * Cabeca2 + Resto.

/*
Computa a correlação de Pearson entre duas listas, usando médias, 
desvios e fórmulas matemáticas.
Arredonda para duas casas decimais e verifica condições como tamanhos iguais.
*/
correlacao(Xs, Ys, R) :-
    comprimento(Xs, N),
    comprimento(Ys, N),
    N > 1,
    media(Xs, MediaX),
    media(Ys, MediaY),
    subtraiValorDeLista(Xs, MediaX, DesviosX),
    subtraiValorDeLista(Ys, MediaY, DesviosY),
    produtoEscalar(DesviosX, DesviosY, Numerador),
    somaQuadrados(DesviosX, SomaQuadX),
    somaQuadrados(DesviosY, SomaQuadY),
    Denominador is sqrt(SomaQuadX) * sqrt(SomaQuadY),
    Denominador > 0,
    Rtemp is Numerador / Denominador,
    R is round(Rtemp * 100) / 100.

%---------------------------WORDLE-------------------------------%
/*
Parte 2: Implementação de um jogo parecido com o Wordle
Predicados para manipulação de palavras, contagens e geração de pistas
*/


%Determina o tamanho de uma palavra, trata tanto atoms como strings
tamanho(Palavra, Tamanho):-
    atom(Palavra), !,
    atom_length(Palavra, Tamanho).
tamanho(Palavra, Tamanho):-
    string(Palavra), !,
    atom_string(Atomo, Palavra),
    atom_length(Atomo, Tamanho).

%Verifica se duas palavras têm o mesmo tamanho e converte-as em listas de caracteres.
verificaECalcula("", "", [], []).
verificaECalcula(Palavra1, Palavra2, Caracteres1, Caracteres2):-
    tamanho(Palavra1, Tam),
    tamanho(Palavra2, Tam),% se tam for diferente que o tamanho da palavra2, vai falhar
    string_chars(Palavra1, Caracteres1),
    string_chars(Palavra2, Caracteres2).

%Conta quantas palavras em uma lista têm um tamanho específico 
quantasN(Id, N, Quantas):-
    lista_palavras(Id, Lista),
    findall(Palavra, (
            member(Palavra, Lista),% member é pra verificar se 1 Elem pertence a uma lst 
            tamanho(Palavra, N)
           ), PalavrasComTamanhoN),
    length(PalavrasComTamanhoN, Quantas).

%Conta quantas palavras em uma lista começam com um caractere específico.
quantasC(Id, C, Quantas):-
    lista_palavras(Id, Lista),
    findall(Palavra, (
            member(Palavra, Lista),
            string_chars(Palavra, [C | _])),
            PalavrasQueComecamComC),
    length(PalavrasQueComecamComC, Quantas).

%Remove a primeira ocorrência de um elemento de uma lista, mantendo o resto
apagaElemento(_, [], []):- !.
apagaElemento(Elem, [Elem|Cauda], Cauda):- !.
apagaElemento(Elem, [Cabeca|Cauda], [Cabeca|ResultadoCauda]):-
    Elem \= Cabeca,   
    apagaElemento(Elem, Cauda, ResultadoCauda).

%Gera uma lista ordenada de pares (letra, posição) para os caracteres de uma palavra
posicoesPalavra(Palavra, Posicoes):-
    string_chars(Palavra, Lista),
    findall((Letra, Pos),
            geraParesPos(Lista, Letra, Pos),
            Pares),
    sort(Pares, Posicoes).

%Auxiliar recursivo para gerar pares de posição e letra, começando da posição 1.
geraParesPos([Letra|_], Pos, Letra, Pos).
geraParesPos([_|Resto], Pos, Letra, PosFinal):-
    Pos1 is Pos + 1,
    geraParesPos(Resto, Pos1, Letra, PosFinal).

geraParesPos(Lista, Letra, Pos):-
    geraParesPos(Lista, 1, Letra, Pos).


/*-----------------------------PISTAS----------------------------------*/

%Gera pista1: 2 para letras na posição correta, 0 caso contrário.
pista1(Palavra1, Palavra2, Pista):-
    atom(Palavra1),
    atom(Palavra2), !,
    string_chars(Palavra1, Lista1),
    string_chars(Palavra2, Lista2),
    length(Lista1, T1),
    length(Lista2, T2),
    T1 =:= T2,  % Falha se tamanhos diferentes
    pista1_aux(Lista1, Lista2, Pista).

% Auxiliar recursivo para comparar listas caractere a caractere na pista 1
pista1_aux([], [], []):- !.
pista1_aux([Cabeca1|Pal1], [Cabeca2|Pal2], [2|PistaResto]):-
    Cabeca1 == Cabeca2, !, 
    pista1_aux(Pal1, Pal2, PistaResto).
pista1_aux([Cabeca1|Pal1], [Cabeca2|Pal2], [0|PistaResto]):-
    Cabeca1 \== Cabeca2,
    pista1_aux(Pal1, Pal2, PistaResto).


%Gera pista de existência: 2 posição correta, 1 existe mas errada, 0 inexistente.        
pista2(Palavra1, Palavra2, Pista) :-
    % Converter para listas de caracteres
    (atom(Palavra1) -> atom_chars(Palavra1, ListaSecreta) ;
     string_chars(Palavra1, ListaSecreta)),
    (atom(Palavra2) -> atom_chars(Palavra2, Palpite) ;
     string_chars(Palavra2, Palpite)),
    length(ListaSecreta, T1),
    length(Palpite, T2),
    T1 =:= T2, % Verificar se têm o mesmo tamanho
    % Obter pista base (2 para corretos, 0 para incorretos)
    pista1_aux(ListaSecreta, Palpite, PistaBase),
    % Para cada posição, se é 0, verifica se a letra existe na palavra secreta
    pista2_aux(Palpite, ListaSecreta, PistaBase, Pista).

% Auxiliar para pista2 - simplesmente verifica se cada letra existe na palavra secreta
pista2_aux([], _, [], []):-!.
% Se já é 2 (posição correta), mantém 2
pista2_aux([_|RestoPalpite], ListaSecreta, [2|RestoPistaBase], [2|RestoPista]) :- !,
    pista2_aux(RestoPalpite, ListaSecreta, RestoPistaBase, RestoPista).
% Se é 0, verifica se a letra existe algures na palavra secreta (sem remover)
pista2_aux([Letra|RestoPalpite], ListaSecreta, [0|RestoPistaBase], [Valor|RestoPista]) :-
    (member(Letra, ListaSecreta) -> Valor = 1 ; Valor = 0),
    pista2_aux(RestoPalpite, ListaSecreta, RestoPistaBase, RestoPista).


%Gera pista avançada: considera contagens de letras para evitar falsos positivos em duplicatas
pista3(Palavra1, Palavra2, Pista):-
    % Converter para listas de caracteres
    (atom(Palavra1) -> atom_chars(Palavra1, ListaSecreta) ;
     string_chars(Palavra1, ListaSecreta)),
    (atom(Palavra2) -> atom_chars(Palavra2, Palpite) ; string_chars(Palavra2, Palpite)),
    length(ListaSecreta, T1),
    length(Palpite, T2),
    T1 =:= T2,
    % Obter pista base (2 para corretos, 0 para incorretos)
    pista1_aux(ListaSecreta, Palpite, PistaBase),
    % Remover da secreta as letras já na posição correta
    remove_letras_corretas(ListaSecreta, PistaBase, SecretaRestante),
    pista3_aux(Palpite, SecretaRestante, PistaBase, Pista).

% Remove letras já corretas da lista secreta para contagem precisa
remove_letras_corretas([], [], []):- !.
remove_letras_corretas([_|Cs], [2|Ps], Resto) :- !,
    remove_letras_corretas(Cs, Ps, Resto).
remove_letras_corretas([C|Cs], [0|Ps], [C|Resto]) :-
    remove_letras_corretas(Cs, Ps, Resto).

% Processa pista 3 removendo ocorrências usadas para letras erradas.
pista3_aux([], _, [], []):- !.
% Se já é 2 (posição correta), mantém 2
pista3_aux([_|RestoPalpite], SecretaRestante, [2|RestoPistaBase], [2|RestoPista]) :- !,
    pista3_aux(RestoPalpite, SecretaRestante, RestoPistaBase, RestoPista).
% Se é 0, verifica se a letra existe na secreta restante
pista3_aux([Letra|RestoPalpite], SecretaRestante,[0|RestoPistaBase],[Valor|RestoPista]):-
    (member(Letra, SecretaRestante) ->
        Valor = 1,
        remove_primeira_ocorrencia(Letra, SecretaRestante, NovaSecreta)
    ;
        Valor = 0,
        NovaSecreta = SecretaRestante
    ),
    pista3_aux(RestoPalpite, NovaSecreta, RestoPistaBase, RestoPista).

% Remove a primeira ocorrência de uma letra em uma lista
remove_primeira_ocorrencia(X, [X|Cauda], Cauda) :- !.
remove_primeira_ocorrencia(X, [C|Cauda], [C|CaudaSem]) :-
    remove_primeira_ocorrencia(X, Cauda, CaudaSem).


%--------------------Parte dos Filmes------------------%
/*
Parte 3: Planeamento de maratona de filmes com restrições.
Gera programações válidas considerando sessões fixas e regras.
*/

%Gera todas as programações possíveis de filmes, preenchendo com 'empty' se necessário,
%e filtra por restrições.
maratonaFilmes(ListaFilmes, ListaRestricoes, Programacao) :- 
    length(ListaFilmes, N),
    NumEmpty is 7 - N,
    criaListaEmpty(NumEmpty, ListaEmpty),
    append(ListaFilmes, ListaEmpty, ListaCompleta),
    
    findall(Perm,
            (permutation(ListaCompleta, Perm),
             verificaRestricoes(Perm, ListaRestricoes)),
            ListaProgramacoes),
    
    sort(ListaProgramacoes, Programacao), !.

%Cria uma lista de 'empty' para preencher sessões vazias
criaListaEmpty(0, []):- !.
criaListaEmpty(N, [empty|Resto]) :-
    N > 0,
    N1 is N - 1,
    criaListaEmpty(N1, Resto).

%Verifica se uma permutação satisfaz todas as restrições fornecidas
verificaRestricoes(_, []):- !.
verificaRestricoes(Perm, [Restricao|Resto]) :-
    verificaRestricao(Perm, Restricao),
    verificaRestricoes(Perm, Resto).

%Verifica restrição de terror: apenas em sessões a partir das 20h (posições 3,4,7)
%Terror aceita posições 3, 4, 7 (a partir das 20h em qualquer dia)
verificaRestricao(Perm, terror(Filme)) :-!, 
    nth1(Pos, Perm, Filme),
    member(Pos, [3, 4, 7]).

%Verifica restrição de sessão obrigatória para um filme
verificaRestricao(Perm, soPode(Filme, Sessao)) :- !,
    nth1(Sessao, Perm, Filme).

%Verifica restrição de proibição de sessão para um filme
verificaRestricao(Perm, nunca(Filme, Sessao)) :- !,
    nth1(Sessao, Perm, FilmeNaSessao),
    Filme \= FilmeNaSessao.

%Verifica se dois filmes são seguidos no mesmo dia
verificaRestricao(Perm, seguido(Filme1, Filme2)) :- !,
    nth1(Pos1, Perm, Filme1),
    Pos2 is Pos1 + 1,
    Pos2 =< 7,
    nth1(Pos2, Perm, Filme2),
    mesmoDia(Pos1, Pos2).

%Verifica se dois filmes não são seguidos no mesmo dia
verificaRestricao(Perm, naoSeguido(Filme1, Filme2)) :- !, 
    \+ (nth1(Pos1, Perm, Filme1),
        nth1(Pos2, Perm, Filme2),
        ((Pos2 =:= Pos1 + 1, mesmoDia(Pos1, Pos2)) ; 
         (Pos1 =:= Pos2 + 1, mesmoDia(Pos2, Pos1)))).

% Verifica se um filme precede outro (não necessariamente imediatamente)
verificaRestricao(Perm, antes(Filme1, Filme2)) :- !,
    nth1(Pos1, Perm, Filme1),
    nth1(Pos2, Perm, Filme2),
    Pos1 < Pos2.

% Determina se duas posições estão no mesmo dia (sábado: 1-4, domingo: 5-7)
mesmoDia(Pos1, Pos2) :-
    (Pos1 =< 4, Pos2 =< 4) ; (Pos1 >= 5, Pos2 >= 5).










