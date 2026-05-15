# Projeto de Prolog - LP

Projeto desenvolvido na cadeira de **Lógica de Programação** que combina três grandes partes:

- Análise estatística sobre uma base de dados de estudantes (médias, alertas de saúde, probabilidade condicional e correlação de Pearson).
- Jogo estilo **Wordle** com três níveis de dificuldade de pistas.
- Planeador de maratona de filmes com restrições (programação de 7 sessões).

**Aluno:** Pedro Maria Vilhena Almeida

## Funcionalidades

### Parte 1 — Base de Dados de Estudantes
- `media/2` — Média aritmética arredondada
- `mediaNotasPorIdade/3` — Média de notas por intervalo de idades
- `freqPorGenero/2` — Frequência média por género
- `alertaSaude/4` — Alunos em risco com critérios de sono, exercício e saúde
- `probEcraNotasAltas/3` — Probabilidade condicional
- `correlacao/3` — Coeficiente de correlação de Pearson (implementado manualmente)

### Parte 2 — Wordle
- `quantasN/3` e `quantasC/3` — Estatísticas sobre listas de palavras
- `pista1/3`, `pista2/3`, `pista3/3` — Três níveis de pistas (verde/amarelo/vermelho)
- `jogar/4` — Jogo interativo completo (disponível em `jogar.pl`)

### Parte 3 — Maratona de Filmes
- `maratonaFilmes/3` — Gera todas as programações válidas de 7 sessões respeitando restrições (`soPode`, `nunca`, `seguido`, `naoSeguido`, `antes`, `terror`, ...)

## Como executar

```bash
# Carregar o projeto
swipl

?- [proj].
true.

% Testes públicos
?- ["testes_publicos.plt"].
?- run_tests.
% All 47 tests passed

% Jogar o Wordle
?- jogar(pt, 5, 6, pista3).
