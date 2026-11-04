--!strict
-- Ponte de depuração: só no Studio, só no servidor.
-- Os serviços registram funções de leitura de estado ("Vitais", "Rodada"...).
-- O Claude chama pelo MCP do Studio com:
--   game.ServerStorage:FindFirstChild("DebugBridge"):Invoke("Rodada")
-- Não executa código arbitrário: só chama o que foi registrado.

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local DebugBridge = {}

local funcoes: { [string]: (...any) -> any } = {}
local iniciado = false

function DebugBridge.registrar(nome: string, funcao: (...any) -> any)
	funcoes[nome] = funcao
end

function DebugBridge.iniciar()
	if iniciado or not RunService:IsStudio() then
		return
	end
	iniciado = true
	local bf = Instance.new("BindableFunction")
	bf.Name = "DebugBridge"
	bf.OnInvoke = function(nome: string, ...: any)
		if nome == "Lista" then
			local nomes = {}
			for n in funcoes do
				table.insert(nomes, n)
			end
			table.sort(nomes)
			return nomes
		end
		local funcao = funcoes[nome]
		if funcao == nil then
			return { Erro = "não registrado: " .. tostring(nome) }
		end
		return funcao(...)
	end
	bf.Parent = ServerStorage
end

return DebugBridge
