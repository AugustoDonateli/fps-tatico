# Estado

Atualizado em 4 nov. 2026.

## Marco atual: M0 (base)

Feito:
- Repositório, Rojo, selene, StyLua.
- Config com todos os números do documento de projeto (11 arquivos).
- Funções puras: Penetracao, Dano, Dispersao, Movimento, Municao, Balistica.
- Lista de remotes e validador (NaN, infinito, faixa, lista de valores, tamanho de vetor).
- Limitador por jogador. Porta de entrada dos remotes no servidor (`Rede.ouvir`) com expulsão após 3 recusas graves em 10 s.
- DebugBridge (só Studio).
- Testes: 6 arquivos de spec. Os números foram conferidos também por script Python.

- Testes rodados no Studio do Guto em 4 nov. 2026: 25 de 25 passaram.

Falta no M0:
- [ ] Rodar selene e StyLua no PC.
- [ ] Ligar o Rojo no PC (hoje o código foi colocado no Studio direto pelo MCP).

## Próximo: versão jogável (decidido em 4 nov. 2026)
Objetivo: jogar com 4 a 6 pessoas e responder: o tiro é justo? A casa é divertida de atacar e defender? O visual está no nível?

Entra:
- Casa da Serra, etapa 1 (só a casa), primeiro em blocos, depois com acabamento visual no estilo do Intruder (formas simples, cores chapadas, luz de fim de tarde). Planta própria.
- Submetralhadora, pistola .45 e pistola 9 mm.
- Andar, correr, agachar, deitar, inclinar, pular, energia.
- Mira, recuo, dispersão, recarga, dano por parte do corpo, tiro atravessando parede.
- Portas abrindo aos poucos.
- 2 times, rodada com maleta e extração simples.
- Morte com o corpo caindo (ragdoll simples).

Fica pra depois: rádio, voz, câmera de vara, sensor, carga, lockpick, portas trancadas, fingir de morto, prender, empurrar, supressão, sangramento, equilíbrio derrubando, escopeta, fuzil, sniper, anexo, lago e passarela.

Feito na versão jogável:
- Movimento (cliente, modelo clássico): andar 9, correr 16, devagar, agachar (C), deitar (Z), levantar com espaço, inclinar (Q/E, 1,5 stud e 15°), pulo de 2,5 studs que gasta energia, primeira pessoa travada, barra de energia.
- Cansaço liga abaixo de 25 e só desliga com 40 (antes ficava ligando e desligando).
- Testado no Studio pelo MCP: velocidades, energia, posturas, inclinar e pulo batem com o Config. 26 testes passam.

Ordem: 1) movimento (feito); 2) casa em blocos e tempos de rota; 3) arma e tiro; 4) portas; 5) rodada e maleta; 6) acabamento visual; 7) teste com gente.

## Lote do Guto (coisas que só você faz)
- [ ] Instalar o Blender.
- [ ] Criar o grupo do Roblox que vai ser dono do jogo e dos assets.
- [ ] Exportar os 4 docs (Bíblia, Projeto, Pesquisa, Plano) em Markdown pra `docs/referencia/`.
- [ ] Criar uma segunda conta pra testar com 2 jogadores.
- [ ] Decidir: câmera de vara em tela cheia (padrão) ou monitor ao lado da arma.
- [ ] Decidir: o que fazer com os R$ 200 se a P5 reprovar.
