-- Confere que o Config carrega inteiro e que os números se conversam.

return {
	["config carrega"] = function(t, Shared)
		local Config = require(Shared.Config)
		for _, nome in { "Movimento", "Vitais", "Combate", "Armas", "Materiais", "Sons", "Rodada", "Objetivo", "Itens", "Teclas", "Mapa" } do
			t.verdade(Config[nome] ~= nil, nome)
		end
	end,

	["armas dos kits existem"] = function(t, Shared)
		local Config = require(Shared.Config)
		for time, kit in Config.Itens.Kit do
			if kit.Principal then
				t.verdade(Config.Armas.Lista[kit.Principal] ~= nil, time .. " principal")
			end
			t.verdade(Config.Armas.Lista[kit.Pistola] ~= nil, time .. " pistola")
		end
	end,

	["materiais do Roblox apontam pra materiais que existem"] = function(t, Shared)
		local Materiais = require(Shared.Config.Materiais)
		for roblox, nosso in Materiais.DoRoblox do
			t.verdade(Materiais.Lista[nosso] ~= nil, roblox .. " → " .. nosso)
			t.verdade(pcall(function()
				return (Enum.Material :: any)[roblox]
			end), "Enum.Material." .. roblox)
		end
	end,

	["reserva fecha em pentes inteiros"] = function(t, Shared)
		local Armas = require(Shared.Config.Armas)
		for nome, arma in Armas.Lista do
			if not arma.Recarga.PorCartucho then
				t.igual(arma.Reserva % arma.Pente, 0, nome)
			end
		end
	end,
}
