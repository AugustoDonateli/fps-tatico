--!strict
-- Números de movimento do documento de projeto (seção Personagem).
-- 1 stud = 0,28 m. Velocidades em studs por segundo.

local Movimento = {}

Movimento.Velocidades = {
	Correr = 16,
	Andar = 9,
	AndarDevagar = 4.5,
	Agachado = 4.5,
	AgachadoDevagar = 2.5,
	Deitado = 1.5,
	Escada = 5,
	Nadar = 5,
	NadarRapido = 8,
}

-- Multiplicadores que se somam por multiplicação.
Movimento.Multiplicadores = {
	Mirando = 0.7, -- mirando, a velocidade cai 30%
	CarregandoMaleta = 0.85, -- carregando maleta, cai 15% e não corre
	PernaFerida = 0.7, -- tiro na perna: −30% por 20 s (ver Combate.EfeitosParte)
}

Movimento.Queda = {
	SemDanoAte = 14, -- studs (4 m)
	DanoPorStudAcima = 3,
	MorteAcima = 32, -- studs (9 m)
}

Movimento.Inclinar = {
	Deslocamento = 1.5, -- studs pro lado
	Angulo = 15, -- graus
}

Movimento.AlturaPersonagem = 6.3 -- studs (1,76 m)
Movimento.GravidadePersonagem = 196.2 -- padrão do Roblox

return Movimento
