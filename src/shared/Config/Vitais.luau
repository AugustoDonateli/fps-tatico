--!strict
-- Vida, energia, equilíbrio e sangramento (documento de projeto, seções Personagem e Dano).

local Vitais = {}

Vitais.VidaMax = 100

Vitais.Energia = {
	Max = 100,
	CorrerPorSegundo = 12,
	Pulo = 15,
	RastejarPorSegundo = 4, -- rastejar gasta e não recupera (decisão v3)
	TiroAutomatico = 1, -- por tiro
	LevantarMinimo = 20,
	LevantarCusto = 20,
	RecuperaParadoEmPe = 15,
	RecuperaAndando = 8,
	RecuperaAgachado = 6,
	RecuperaDeitadoParado = 4,
	LimiarCansado = 25, -- abaixo: respiração alta, balanço 2×, não corre
	VoltaACorrer = 40, -- depois de cansar, só corre de novo com 40 (evita liga e desliga)
	BalancoArmaCansado = 2,
	SupressaoPorBala = 5, -- cada bala que passa perto tira energia
}

Vitais.Equilibrio = {
	Max = 100,
	RecuperaPorSegundo = 40,
	AtrasoRecuperacao = 1, -- s depois da última perda (decisão v3, ajustável)
	Perdas = {
		TiroTronco = 35,
		TiroPerna = 50,
		Explosao = 100,
		Empurrao = 60,
		BeiradaPorSegundo = 20,
	},
	-- Banana e escopeta derrubam na hora, sem cálculo.
	DerrubaSempre = { Banana = true, Escopeta = true },
	MultPostura = {
		Correndo = 1.5,
		EmPe = 1,
		Agachado = 0.6,
		Deitado = 0.3,
	},
}

Vitais.Sangramento = {
	Limiar = 50, -- abaixo disso começa a sangrar
	PerdaPorSegundo = 1,
	Piso = 35, -- para de perder ao chegar aqui (nunca cura)
	GotaACadaStuds = 2,
	BordaEscuraAbaixo = 25,
}

return Vitais
