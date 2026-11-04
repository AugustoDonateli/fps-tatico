return {
	["cone de dispersão"] = function(t, Shared)
		local D = require(Shared.Sim.Dispersao)
		t.perto(D.cone("Submetralhadora", { Mirando = true }) :: number, 0.3, 1e-6, "SMG mirando parado")
		t.perto(D.cone("Pistola45", { Mirando = true }) :: number, 0.5, 1e-6, "pistola mirando parado")
		t.perto(D.cone("Submetralhadora", { Movendo = true, Postura = "Agachado" }) :: number, 3.15, 1e-6, "sem mirar andando agachado")
		t.perto(D.cone("Pistola9", { Mirando = true, Postura = "Deitado", Cansado = true }) :: number, 0.5, 1e-6, "deitado cansado")
		t.perto(D.cone("Submetralhadora", { BracoFerido = true }) :: number, 4.5, 1e-6, "braço ferido")
		t.igual(D.cone("Submetralhadora", { Correndo = true }), nil, "correndo não atira")
	end,

	["desvio fica no cone e repete com a mesma semente"] = function(t, Shared)
		local D = require(Shared.Sim.Dispersao)
		local a1, b1 = D.desvio(1234, 7, 3)
		local a2, b2 = D.desvio(1234, 7, 3)
		t.igual(a1, a2, "lado igual")
		t.igual(b1, b2, "cima igual")
		for n = 1, 500 do
			local lado, cima = D.desvio(99, n, 3)
			t.verdade(math.sqrt(lado * lado + cima * cima) <= 3 + 1e-9, "tiro " .. n .. " dentro do cone")
		end
		local dir = D.aplicar(Vector3.new(0, 0, -1), 0, 0)
		t.perto((dir - Vector3.new(0, 0, -1)).Magnitude, 0, 1e-6, "desvio zero não muda")
		local dir2 = D.aplicar(Vector3.new(0, 0, -1), 3, 0)
		t.perto(math.deg(math.acos(dir2:Dot(Vector3.new(0, 0, -1)))), 3, 1e-4, "3 graus de lado")
	end,

	["recarga"] = function(t, Shared)
		local M = require(Shared.Sim.Municao)
		local e = M.inicial("Submetralhadora")
		t.igual(e.NoArma, 30, "pente cheio")
		t.igual(#e.Pentes, 3, "3 pentes no bolso")
		t.igual(M.tempoRecarga("Submetralhadora", { NoArma = 5, Pentes = { 30 } }), 2.6, "com bala")
		t.igual(M.tempoRecarga("Submetralhadora", { NoArma = 0, Pentes = { 30 } }), 3.2, "vazio")
		-- pega o mais cheio e guarda o atual
		local novo, trocou = M.recarregar("Submetralhadora", { NoArma = 10, Pentes = { 12, 30, 20 } })
		t.verdade(trocou, "trocou")
		t.igual(novo.NoArma, 30, "pegou o de 30")
		t.igual(#novo.Pentes, 3, "guardou o de 10")
		t.verdade(table.find(novo.Pentes, 10) ~= nil, "pente de 10 no bolso")
		-- escopeta por cartucho
		t.perto(M.tempoRecarga("Escopeta", { NoArma = 2, Pentes = { 12 } }), 2.4, 1e-6, "4 cartuchos")
		local esc = M.recarregar("Escopeta", { NoArma = 2, Pentes = { 12 } })
		t.igual(esc.NoArma, 6, "escopeta cheia")
		t.igual(esc.Pentes[1], 8, "sobraram 8")
	end,

	["hitscan curvo cai com a gravidade da bala"] = function(t, Shared)
		local B = require(Shared.Sim.Balistica)
		-- 1 s de voo: cai 0,5 × 35 × 1² = 17,5 studs
		local p = B.posicao(Vector3.zero, Vector3.new(0, 0, -1), 950, 1)
		t.perto(p.Y, -17.5, 1e-6, "queda em 1 s")
		t.perto(p.Z, -950, 1e-6, "avanço em 1 s")
	end,

	["balística com raycast falso: atravessa gesso e acerta"] = function(t, Shared)
		local B = require(Shared.Sim.Balistica)
		-- Parede de gesso em z = -10, alvo em z = -20.
		local function raycast(de: Vector3, delta: Vector3, ignorar)
			local ate = de + delta
			local function cruza(z)
				return de.Z > z and ate.Z <= z
			end
			if cruza(-10) and not table.find(ignorar, "parede") then
				return { Posicao = Vector3.new(de.X, de.Y, -10), Instancia = nil, Material = "Gesso", _id = "parede" }
			end
			if cruza(-20) and not table.find(ignorar, "alvo") then
				return { Posicao = Vector3.new(de.X, de.Y, -20), Personagem = "alvo", Parte = "Tronco" }
			end
			return nil
		end
		local function medir()
			return 0.5
		end
		-- a parede não tem Instancia, então marcamos o ignorar por fora
		local function raycastComIgnorar(de, delta, ignorar)
			local r = raycast(de, delta, ignorar)
			if r and r._id == "parede" then
				table.insert(ignorar, "parede")
			end
			return r
		end
		local r = B.resolver(Vector3.zero, Vector3.new(0, 0, -1), "Submetralhadora", raycastComIgnorar, medir)
		t.igual(#r.Alvos, 1, "acertou 1 alvo")
		t.igual(#r.Impactos, 1, "1 impacto na parede")
		if r.Alvos[1] then
			t.perto(r.Alvos[1].ForcaFinal, 8, 1e-6, "chegou com força 8")
			t.falso(r.Alvos[1].Direto, "não foi direto")
		end
	end,
}
