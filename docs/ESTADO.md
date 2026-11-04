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

## Voltando ao plano (4 nov. 2026)
O desvio da "versão jogável" serviu de teste: o movimento entra no M1 e o mapa com acabamento fica guardado como base da A4/A5 (código em `src/dev/Mapa`). O mapa cinza do M2 vai ser montado com o mesmo kit, sem os móveis.

### O que falta pra fechar o M0
- [ ] Rojo rodando no PC do Guto (resolve também o bloqueio do MCP pra criar scripts no lugar).
- [ ] EntradaController base (teclas do Config viram ações).
- [ ] Estande de teste e sala de laboratório (cinza): porta 3,2 × 7,5, janela, duto, escada, painel com uma parede de cada material, 2 posições de tiro, corredor em L, boneco de escala 6,3.
- [ ] DebugBridge lendo o estado do jogo em Play pelo execute_luau.
- [ ] Prova P1 (Server Authority, lugar à parte, 150 ms simulados, depois 2 contas publicadas).
- [ ] Prova P9 (ragdoll do Nevermore contra constraints próprias).
- [ ] Cadeira da prova P5 (Blender sem janela, escala certa na 1ª tentativa).
- [ ] 1 hora de estudo dos templates oficiais FPS System e Laser Tag.
- [ ] Tag marco-0 no GitHub.

Depois: M1 Corpo (arquitetura da P1, 8 posturas, energia, equilíbrio, beirada, ragdoll, fingir, escada, trepadeira, nado, painel de medidores).

## Lote do Guto (coisas que só você faz)
- [ ] Instalar o Blender.
- [ ] Criar o grupo do Roblox que vai ser dono do jogo e dos assets.
- [ ] Exportar os 4 docs (Bíblia, Projeto, Pesquisa, Plano) em Markdown pra `docs/referencia/`.
- [ ] Criar uma segunda conta pra testar com 2 jogadores.
- [ ] Decidir: câmera de vara em tela cheia (padrão) ou monitor ao lado da arma.
- [ ] Decidir: o que fazer com os R$ 200 se a P5 reprovar.
