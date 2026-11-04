--!strict
-- Maleta e extração (documento de projeto, seção Maleta e extração).

return {
	MaletasAtivas = 2, -- sorteadas entre os lugares possíveis (4 no mapa completo, 3 na etapa 1)
	PegarSegurando = 1.5, -- s segurando F
	VelocidadeCarregando = 0.85, -- −15%, não corre
	SoPistolaCarregando = true,
	TeclaLargar = "G",
	DevolverSegurando = 3, -- Guardas devolvem a maleta largada
	Extracoes = 2,
	ExtrairSegundos = 3, -- ficar dentro da zona com a maleta
	IntrusosVeemLugaresNaPreparacao = true, -- decisão v2/v3, chave liga e desliga
}
