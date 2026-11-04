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

Falta no M0:
- [ ] Rodar os testes no Studio pela primeira vez e corrigir o que falhar.
- [ ] Rodar selene e StyLua no PC.
- [ ] Montar a sala de laboratório no Studio (paredes de cada material, alvos, escada, rampa).

Depois do M0: provas P1 (Server Authority), P9 (ragdoll) e a cadeira da P5 (arma por código).

## Lote do Guto (coisas que só você faz)
- [ ] Instalar o Blender.
- [ ] Criar o grupo do Roblox que vai ser dono do jogo e dos assets.
- [ ] Exportar os 4 docs (Bíblia, Projeto, Pesquisa, Plano) em Markdown pra `docs/referencia/`.
- [ ] Criar uma segunda conta pra testar com 2 jogadores.
- [ ] Decidir: câmera de vara em tela cheia (padrão) ou monitor ao lado da arma.
- [ ] Decidir: o que fazer com os R$ 200 se a P5 reprovar.
