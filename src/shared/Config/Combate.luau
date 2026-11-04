--!strict
-- Dano, derrubada, prisão, supressão e regras de rede do tiro.

local Combate = {}

Combate.GravidadeBala = 35 -- studs/s² (9,8 m/s²)

Combate.MultParte = {
	Cabeca = 4,
	PescocoPeito = 1.3,
	Tronco = 1,
	Braco = 0.6,
	Perna = 0.7,
}

-- Tiro direto na cabeça mata com qualquer arma.
-- Atravessando parede, a cabeça usa a fórmula normal (decisão v3).
Combate.CabecaDiretaMata = true

Combate.EfeitosParte = {
	Braco = { DispersaoMult = 1.5, Duracao = 15 },
	Perna = { VelocidadeMult = 0.7, SemCorrer = true, Duracao = 20 },
}

Combate.Derrubada = {
	TempoMinimoNoChao = 3,
}

Combate.Prisao = {
	Distancia = 4, -- studs, mãos vazias
	Tempo = 1.5, -- segurar
	DesistirApertos = 5, -- espaço 5 vezes = morre
}

Combate.Supressao = {
	RaioCabeca = 4, -- studs do caminho da bala
	PorBala = 10,
	QuedaPorSegundo = 20,
	LimiarEfeito = 50,
	Max = 100,
}

Combate.FogoAmigo = true

-- Decisões em aberto, ligadas por chave (testar no M7, decidir no M9).
Combate.Abertas = {
	TirosTroncoAlvo = 3, -- 3 ou 2
	ColeteGuardas = false,
	SomDeAcertoPraAtirador = true, -- está na lista de corte
}

-- Regras de rede do tiro (decisões v3).
Combate.Rede = {
	VoltaNoTempoMax = 0.25, -- s
	HistoricoHitbox = 1.2, -- s guardados
	ToleranciaInstante = 0.05, -- diferença aceita entre o instante do cliente e a estimativa do servidor
	ToleranciaOrigem = 1.5, -- studs entre a cabeça e a origem do tiro
	IntervaloMinimoFracao = 0.8, -- tiro mais rápido que 80% do intervalo da cadência é recusado
	RecusasPraExpulsar = 3, -- recusas graves...
	JanelaRecusas = 10, -- ...em 10 s
}

return Combate
