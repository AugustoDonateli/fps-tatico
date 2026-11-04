# Decisões

Registro curto. Cada linha: o que foi decidido, quando e por quê. Detalhes no Plano v3.

## Fechadas no plano (v2 e v3)
| Decisão | Por quê |
| --- | --- |
| Tiro hitscan curvo, gravidade 35 studs/s² | Resposta na hora como no Intruder, com queda real em tiro longo. Projétil de verdade custa rede e servidor. |
| Volta no tempo até 250 ms, histórico 1,2 s | Cobre ping de até ~250 ms sem dar vantagem grande pra quem tem ping alto. |
| Instante do tiro conferido com 50 ms de folga, nunca futuro | Impede o cliente de escolher o passado que quiser. |
| Origem do tiro até 1,5 stud da cabeça, caminho livre | Impede atirar de dentro da parede. |
| Dano calculado uma vez no servidor | Uma fórmula só, sem diferença entre cliente e servidor. |
| Tiro direto na cabeça mata; atravessando, usa a fórmula | Regra simples; parede ainda protege. |
| Penetração por resistência × caminho, máx. 4 peças, corpo 6 | Números do documento de projeto. |
| Rastejar gasta energia e não recupera | Deitado parado recupera 4/s. |
| Equilíbrio volta 40/s depois de 1 s sem perda | Ajustável. |
| Carga: parede bloqueia | Evita dano através de laje. |
| Som tático confiável; passos e efeito de tiro não confiáveis | Som que muda decisão não pode se perder. |
| Câmera de vara em tela cheia (padrão) | ViewportFrame só mostra os próprios filhos; tela cheia usa a câmera real. Guto pode trocar. |
| Acústica nativa (AcousticSimulationEnabled) se a P3 aprovar | Menos código. |
| LightingStyle no lugar de Technology | API nova. |
| Assets só pelo grupo, com manifesto de IDs | Evita perder asset preso numa conta pessoal. |
| Bots chamam as funções do servidor, sem remote | Teste sem precisar de 10 pessoas. |
| Colisores separados: visual, movimento, balístico, acústico | Cada sistema mede no que importa pra ele. |

## Versão jogável primeiro (4 nov. 2026)
Antes das partes difíceis, fazer uma versão curta e jogável pra ver se o projeto se sustenta. Corte em `docs/ESTADO.md`.
Mapa e visual: mesmo estilo do Intruder, com planta própria. Copiar mapa, modelos ou texturas do Intruder continua proibido (risco de derrubada por direito autoral).

## Esperando prova
| Decisão | Prova |
| --- | --- |
| Server Authority ou modelo clássico | P1 |
| Ragdoll do Nevermore ou próprio | P9 |
| Arma por código ou comprar/encomendar modelo | P5 |

## Esperando o Guto
- Tamanho do time (5 ou 6) — fechar no teste com gente.
- Quem testa e quem ajuda com voz na P4.
- Criar o grupo do Roblox agora.
- Plano B dos R$ 200 se a P5 reprovar.
