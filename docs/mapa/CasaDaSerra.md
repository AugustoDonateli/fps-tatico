# Casa da Serra — etapa 1 (blocos)

Planta própria. Código: `src/dev/Mapa/CasaDaSerra.luau` (monta tudo em `workspace.Mapa`).

## Planta
- Casa de 90 × 60 studs: térreo (piso y 0), 1º andar (piso y 11), porão (piso y -11).
- Térreo: cozinha e jantar (oeste), sala com pé-direito duplo e claraboia (centro), hall de entrada (sul), área de serviço e garagem (leste).
- 1º andar: galeria em U em volta do vão da sala; quartos 1 e 2 e banheiro (oeste); quarto 3 (frente); escritório, banheiro 2 e quarto 4 (leste).
- Porão: adega dos servidores e lavanderia.
- Escada principal dentro da sala; escada do porão na área de serviço.

## Rotas de entrada (8)
Porta da frente, janela da cozinha (peitoril baixo, pula), porta dos fundos (cozinha), porta de vidro da sala (norte), portão da garagem, porta lateral da garagem, duto do porão (grade no jardim leste), trepadeira até a janela do escritório.

## Lugares de maleta (etapa 1)
Escritório (1º andar), adega (porão), garagem.

## Tempos medidos (4 nov. 2026, PathfindingService, andando a 9 studs/s e com maleta a 7,65)
| Trajeto | Distância | Tempo | Meta |
| --- | --- | --- | --- |
| Spawn sul → porta da frente | 146 | 16,2 s | 15–20 s ✔ |
| Spawn sul → portão da garagem | 167 | 18,5 s | ✔ |
| Spawn sul → janela da cozinha | 144 | 15,9 s | ✔ |
| Spawn oeste → janela da cozinha | 120 | 13,4 s | um pouco curto |
| Spawn oeste → porta dos fundos | 123 | 13,6 s | um pouco curto |
| Spawn oeste → porta de vidro | 152 | 16,9 s | ✔ |
| Guardas → escritório | 72 | 8,0 s | até 15 s ✔ |
| Guardas → adega | 119 | 13,3 s | ✔ |
| Guardas → garagem | 72 | 8,0 s | ✔ |
| Escritório → extração norte (com maleta) | 149 | 19,5 s | 20–30 s, no limite |
| Garagem → extração leste (com maleta) | 178 | 23,3 s | ✔ |
| Adega → extração norte (com maleta) | 196 | 25,6 s | ✔ |

## Pendências
- Spawn oeste está ~1,5 s perto demais. Ajustar depois do primeiro teste com gente.
- Duto do porão está alto (7 studs) porque deitar ainda não muda a colisão. Baixar quando mudar.
- Portas e portão são só vãos. Portas entram no passo 4.
- Maior linha de visão (meta 150 studs) ainda não medida.
