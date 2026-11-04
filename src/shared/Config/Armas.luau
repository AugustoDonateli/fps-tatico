--!strict
-- Tabela das 6 armas, precisão e recarga (documento de projeto, seção Armas).
-- Nomes provisórios e nossos. Fuzil e sniper já têm números, mas ficam fora da fatia.

export type ModoTiro = "Unico" | "Rajada2" | "Rajada3" | "Auto" | "Bomba"

export type Arma = {
	Nome: string,
	QuemUsa: string,
	Dano: number,
	Cadencia: number, -- tiros por minuto
	Modos: { ModoTiro },
	Pente: number,
	Reserva: number,
	VelocidadeBala: number, -- studs/s (só visual: o tiro é hitscan curvo)
	Forca: number, -- força de penetração
	Recuo: { Cima: number, Lado: number }, -- graus por tiro
	Recarga: { ComBala: number?, Vazio: number?, PorCartucho: number? },
	Pistola: boolean,
	NaFatia: boolean,
	Laser: boolean?,
	Silenciada: boolean?,
	DerrubaSempre: boolean?,
	ArrombaMadeira: boolean?,
}

local Armas: { [string]: Arma } = {
	Submetralhadora = {
		Nome = "Submetralhadora .45",
		QuemUsa = "Guardas",
		Dano = 34,
		Cadencia = 900,
		Modos = { "Unico", "Rajada2", "Auto" },
		Pente = 30,
		Reserva = 90,
		VelocidadeBala = 950,
		Forca = 12,
		Recuo = { Cima = 1.1, Lado = 0.5 },
		Recarga = { ComBala = 2.6, Vazio = 3.2 },
		Pistola = false,
		NaFatia = true,
	},
	Pistola45 = {
		Nome = "Pistola .45 com laser",
		QuemUsa = "Guardas",
		Dano = 36,
		Cadencia = 400,
		Modos = { "Unico" },
		Pente = 12,
		Reserva = 36,
		VelocidadeBala = 900,
		Forca = 11,
		Recuo = { Cima = 2.5, Lado = 0 },
		Recarga = { ComBala = 1.8, Vazio = 2.3 },
		Pistola = true,
		NaFatia = true,
		Laser = true,
	},
	Pistola9 = {
		Nome = "Pistola 9 mm silenciada",
		QuemUsa = "Intrusos",
		Dano = 30,
		Cadencia = 400,
		Modos = { "Unico" },
		Pente = 15,
		Reserva = 45,
		VelocidadeBala = 1050,
		Forca = 10,
		Recuo = { Cima = 2.0, Lado = 0 },
		Recarga = { ComBala = 1.8, Vazio = 2.3 },
		Pistola = true,
		NaFatia = true,
		Silenciada = true,
	},
	Escopeta = {
		Nome = "Escopeta (balote)",
		QuemUsa = "Pega no mapa",
		Dano = 90,
		Cadencia = 70,
		Modos = { "Bomba" },
		Pente = 6,
		Reserva = 12,
		VelocidadeBala = 1500,
		Forca = 20,
		Recuo = { Cima = 6, Lado = 0 },
		Recarga = { PorCartucho = 0.6 },
		Pistola = false,
		NaFatia = true,
		DerrubaSempre = true,
		ArrombaMadeira = true,
	},
	Fuzil = {
		Nome = "Fuzil",
		QuemUsa = "Pega no mapa",
		Dano = 40,
		Cadencia = 1200,
		Modos = { "Rajada3", "Unico" },
		Pente = 30,
		Reserva = 60,
		VelocidadeBala = 2800,
		Forca = 25,
		Recuo = { Cima = 1.4, Lado = 0 },
		Recarga = { ComBala = 2.8, Vazio = 3.4 },
		Pistola = false,
		NaFatia = false,
	},
	Sniper = {
		Nome = "Sniper",
		QuemUsa = "Estojo com código",
		Dano = 120,
		Cadencia = 60,
		Modos = { "Unico" },
		Pente = 5,
		Reserva = 10,
		VelocidadeBala = 3000,
		Forca = 45,
		Recuo = { Cima = 8, Lado = 0 },
		Recarga = { ComBala = 3.0, Vazio = 3.8 },
		Pistola = false,
		NaFatia = false,
	},
}

-- Precisão (dispersão em graus).
local Precisao = {
	MirandoParado = 0.3,
	MirandoParadoPistola = 0.5,
	SemMirarParado = 3,
	AndandoSoma = 1.5,
	MultAgachado = 0.7, -- −30%
	MultDeitado = 0.5, -- −50%
	MultCansado = 2, -- energia abaixo de 25
	-- Correndo: não atira (arma abaixada).
}

return {
	Lista = Armas,
	Precisao = Precisao,
	-- Na próxima recarga, o jogo pega o pente mais cheio.
	RecargaPegaPenteMaisCheio = true,
	-- Um tiro de escopeta na maçaneta abre porta trancada de madeira. Metal não abre.
	EscopetaAbreMadeira = true,
}
