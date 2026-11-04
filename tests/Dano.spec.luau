-- Exemplos da seção de penetração e dano do plano. Conferidos também por script Python.
-- Cada caso recebe (t, Shared), onde Shared é uma cópia fresca de ReplicatedStorage.Shared.

return {
	["tiros no tronco pra matar"] = function(t, Shared)
		local Dano = require(Shared.Sim.Dano)
		t.igual(Dano.tirosPraMatar("Submetralhadora", "Tronco"), 3, "SMG")
		t.igual(Dano.tirosPraMatar("Pistola45", "Tronco"), 3, ".45")
		t.igual(Dano.tirosPraMatar("Pistola9", "Tronco"), 4, "9 mm")
		t.igual(Dano.tirosPraMatar("Escopeta", "Tronco"), 2, "escopeta")
	end,

	["cabeça direta mata, atravessando não"] = function(t, Shared)
		local Dano = require(Shared.Sim.Dano)
		t.igual(Dano.tiro({ Arma = "Pistola9", Parte = "Cabeca" }), 100, "direta")
		-- 9 mm com força 8/10 depois de parede: 30 × 4 × 0,8 = 96
		t.igual(Dano.tiro({ Arma = "Pistola9", Parte = "Cabeca", ForcaFinal = 8 }), 96, "atravessando")
	end,

	["dano depois de atravessar"] = function(t, Shared)
		local Dano = require(Shared.Sim.Dano)
		local Pen = require(Shared.Sim.Penetracao)
		local function caso(arma, forca, material, caminho, esperado)
			local r = Pen.atravessar(forca, { { Material = material, Caminho = caminho } })
			t.igual(Dano.tiro({ Arma = arma, Parte = "Tronco", ForcaFinal = r.Forca }), esperado, arma .. " " .. material)
		end
		caso("Submetralhadora", 12, "Gesso", 0.5, 23)
		caso("Submetralhadora", 12, "Madeira", 0.2, 26)
		caso("Sniper", 45, "Concreto", 0.5, 27)
		caso("Pistola9", 10, "MetalFino", 0.15, 3)
	end,

	["carga e queda"] = function(t, Shared)
		local Dano = require(Shared.Sim.Dano)
		t.igual(Dano.carga(0), 80, "carga centro")
		t.igual(Dano.carga(4), 45, "carga 4 studs")
		t.igual(Dano.carga(8), 10, "carga borda")
		t.igual(Dano.carga(8.1), 0, "carga fora")
		t.igual(Dano.queda(14), 0, "queda 14")
		t.igual(Dano.queda(20), 18, "queda 20")
		t.igual(Dano.queda(32), 54, "queda 32")
		t.igual(Dano.queda(33), 100, "queda 33 mata")
	end,
}
