return {
	["velocidades base"] = function(t, Shared)
		local Mov = require(Shared.Sim.Movimento)
		t.igual(Mov.velocidade({ Modo = "Correr" }), 16, "correr")
		t.igual(Mov.velocidade({ Modo = "Andar" }), 9, "andar")
		t.igual(Mov.velocidade({ Modo = "Agachado" }), 4.5, "agachado")
		t.igual(Mov.velocidade({ Modo = "Deitado" }), 1.5, "deitado")
		t.igual(Mov.velocidade({ Modo = "Andar", Parado = true }), 0, "parado")
	end,

	["multiplicadores"] = function(t, Shared)
		local Mov = require(Shared.Sim.Movimento)
		t.perto(Mov.velocidade({ Modo = "Andar", Mirando = true }), 6.3, 1e-6, "mirando")
		t.perto(Mov.velocidade({ Modo = "Andar", Mirando = true, Maleta = true }), 5.355, 1e-6, "mirando + maleta")
		t.perto(Mov.velocidade({ Modo = "Agachado", PernaFerida = true }), 3.15, 1e-6, "perna ferida")
	end,

	["quem não pode correr anda"] = function(t, Shared)
		local Mov = require(Shared.Sim.Movimento)
		t.igual(Mov.velocidade({ Modo = "Correr", Maleta = true }), 9 * 0.85, "maleta")
		t.igual(Mov.velocidade({ Modo = "Correr", Energia = 20 }), 9, "cansado")
		t.igual(Mov.velocidade({ Modo = "Correr", PernaFerida = true }), 9 * 0.7, "perna")
	end,

	["energia"] = function(t, Shared)
		local Mov = require(Shared.Sim.Movimento)
		t.perto(Mov.passoEnergia(100, { Modo = "Correr" }, 2), 76, 1e-6, "correr 2 s")
		t.perto(Mov.passoEnergia(50, { Modo = "Deitado" }, 5), 30, 1e-6, "rastejar 5 s gasta")
		t.perto(Mov.passoEnergia(50, { Modo = "Deitado", Parado = true }, 1), 54, 1e-6, "deitado parado")
		t.perto(Mov.passoEnergia(50, { Modo = "Andar", Parado = true }, 1), 65, 1e-6, "parado em pé")
		t.perto(Mov.passoEnergia(50, { Modo = "Andar" }, 1), 58, 1e-6, "andando")
		t.perto(Mov.passoEnergia(50, { Modo = "Agachado" }, 1), 56, 1e-6, "agachado")
		t.igual(Mov.passoEnergia(99, { Modo = "Andar", Parado = true }, 1), 100, "não passa de 100")
		t.igual(Mov.passoEnergia(5, { Modo = "Correr" }, 1), 0, "não fica negativa")
	end,

	["equilíbrio"] = function(t, Shared)
		local Mov = require(Shared.Sim.Movimento)
		t.igual(Mov.passoEquilibrio(50, 0.5, 1), 50, "antes de 1 s não recupera")
		t.igual(Mov.passoEquilibrio(50, 1.0, 0.5), 70, "depois recupera 40/s")
		t.perto(Mov.perdaEquilibrio("TiroTronco", "Agachado"), 21, 1e-6, "tronco agachado")
		t.perto(Mov.perdaEquilibrio("TiroPerna", "Correndo"), 75, 1e-6, "perna correndo")
		local _, caiu = Mov.aplicarPerda(100, "Escopeta", "Deitado")
		t.verdade(caiu, "escopeta derruba sempre")
		local novo, caiu2 = Mov.aplicarPerda(100, "TiroTronco", "EmPe")
		t.igual(novo, 65, "tronco em pé")
		t.falso(caiu2, "não caiu")
		local _, caiu3 = Mov.aplicarPerda(40, "TiroPerna", "EmPe")
		t.verdade(caiu3, "perna com 40 de equilíbrio derruba")
	end,
}
