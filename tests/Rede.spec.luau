return {
	["validador aceita tiro certo"] = function(t, Shared)
		local R = require(Shared.Net.Remotes)
		local ok, motivo = R.validar("Atirar", 1, "Submetralhadora", Vector3.new(0, 5, 0), Vector3.new(0, 0, -1), 1000)
		t.verdade(ok, "aceitou (" .. tostring(motivo) .. ")")
	end,

	["validador recusa lixo"] = function(t, Shared)
		local R = require(Shared.Net.Remotes)
		local nan = 0 / 0
		local inf = math.huge
		local origem = Vector3.new(0, 5, 0)
		local dir = Vector3.new(0, 0, -1)
		t.falso(R.validar("Atirar", nan, "Submetralhadora", origem, dir, 1000), "NaN no número")
		t.falso(R.validar("Atirar", 1.5, "Submetralhadora", origem, dir, 1000), "número quebrado")
		t.falso(R.validar("Atirar", 1, "Bazuca", origem, dir, 1000), "arma que não existe")
		t.falso(R.validar("Atirar", 1, "Submetralhadora", Vector3.new(nan, 0, 0), dir, 1000), "NaN na origem")
		t.falso(R.validar("Atirar", 1, "Submetralhadora", Vector3.new(inf, 0, 0), dir, 1000), "infinito na origem")
		t.falso(R.validar("Atirar", 1, "Submetralhadora", origem, Vector3.new(0, 0, -5), 1000), "direção sem tamanho 1")
		t.falso(R.validar("Atirar", 1, "Submetralhadora", origem, dir, inf), "instante infinito")
		t.falso(R.validar("Atirar", 1, "Submetralhadora", origem, dir), "faltou argumento")
		t.falso(R.validar("Atirar", 1, "Submetralhadora", origem, dir, 1000, "extra"), "argumento a mais")
		t.falso(R.validar("Equipar", 8), "espaço 8")
		t.falso(R.validar("Equipar", "1"), "texto no lugar de número")
		t.falso(R.validar("MoverPorta", workspace, 200), "porta além de 110")
		t.falso(R.validar("NaoExiste"), "remote desconhecido")
		t.verdade(R.validar("Largar"), "remote sem argumento")
	end,

	["limitador por segundo"] = function(t, Shared)
		local Limitador = require(Shared.Util.Limitador)
		local agora = 0
		local lim = Limitador.novo(2, 2, function()
			return agora
		end)
		t.verdade(lim:permitir("a"), "1ª")
		t.verdade(lim:permitir("a"), "2ª")
		t.falso(lim:permitir("a"), "3ª no mesmo instante")
		t.verdade(lim:permitir("b"), "outro jogador tem balde próprio")
		agora = 0.5
		t.verdade(lim:permitir("a"), "meio segundo depois volta 1 ficha")
		t.falso(lim:permitir("a"), "só 1")
	end,
}
