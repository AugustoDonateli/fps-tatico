--!strict
-- Porta de entrada de todo remote do cliente.
-- Ordem: limite por segundo → formato (Remotes.validar) → função do serviço.
-- Formato errado conta como recusa grave. 3 recusas graves em 10 s = expulsa.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Net.Remotes)
local Limitador = require(Shared.Util.Limitador)
local Combate = require(Shared.Config.Combate)

local Rede = {}

local recusas: { [Player]: { number } } = {}

function Rede.registrarRecusaGrave(jogador: Player, motivo: string)
	local agora = os.clock()
	local lista = recusas[jogador] or {}
	recusas[jogador] = lista
	table.insert(lista, agora)
	-- tira as antigas
	local janela = Combate.Rede.JanelaRecusas
	while #lista > 0 and agora - lista[1] > janela do
		table.remove(lista, 1)
	end
	warn(("[Rede] recusa grave de %s: %s"):format(jogador.Name, motivo))
	if #lista >= Combate.Rede.RecusasPraExpulsar then
		jogador:Kick("Dados inválidos enviados ao servidor.")
	end
end

-- Liga um remote do cliente a uma função. A função só roda com os argumentos já conferidos.
function Rede.ouvir(nome: string, funcao: (jogador: Player, ...any) -> ())
	local info = Remotes.Lista[nome]
	assert(info ~= nil and info.Direcao == "ClienteServidor", "remote não é do cliente: " .. nome)
	local remote = Remotes.obter(ReplicatedStorage, nome) :: RemoteEvent
	local limite = Limitador.novo(info.PorSegundo or 10)

	remote.OnServerEvent:Connect(function(jogador: Player, ...: any)
		if not limite:permitir(jogador) then
			return -- só ignora; passar do limite não é grave
		end
		local ok, motivo = Remotes.validar(nome, ...)
		if not ok then
			Rede.registrarRecusaGrave(jogador, nome .. " - " .. tostring(motivo))
			return
		end
		funcao(jogador, ...)
	end)

	Players.PlayerRemoving:Connect(function(jogador)
		limite:esquecer(jogador)
	end)
end

Players.PlayerRemoving:Connect(function(jogador)
	recusas[jogador] = nil
end)

return Rede
