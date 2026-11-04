--!strict
-- Escala e medidas do mapa (documento de projeto, seções Escala e Mapa da fatia).

return {
	Stud = 0.28, -- metros
	AlturaPersonagem = 6.3,
	PeDireito = 10,
	Porta = { Largura = 3.2, Altura = 7.5 }, -- fora da grade de 0,5: usa módulo de vão próprio
	ParedeInterna = 0.5,
	ParedeExterna = 1,
	Grade = 0.5,

	CasaDaSerra = {
		Terreno = { 260, 200 },
		Casa = { 90, 60 }, -- 2 andares + porão
		Anexo = { 50, 40 }, -- etapa 2
		Passarela = 30, -- etapa 2
		Lago = { 60, 40 }, -- etapa 2
		LugaresMaletaEtapa1 = { "Escritorio", "Adega", "Garagem" },
		LugaresMaletaEtapa2 = { "Escritorio", "Adega", "Garagem", "EstudioAnexo" },
		PortasTrancaveis = 8,
		LuzesQueQuebram = 6,
		Horario = "FimDeTarde",
		MetasTempo = { -- segundos andando
			IntrusosAteEntrada = { 15, 20 },
			GuardasAteMaleta = { 0, 15 },
			MaletaAteExtracao = { 20, 30 },
		},
		MaiorLinhaDeVisao = 150, -- studs
		CoberturasPorComodo = 2,
		EscopetaDoSpawnIntruso = 20, -- s andando, no máximo
	},
}
