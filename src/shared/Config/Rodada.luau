--!strict
-- Rodada e partida (documento de projeto, seção Rodada e partida). Tempos em segundos.

local Rodada = {}

Rodada.Jogadores = {
	PorTime = 5, -- 5 contra 5 ou 6 contra 6, fechar no teste (4 contra 4 também é aceito)
	PorTimeAceitos = { 4, 5, 6 },
	MinimoPraComecar = 2, -- 1 contra 1, pra teste
}

Rodada.Formatos = {
	Padrao = { Rodadas = 6, Acao = 360, TrocaDeLadoApos = 3 },
	Curto = { Rodadas = 4, Acao = 240, TrocaDeLadoApos = 2 }, -- comparar no M7
}
Rodada.FormatoAtual = "Padrao"

Rodada.Preparacao = 25
Rodada.Intervalo = 12
Rodada.Empate = "RodadaExtraLadoSorteado"
Rodada.TempoExtraComMaleta = 30 -- máximo de segundos extras se o tempo acabar com a maleta nas costas
Rodada.EntrouNoMeio = "Espectador" -- espera a próxima rodada

Rodada.Mortos = {
	VeSoAliadosVivos = true,
	FalaSoComMortos = true,
	NomesSoNoIntervalo = true, -- sem lista de abates
	MiraEspectadorPorSegundo = 10,
}

return Rodada
