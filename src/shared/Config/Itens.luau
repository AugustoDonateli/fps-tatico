--!strict
-- Kit inicial, números dos itens e portas trancadas (documento de projeto, seção Itens).

local Itens = {}

Itens.Kit = {
	Guardas = {
		Principal = "Submetralhadora",
		Pistola = "Pistola45",
		Itens = { Radio = 1, CameraVara = 1, Sensor = 2, Carga = 1, Chave = 1 },
	},
	Intrusos = {
		Principal = nil :: string?,
		Pistola = "Pistola9",
		Itens = { Radio = 1, CameraVara = 1, Lockpick = 1, Carga = 1 },
	},
}

Itens.CameraVara = {
	Alcance = 2.5, -- studs, passa por baixo de porta
	PretoEBranco = true,
	PersonagemParado = true,
	TelaCheia = true, -- decisão v3 (prova P2)
}

Itens.Sensor = {
	Cone = 12, -- studs
	SoDonoOuve = true,
	DeitadoParadoNaoDispara = true,
	AliadoDispara = true,
	DuraRodadaToda = true,
}

Itens.Carga = {
	Raio = 8,
	DanoCentro = 80,
	DanoBorda = 10,
	DerrubaNoRaio = true,
	GrudarSegundos = 1,
	ParedeBloqueia = true, -- decisão v3
}

Itens.Lockpick = {
	Pinos = 5,
	CliqueErroAlcance = 20, -- studs
	ErroSoltaPinos = 1,
	TempoTipico = { 8, 15 }, -- s
	FechaSeOutroAbrir = true,
}

Itens.Radio = {
	AlcanceInfinito = true,
	FalarNoRadioOuveSePerto = true,
}

Itens.Portas = {
	FracaoTrancadas = 0.3, -- das portas internas marcadas como "trancável"
	ChaveSegurando = 1, -- s
	AnguloMax = 110, -- graus
}

return Itens
