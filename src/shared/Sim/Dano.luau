--!strict
-- Dano do tiro, da carga e da queda. Calculado uma vez, no servidor (decisão v3).
-- Fórmula: dano = base × multiplicador da parte × força final ÷ força inicial.

local Config = script.Parent.Parent.Config
local Armas = require(Config.Armas)
local Combate = require(Config.Combate)
local Vitais = require(Config.Vitais)
local Itens = require(Config.Itens)
local Movimento = require(Config.Movimento)

export type Parte = "Cabeca" | "PescocoPeito" | "Tronco" | "Braco" | "Perna"

export type Tiro = {
	Arma: string,
	Parte: Parte,
	ForcaFinal: number?, -- nil = tiro direto, força cheia
	Direto: boolean?, -- não atravessou nada antes do alvo
}

local Dano = {}

local function arredondar(x: number): number
	return math.floor(x + 0.5)
end

function Dano.tiro(tiro: Tiro): number
	local arma = Armas.Lista[tiro.Arma]
	assert(arma ~= nil, "arma desconhecida: " .. tostring(tiro.Arma))
	local mult = Combate.MultParte[tiro.Parte]
	assert(mult ~= nil, "parte desconhecida: " .. tostring(tiro.Parte))

	local direto = if tiro.Direto ~= nil then tiro.Direto else tiro.ForcaFinal == nil
	if direto and tiro.Parte == "Cabeca" and Combate.CabecaDiretaMata then
		return Vitais.VidaMax
	end

	local forcaFinal = tiro.ForcaFinal or arma.Forca
	local fracao = math.clamp(forcaFinal / arma.Forca, 0, 1)
	return arredondar(arma.Dano * mult * fracao)
end

-- Quantos tiros diretos naquela parte pra matar alguém com vida cheia.
function Dano.tirosPraMatar(nomeArma: string, parte: Parte): number
	local dano = Dano.tiro({ Arma = nomeArma, Parte = parte, Direto = true })
	return math.ceil(Vitais.VidaMax / dano)
end

-- Carga: cai em linha reta do centro até a borda do raio. Parede no meio zera (quem confere é o servidor).
function Dano.carga(distancia: number): number
	local c = Itens.Carga
	if distancia > c.Raio then
		return 0
	end
	local t = math.clamp(distancia / c.Raio, 0, 1)
	return arredondar(c.DanoCentro + (c.DanoBorda - c.DanoCentro) * t)
end

-- Queda: nada até 14 studs, 3 por stud acima disso, morte acima de 32.
function Dano.queda(altura: number): number
	local q = Movimento.Queda
	if altura <= q.SemDanoAte then
		return 0
	end
	if altura > q.MorteAcima then
		return Vitais.VidaMax
	end
	return arredondar((altura - q.SemDanoAte) * q.DanoPorStudAcima)
end

return Dano
