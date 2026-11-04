--!strict
-- Alcance dos barulhos (documento de projeto, seção Som): 18 linhas.
-- Alcance em studs. 0 = silencioso. Confiavel = vai por evento confiável (som tático).

export type Barulho = {
	Alcance: number,
	Confiavel: boolean,
	SoDono: boolean?,
}

local Barulhos: { [string]: Barulho } = {
	TiroNormal = { Alcance = 600, Confiavel = true },
	TiroSilenciado = { Alcance = 35, Confiavel = true },
	Explosao = { Alcance = 800, Confiavel = true },
	VidroQuebrando = { Alcance = 80, Confiavel = true },
	PortaBatendo = { Alcance = 60, Confiavel = true },
	PortaAbertaRapido = { Alcance = 30, Confiavel = true },
	PortaAbertaDevagar = { Alcance = 0, Confiavel = true },
	PassosCorrendo = { Alcance = 45, Confiavel = false },
	PassosAndando = { Alcance = 25, Confiavel = false },
	PassosDevagarAgachado = { Alcance = 8, Confiavel = false },
	Deitado = { Alcance = 0, Confiavel = false },
	PousoPulo = { Alcance = 30, Confiavel = false },
	Splash = { Alcance = 50, Confiavel = true },
	CliqueLockpick = { Alcance = 20, Confiavel = true },
	Respiracao = { Alcance = 12, Confiavel = false },
	Voz = { Alcance = 40, Confiavel = true }, -- proximidade, via VozService
	BipSensor = { Alcance = 0, Confiavel = true, SoDono = true }, -- só no rádio do dono
	Cartucho = { Alcance = 15, Confiavel = false },
}

return {
	Lista = Barulhos,
	ParedeFator = 0.5, -- parede no caminho corta o volume pela metade (se a P3 não escolher a acústica nativa)
	TremorExplosaoAte = 40, -- studs
	SonsTocandoMax = 32, -- por cliente
	EfeitoTiroAlcance = 150, -- studs: impactos e faíscas só pra quem está perto
}
