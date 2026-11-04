return {
	["sobra de força nos 4 exemplos"] = function(t, Shared)
		local Pen = require(Shared.Sim.Penetracao)
		t.perto(Pen.atravessar(12, { { Material = "Gesso", Caminho = 0.5 } }).Forca, 8, 1e-6, "SMG gesso")
		t.perto(Pen.atravessar(12, { { Material = "Madeira", Caminho = 0.2 } }).Forca, 9.2, 1e-6, "SMG porta")
		t.perto(Pen.atravessar(45, { { Material = "Concreto", Caminho = 0.5 } }).Forca, 10, 1e-6, "sniper concreto")
		t.perto(Pen.atravessar(10, { { Material = "MetalFino", Caminho = 0.15 } }).Forca, 1, 1e-6, "9 mm metal")
	end,

	["para quando o custo passa da força"] = function(t, Shared)
		local Pen = require(Shared.Sim.Penetracao)
		local r = Pen.atravessar(12, { { Material = "Concreto", Caminho = 1 } })
		t.verdade(r.Parou, "parou")
		t.igual(r.Forca, 0, "força zerada")
		t.igual(r.Atravessou, 0, "não atravessou nada")
	end,

	["corpo custa 6"] = function(t, Shared)
		local Pen = require(Shared.Sim.Penetracao)
		local r = Pen.atravessar(12, { { Corpo = true }, { Material = "Gesso", Caminho = 0.5 } })
		t.perto(r.Forca, 2, 1e-6, "SMG corpo + gesso")
	end,

	["máximo de 4 peças"] = function(t, Shared)
		local Pen = require(Shared.Sim.Penetracao)
		local vidro = { Material = "Vidro", Caminho = 0.1 }
		local quatro = Pen.atravessar(45, { vidro, vidro, vidro, vidro })
		t.falso(quatro.Parou, "4 vidros passa")
		local cinco = Pen.atravessar(45, { vidro, vidro, vidro, vidro, vidro })
		t.verdade(cinco.Parou, "5 vidros para")
		t.igual(cinco.Atravessou, 4, "atravessou 4")
	end,
}
