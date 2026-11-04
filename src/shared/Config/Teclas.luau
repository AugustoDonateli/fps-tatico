--!strict
-- Controles no PC (documento de projeto, seção Controles). Todas podem ser trocadas.
-- O EntradaController transforma isto em InputActions.

return {
	Andar = { "W", "A", "S", "D" },
	Correr = "LeftShift",
	AndarDevagar = "LeftAlt",
	Agachar = "C", -- alterna
	Deitar = "Z", -- alterna
	Pular = "Space", -- também levanta do chão
	InclinarEsquerda = "Q",
	InclinarDireita = "E",
	Interagir = "F", -- porta, maleta, chave (segurar quando precisa)
	AbrirPortaAosPoucos = "MouseWheel",
	Atirar = "MouseButton1", -- com as mãos: empurrar; tocar no corpo: checar; segurar: prender
	Mirar = "MouseButton2",
	Recarregar = "R", -- segurar = checar pente
	ModoTiro = "X", -- ou ligar o laser
	ArmaPrincipal = "One",
	Pistola = "Two",
	Maos = "Three",
	Itens = { "Four", "Five", "Six", "Seven" },
	Largar = "G",
	FalarProximidade = "V", -- segurar
	Radio = "B", -- segurar = falar; toque = bip
	Sinais = "T", -- toque duplo = estalar os dedos
	FingirDeMorto = "K",
	ChatTexto = "Return",
	DesligarListaPadraoTab = true,
}
