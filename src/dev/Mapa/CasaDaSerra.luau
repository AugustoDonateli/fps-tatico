--!strict
-- Monta a Casa da Serra inteira (etapa 1) em workspace.Mapa. Planta própria.
-- Rodar no Studio (modo Edit) pelo MCP:
--   local p = game.ServerStorage.Dev.Mapa:Clone(); p.Parent = game.ServerStorage
--   require(p.CasaDaSerra).construir(); p:Destroy()
-- (copia a pasta inteira pra não pegar versão velha no cache do require)

local Casa = require(script.Parent.Casa)
local Ambiente = require(script.Parent.Ambiente)

local CasaDaSerra = {}

function CasaDaSerra.construir(): Model
	local velho = workspace:FindFirstChild("Mapa")
	if velho then
		velho:Destroy()
	end
	for _, nome in { "Baseplate", "SpawnLocation" } do
		local p = workspace:FindFirstChild(nome)
		if p and p.Parent == workspace then
			p:Destroy()
		end
	end
	local mapa = Instance.new("Model")
	mapa.Name = "Mapa"
	mapa.Parent = workspace
	Casa.construir(mapa)
	task.wait()
	Ambiente.construir(mapa)
	return mapa
end

return CasaDaSerra
