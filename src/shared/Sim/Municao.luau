--!strict
-- Pentes e recarga. Cada pente é guardado com quantas balas tem.
-- Na recarga, o pente atual volta pro bolso e o jogo pega o mais cheio.

local Config = script.Parent.Parent.Config
local ArmasCfg = require(Config.Armas)

export type Estado = {
	NoArma: number, -- balas no pente da arma (com bala na câmara contada aqui)
	Pentes: { number }, -- pentes no bolso
}

local Municao = {}

function Municao.inicial(nomeArma: string): Estado
	local arma = ArmasCfg.Lista[nomeArma]
	assert(arma ~= nil, "arma desconhecida: " .. tostring(nomeArma))
	local pentes = {}
	if arma.Recarga.PorCartucho then
		-- Escopeta: reserva é de cartuchos soltos, guardada como um "pente" só.
		table.insert(pentes, arma.Reserva)
	else
		for _ = 1, math.floor(arma.Reserva / arma.Pente) do
			table.insert(pentes, arma.Pente)
		end
	end
	return { NoArma = arma.Pente, Pentes = pentes }
end

-- Tempo de recarga em segundos.
function Municao.tempoRecarga(nomeArma: string, e: Estado): number
	local arma = ArmasCfg.Lista[nomeArma]
	assert(arma ~= nil, "arma desconhecida: " .. tostring(nomeArma))
	local r = arma.Recarga
	if r.PorCartucho then
		local cabem = arma.Pente - e.NoArma
		local tem = e.Pentes[1] or 0
		return math.min(cabem, tem) * r.PorCartucho
	end
	if e.NoArma > 0 then
		return r.ComBala :: number
	end
	return r.Vazio :: number
end

-- Faz a recarga. Devolve o estado novo (não mexe no antigo) e se trocou.
function Municao.recarregar(nomeArma: string, e: Estado): (Estado, boolean)
	local arma = ArmasCfg.Lista[nomeArma]
	assert(arma ~= nil, "arma desconhecida: " .. tostring(nomeArma))

	if arma.Recarga.PorCartucho then
		local cabem = arma.Pente - e.NoArma
		local tem = e.Pentes[1] or 0
		local poe = math.min(cabem, tem)
		if poe <= 0 then
			return e, false
		end
		return { NoArma = e.NoArma + poe, Pentes = { tem - poe } }, true
	end

	local melhor, indice = -1, 0
	for i, balas in e.Pentes do
		if balas > melhor then
			melhor, indice = balas, i
		end
	end
	if indice == 0 or melhor <= 0 then
		return e, false
	end
	local pentes = table.clone(e.Pentes)
	table.remove(pentes, indice)
	if e.NoArma > 0 then
		table.insert(pentes, e.NoArma)
	end
	return { NoArma = melhor, Pentes = pentes }, true
end

return Municao
