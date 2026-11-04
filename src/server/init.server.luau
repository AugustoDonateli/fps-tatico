--!strict
-- Ponto de partida do servidor. Cria os remotes e, só no Studio, liga a ponte de depuração.
-- Os serviços de jogo (rodada, combate, portas...) entram aqui a partir do M1.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Net.Remotes)

Remotes.criar(ReplicatedStorage)

if RunService:IsStudio() then
	local Dev = ServerStorage:FindFirstChild("Dev")
	if Dev then
		local DebugBridge = require(Dev:WaitForChild("DebugBridge")) :: any
		DebugBridge.iniciar()
		DebugBridge.registrar("Remotes", function()
			local nomes = {}
			for nome in Remotes.Lista do
				table.insert(nomes, nome)
			end
			table.sort(nomes)
			return nomes
		end)
	end
end

print("[Servidor] pronto")
