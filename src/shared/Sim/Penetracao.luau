--!strict
-- Penetração: quanto de força sobra depois de atravessar peças e corpos.
-- Função pura. Quem mede o caminho dentro de cada peça é a Balistica (ou o teste).

local Config = script.Parent.Parent.Config
local Materiais = require(Config.Materiais)

export type Trecho = {
	Material: string?, -- nome em Materiais.Lista
	Resistencia: number?, -- usa direto se vier (manda mais que Material)
	Caminho: number?, -- studs dentro da peça
	Corpo: boolean?, -- personagem atravessado: custo fixo
}

export type Resultado = {
	Forca: number, -- força que sobrou (0 se parou)
	Atravessou: number, -- quantas peças atravessou inteiras
	Parou: boolean,
}

local Penetracao = {}

-- Custo de um trecho = resistência × caminho, ou o custo fixo de corpo.
function Penetracao.custo(trecho: Trecho): number
	if trecho.Corpo then
		return Materiais.CustoCorpo
	end
	local resistencia = trecho.Resistencia
	if resistencia == nil then
		local nome = trecho.Material
		assert(nome ~= nil, "trecho sem Material nem Resistencia")
		local material = Materiais.Lista[nome]
		assert(material ~= nil, "material desconhecido: " .. tostring(nome))
		resistencia = material.Resistencia
	end
	local caminho = trecho.Caminho or 0
	assert(caminho >= 0, "caminho negativo")
	return (resistencia :: number) * caminho
end

-- Passa a bala pelos trechos em ordem. Parou se a força acaba ou se passa do máximo de peças.
function Penetracao.atravessar(forcaInicial: number, trechos: { Trecho }): Resultado
	local forca = forcaInicial
	for indice, trecho in trechos do
		if indice > Materiais.MaxPecas then
			return { Forca = 0, Atravessou = indice - 1, Parou = true }
		end
		local custo = Penetracao.custo(trecho)
		if custo >= forca then
			return { Forca = 0, Atravessou = indice - 1, Parou = true }
		end
		forca -= custo
	end
	return { Forca = forca, Atravessou = #trechos, Parou = false }
end

return Penetracao
