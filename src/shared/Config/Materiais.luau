--!strict
-- Penetração por material (documento de projeto, seção Penetração por material).
-- Regra: custo = resistência × caminho percorrido dentro da peça (studs).
-- O caminho é medido com raio de entrada e de saída no colisor balístico (decisão v3).

export type Material = {
	Resistencia: number, -- por stud
	Efeito: string,
}

local Materiais: { [string]: Material } = {
	Vidro = { Resistencia = 2, Efeito = "Cacos" },
	Tecido = { Resistencia = 3, Efeito = "PoeiraTecido" },
	Plastico = { Resistencia = 6, Efeito = "LascaPequena" },
	Gesso = { Resistencia = 8, Efeito = "PoeiraBranca" }, -- se a parede não proteger nada, subir pra 14 (M4a)
	Madeira = { Resistencia = 14, Efeito = "Lascas" },
	MetalFino = { Resistencia = 60, Efeito = "Faisca" },
	ChapaGrossa = { Resistencia = 80, Efeito = "FaiscaForte" },
	Tijolo = { Resistencia = 50, Efeito = "PoeiraVermelha" },
	Concreto = { Resistencia = 70, Efeito = "PoeiraCinza" },
	Pedra = { Resistencia = 80, Efeito = "Poeira" },
}

-- Material do Roblox → material balístico. O atributo "Balistico" na peça manda mais que isto.
local DoRoblox: { [string]: string } = {
	Glass = "Vidro",
	Fabric = "Tecido",
	Plastic = "Plastico",
	SmoothPlastic = "Plastico",
	Wood = "Madeira",
	WoodPlanks = "Madeira",
	Metal = "MetalFino",
	Foil = "MetalFino",
	DiamondPlate = "ChapaGrossa",
	CorrodedMetal = "ChapaGrossa",
	Brick = "Tijolo",
	Concrete = "Concreto",
	Granite = "Pedra",
	Marble = "Pedra",
	Slate = "Pedra",
	Cobblestone = "Pedra",
}

return {
	Lista = Materiais,
	DoRoblox = DoRoblox,
	CustoCorpo = 6, -- por personagem atravessado, não por membro
	MaxPecas = 4,
	AtributoMaterial = "Balistico", -- atributo da peça que força o material (ex.: "Gesso")
}
