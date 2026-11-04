# FPS tático (Roblox) — regras pro Claude

Leia isto antes de mexer em qualquer coisa. O plano completo está no Claude Doc "Plano de execução" (v3).
O estado atual e o próximo passo estão em `docs/ESTADO.md`. Atualize esse arquivo no fim de toda sessão.

## Como o projeto roda
- Código no Git, sincronizado com o Studio pelo Rojo (`rojo serve` + plugin do Rojo).
- O mapa e as peças grandes ficam no Studio; o código fica aqui. Não editar script dentro do Studio.
- `default.project.json` é o de trabalho. `build.project.json` gera o .rbxl de entrega (o mapa entra no M2).

## Pastas
- `src/shared/Config` — todos os números do jogo. Nenhum outro arquivo escreve número de jogo solto.
- `src/shared/Sim` — funções puras (penetração, dano, dispersão, movimento, munição, balística). Sem estado, sem serviço.
- `src/shared/Net/Remotes.luau` — lista de todos os remotes e o validador de formato.
- `src/shared/Util` — utilidades (Limitador).
- `src/server` — servidor. Todo remote do cliente entra pelo `Rede.ouvir` (limite → formato → função).
- `src/client` — cliente.
- `src/dev/DebugBridge.luau` — só no Studio. Lê estados registrados. Nunca executa código arbitrário.
- `tests` — testes (`*.spec.luau`) e o runner `Rodar.luau`.

## Rodar os testes
Pelo MCP do Studio (execute_luau), com o Rojo ligado e sem dar Play:

```lua
return require(game.ServerStorage.Tests.Rodar:Clone())()
```

Cada spec devolve uma tabela `{ ["nome do caso"] = function(t, Shared) ... end }`.
`Shared` é uma cópia fresca de `ReplicatedStorage.Shared`, então use `require(Shared.Sim.X)`.
Os módulos de `Sim` usam `script.Parent.Parent.Config` (caminho relativo) pra funcionar na cópia.

## Decisões fechadas (não mudar sem falar com o Guto)
- Tiro: hitscan curvo (gravidade da bala 35 studs/s²), resolvido no servidor, com volta no tempo de até 250 ms
  (histórico de 1,2 s). O instante do cliente é conferido contra a estimativa do servidor (50 ms de folga, nunca futuro).
- Origem do tiro a até 1,5 stud da cabeça, com caminho livre até ela.
- Dano calculado uma vez: base × multiplicador da parte × força final ÷ força inicial. Tiro direto na cabeça mata.
- Penetração: custo = resistência × caminho dentro do colisor balístico. No máximo 4 peças. Corpo custa 6.
- Som tático por evento confiável. Passos e efeito de tiro por UnreliableRemoteEvent (efeito só até 150 studs).
- Arquitetura de rede: Server Authority ou modelo clássico, decidido pela prova P1. Só uma fica.
- O servidor é dono do corpo morto e do fingir de morto.

## Proibido
- Engenharia reversa ou extrair arquivo do Intruder. Mapas com planta própria.
- Usar modelo de terceiros sem triagem (sem script escondido, licença anotada em `docs/LICENCAS.md`).
- Subir asset fora do grupo do jogo. Todo ID vai pro manifesto.
- Confiar no cliente: todo remote passa por `Rede.ouvir`.

## Estilo
- `--!strict` em todo módulo de `src`. Nomes em português.
- Tabs, 110 colunas (StyLua). selene com std roblox.
- Commits pequenos, em português.
