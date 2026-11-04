--!strict
-- Ponto de partida do cliente.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Net.Remotes)

Remotes.obter(ReplicatedStorage, "Atirar")

local Movimento = require(script:WaitForChild("Movimento"))
local Hud = require(script:WaitForChild("Hud"))

Movimento.iniciar()
Hud.iniciar(Movimento)

print("[Cliente] pronto")
