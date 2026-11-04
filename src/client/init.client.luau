--!strict
-- Ponto de partida do cliente. Por enquanto só espera os remotes aparecerem.
-- Os controladores (entrada, câmera, arma, HUD) entram aqui a partir do M1.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Net.Remotes)

Remotes.obter(ReplicatedStorage, "Atirar")
print("[Cliente] remotes prontos")
