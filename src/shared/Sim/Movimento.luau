--!strict
-- Velocidade, energia e equilíbrio. Funções puras: recebem o estado e o tempo, devolvem o novo valor.

local Config = script.Parent.Parent.Config
local MovCfg = require(Config.Movimento)
local Vitais = require(Config.Vitais)

export type Modo =
	"Correr"
	| "Andar"
	| "AndarDevagar"
	| "Agachado"
	| "AgachadoDevagar"
	| "Deitado"
	| "Escada"
	| "Nadar"
	| "NadarRapido"

export type Postura = "Correndo" | "EmPe" | "Agachado" | "Deitado"

export type Estado = {
	Modo: Modo,
	Parado: boolean?,
	Mirando: boolean?,
	Maleta: boolean?,
	PernaFerida: boolean?,
	Energia: number?, -- pra saber se está cansado
	Cansado: boolean?, -- se vier, manda mais que a Energia (ver atualizarCansado)
}

local Mov = {}

function Mov.cansado(energia: number): boolean
	return energia < Vitais.Energia.LimiarCansado
end

-- Cansado liga abaixo de 25 e só desliga com 40.
function Mov.atualizarCansado(cansadoAntes: boolean, energia: number): boolean
	local en = Vitais.Energia
	if cansadoAntes then
		return energia < en.VoltaACorrer
	end
	return energia < en.LimiarCansado
end

function Mov.podeCorrer(e: Estado): boolean
	if e.Maleta or e.PernaFerida or e.Mirando then
		return false
	end
	if e.Cansado ~= nil then
		return not e.Cansado
	end
	if e.Energia ~= nil and Mov.cansado(e.Energia) then
		return false
	end
	return true
end

-- Modo que vale de verdade (quem pediu pra correr e não pode, anda).
function Mov.modoEfetivo(e: Estado): Modo
	if e.Modo == "Correr" and not Mov.podeCorrer(e) then
		return "Andar"
	end
	return e.Modo
end

function Mov.velocidade(e: Estado): number
	if e.Parado then
		return 0
	end
	local modo = Mov.modoEfetivo(e)
	local v = MovCfg.Velocidades[modo]
	assert(v ~= nil, "modo desconhecido: " .. tostring(modo))
	local m = MovCfg.Multiplicadores
	if e.Mirando then
		v *= m.Mirando
	end
	if e.Maleta then
		v *= m.CarregandoMaleta
	end
	if e.PernaFerida then
		v *= m.PernaFerida
	end
	return v
end

-- Energia depois de dt segundos. Rastejar gasta e não recupera.
function Mov.passoEnergia(energia: number, e: Estado, dt: number): number
	local en = Vitais.Energia
	local modo = Mov.modoEfetivo(e)
	local taxa: number
	if modo == "Correr" and not e.Parado then
		taxa = -en.CorrerPorSegundo
	elseif modo == "Deitado" then
		taxa = if e.Parado then en.RecuperaDeitadoParado else -en.RastejarPorSegundo
	elseif modo == "Agachado" or modo == "AgachadoDevagar" then
		taxa = en.RecuperaAgachado
	elseif e.Parado then
		taxa = en.RecuperaParadoEmPe
	else
		taxa = en.RecuperaAndando
	end
	return math.clamp(energia + taxa * dt, 0, en.Max)
end

-- Equilíbrio volta 40/s, só depois de 1 s sem perder.
function Mov.passoEquilibrio(equilibrio: number, desdeUltimaPerda: number, dt: number): number
	local eq = Vitais.Equilibrio
	if desdeUltimaPerda < eq.AtrasoRecuperacao then
		return equilibrio
	end
	return math.clamp(equilibrio + eq.RecuperaPorSegundo * dt, 0, eq.Max)
end

-- Perda de equilíbrio já multiplicada pela postura.
function Mov.perdaEquilibrio(tipo: string, postura: Postura): number
	local eq = Vitais.Equilibrio
	local perda = (eq.Perdas :: any)[tipo]
	assert(type(perda) == "number", "perda desconhecida: " .. tostring(tipo))
	local mult = eq.MultPostura[postura]
	assert(mult ~= nil, "postura desconhecida: " .. tostring(postura))
	return perda * mult
end

-- Aplica uma perda. Devolve o equilíbrio novo e se a pessoa caiu.
function Mov.aplicarPerda(equilibrio: number, tipo: string, postura: Postura): (number, boolean)
	if (Vitais.Equilibrio.DerrubaSempre :: any)[tipo] then
		return 0, true
	end
	local novo = equilibrio - Mov.perdaEquilibrio(tipo, postura)
	if novo <= 0 then
		return 0, true
	end
	return novo, false
end

return Mov
