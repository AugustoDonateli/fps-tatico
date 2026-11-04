--!strict
-- Hitscan curvo: o tiro é resolvido na hora, mas o caminho cai com a gravidade da bala.
-- O caminho é cortado em segmentos e cada segmento vira um raycast.
-- O raycast e a medida de espessura são injetados: no jogo usam workspace:Raycast,
-- no teste usam funções falsas. Assim este módulo não depende do mapa.

local Config = script.Parent.Parent.Config
local Combate = require(Config.Combate)
local ArmasCfg = require(Config.Armas)
local Materiais = require(Config.Materiais)

export type Acerto = {
	Posicao: Vector3,
	Instancia: Instance?,
	Material: string?, -- material balístico (nome em Materiais.Lista); nil se for corpo
	Personagem: any?, -- quem foi atingido (Model ou id); nil se for parede
	Parte: string?, -- Cabeca, PescocoPeito, Tronco, Braco, Perna
}

export type Raycast = (origem: Vector3, deslocamento: Vector3, ignorar: { any }) -> Acerto?
export type MedirCaminho = (acerto: Acerto, direcao: Vector3) -> number

export type AlvoAtingido = {
	Personagem: any,
	Parte: string,
	Posicao: Vector3,
	ForcaFinal: number,
	Direto: boolean,
}

export type Resultado = {
	Alvos: { AlvoAtingido },
	Impactos: { Acerto }, -- paredes tocadas (pra efeito)
	Fim: Vector3,
	ForcaFinal: number,
}

local Balistica = {}

Balistica.PassoTempo = 0.04 -- s por segmento
Balistica.AlcanceMax = 1200 -- studs

-- Posição da bala no instante t.
function Balistica.posicao(origem: Vector3, direcao: Vector3, velocidade: number, t: number): Vector3
	local g = Combate.GravidadeBala
	return origem + direcao * velocidade * t + Vector3.new(0, -0.5 * g * t * t, 0)
end

-- Lista de pontos do caminho, do começo até o alcance máximo.
function Balistica.pontos(origem: Vector3, direcao: Vector3, velocidade: number): { Vector3 }
	local pontos = { origem }
	local tempoTotal = Balistica.AlcanceMax / velocidade
	local n = math.max(1, math.ceil(tempoTotal / Balistica.PassoTempo))
	for i = 1, n do
		table.insert(pontos, Balistica.posicao(origem, direcao, velocidade, tempoTotal * i / n))
	end
	return pontos
end

-- Resolve um tiro inteiro.
function Balistica.resolver(
	origem: Vector3,
	direcao: Vector3,
	nomeArma: string,
	raycast: Raycast,
	medirCaminho: MedirCaminho
): Resultado
	local arma = ArmasCfg.Lista[nomeArma]
	assert(arma ~= nil, "arma desconhecida: " .. tostring(nomeArma))

	local forca = arma.Forca
	local pecas = 0
	local direto = true
	local ignorar: { any } = {}
	local alvos: { AlvoAtingido } = {}
	local impactos: { Acerto } = {}
	local pontos = Balistica.pontos(origem, direcao.Unit, arma.VelocidadeBala)

	for i = 1, #pontos - 1 do
		local de = pontos[i]
		local ate = pontos[i + 1]
		-- Vários acertos podem cair no mesmo segmento.
		for _ = 1, Materiais.MaxPecas + 1 do
			local acerto = raycast(de, ate - de, ignorar)
			if acerto == nil then
				break
			end
			local dirSeg = (ate - de).Unit
			pecas += 1
			if pecas > Materiais.MaxPecas then
				return { Alvos = alvos, Impactos = impactos, Fim = acerto.Posicao, ForcaFinal = 0 }
			end

			local custo: number
			if acerto.Personagem ~= nil then
				table.insert(alvos, {
					Personagem = acerto.Personagem,
					Parte = acerto.Parte or "Tronco",
					Posicao = acerto.Posicao,
					ForcaFinal = forca,
					Direto = direto,
				})
				table.insert(ignorar, acerto.Personagem)
				custo = Materiais.CustoCorpo
			else
				table.insert(impactos, acerto)
				if acerto.Instancia ~= nil then
					table.insert(ignorar, acerto.Instancia)
				end
				local mat = Materiais.Lista[acerto.Material or "Concreto"] or Materiais.Lista.Concreto
				custo = mat.Resistencia * medirCaminho(acerto, dirSeg)
			end

			direto = false
			if custo >= forca then
				return { Alvos = alvos, Impactos = impactos, Fim = acerto.Posicao, ForcaFinal = 0 }
			end
			forca -= custo
			de = acerto.Posicao + dirSeg * 0.01
		end
	end

	return { Alvos = alvos, Impactos = impactos, Fim = pontos[#pontos], ForcaFinal = forca }
end

return Balistica
