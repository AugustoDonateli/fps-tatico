--!strict
-- M2: mapa cinza da casa de praia (planta própria, docs/mapa/planta-praia.png e andares-praia.png).
-- Só estrutura e rotas, sem acabamento. Rodar no Studio (Edit) pelo MCP:
--   require(game.ServerStorage.Dev.Mapa.Praia).construir()
-- Eixos: +X leste, +Z sul (mar). Rua +11, jardim/terraço 0, praia −6, porão −11, telhado 22.

local Kit = require(script.Parent.Kit)

local Praia = {}

local function g(c: number, bal: string): Kit.Estilo
	return { Cor = Color3.fromRGB(c, c, c + 4), Mat = Enum.Material.SmoothPlastic, Bal = bal }
end
local EXT = g(176, "Concreto")
local INT = g(206, "Gesso")
local PISO = g(140, "Concreto")
local CHAO = g(120, "Pedra")
local ROCHA = g(100, "Pedra")
local ESC = { Cor = Color3.fromRGB(150, 128, 104), Mat = Enum.Material.SmoothPlastic, Bal = "Madeira" }
local AREIA = { Cor = Color3.fromRGB(196, 186, 156), Mat = Enum.Material.SmoothPlastic, Bal = "Pedra" }
local TUNEL = g(90, "Concreto")
local VIDRO = Kit.E.Vidro

local P, PA = 3.2, 7.5
local function porta(c: number, y: number, nome: string?): Kit.Abertura
	return { c = c, w = P, y0 = y, y1 = y + PA, tipo = "vao", nome = nome }
end
local function vao(c: number, w: number, y0: number, y1: number, nome: string?): Kit.Abertura
	return { c = c, w = w, y0 = y0, y1 = y1, tipo = "vao", nome = nome }
end
local function vidro(c: number, w: number, y0: number, y1: number): Kit.Abertura
	return { c = c, w = w, y0 = y0, y1 = y1, tipo = "janela" }
end
local function pasta(pai: Instance, nome: string): Folder
	local f = Instance.new("Folder")
	f.Name = nome
	f.Parent = pai
	return f
end

-- Escada em x (sobe de xIni a xFim) ou em z.
local function escada(pai: Instance, eixo: "x" | "z", a1: number, a2: number, ini: number, fim: number, y0: number, y1: number, n: number)
	local d = (fim - ini) / n
	local dy = (y1 - y0) / n
	for i = 1, n do
		local p = ini + d * (i - 1)
		if eixo == "z" then
			Kit.caixa(pai, "Degrau", a1, y0, p, a2, y0 + dy * i, p + d, ESC)
		else
			Kit.caixa(pai, "Degrau", p, y0, a1, p + d, y0 + dy * i, a2, ESC)
		end
	end
end

-- Túnel retangular (piso, teto, 2 lados) ao longo de x ou z.
local function tunel(pai: Instance, eixo: "x" | "z", a: number, b: number, c1: number, c2: number, y0: number, alt: number)
	if eixo == "x" then
		Kit.caixa(pai, "Piso", a, y0 - 1, c1 - 1, b, y0, c2 + 1, TUNEL)
		Kit.caixa(pai, "Teto", a, y0 + alt, c1 - 1, b, y0 + alt + 1, c2 + 1, TUNEL)
		Kit.caixa(pai, "Lado", a, y0, c1 - 1, b, y0 + alt, c1, TUNEL)
		Kit.caixa(pai, "Lado", a, y0, c2, b, y0 + alt, c2 + 1, TUNEL)
	else
		Kit.caixa(pai, "Piso", c1 - 1, y0 - 1, a, c2 + 1, y0, b, TUNEL)
		Kit.caixa(pai, "Teto", c1 - 1, y0 + alt, a, c2 + 1, y0 + alt + 1, b, TUNEL)
		Kit.caixa(pai, "Lado", c1 - 1, y0, a, c1, y0 + alt, b, TUNEL)
		Kit.caixa(pai, "Lado", c2, y0, a, c2 + 1, y0 + alt, b, TUNEL)
	end
end

local function trelica(pai: Instance, nome: string, x: number, z: number, y0: number, y1: number)
	local t = Instance.new("TrussPart")
	t.Name = nome
	t.Anchored = true
	t.Size = Vector3.new(2, y1 - y0, 2)
	t.CFrame = CFrame.new(x, (y0 + y1) / 2, z)
	t.Color = Color3.fromRGB(80, 80, 84)
	t.Parent = pai
end

local function rotulo(pai: Instance, texto: string, pos: Vector3)
	local p = Instance.new("Part")
	p.Name = "Rotulo_" .. texto
	p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.Transparency = true, false, false, false, 1
	p.Size = Vector3.new(1, 1, 1)
	p.CFrame = CFrame.new(pos)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(160, 30)
	bb.AlwaysOnTop = false
	bb.MaxDistance = 60
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.fromScale(1, 1)
	tl.BackgroundTransparency = 1
	tl.Text = texto
	tl.TextColor3 = Color3.fromRGB(40, 40, 40)
	tl.TextStrokeTransparency = 0.6
	tl.TextStrokeColor3 = Color3.new(1, 1, 1)
	tl.Font = Enum.Font.GothamBold
	tl.TextScaled = true
	tl.Parent = bb
	bb.Parent = p
	p.Parent = pai
end

-- Boneco de escala (6,3 studs).
local function boneco(pai: Instance, x: number, y: number, z: number)
	Kit.caixa(pai, "Boneco6_3", x - 0.9, y, z - 0.5, x + 0.9, y + 6.3, z + 0.5, { Cor = Color3.fromRGB(230, 120, 40), Mat = Enum.Material.SmoothPlastic }, { Colide = false })
end

----------------------------------------------------------------------------------------------------
local function terreno(pai: Instance)
	local f = pasta(pai, "Terreno")
	-- platô da rua (+11). Desce até z -14 (oeste), -6 (atrás da ala da cozinha) e -10 (casa e garagem).
	Kit.caixa(f, "PlatoRua", -150, -1, -110, 48, 11, -14, CHAO)
	Kit.caixa(f, "PlatoAla", -44, -1, -14, -20, 11, -6, CHAO)
	Kit.caixa(f, "PlatoCasa", -20, -1, -14, 48, 11, -10, CHAO)
	Kit.caixa(f, "Estrada", -150, 11, -110, 150, 11.1, -90, g(70, "Pedra"), { Sombra = false })
	-- jardim/terraço (0): com buracos do porão, da piscina e do túnel do deque
	Kit.laje(f, "Jardim", -150, -14, 48, 40, -1, 0, {
		{ -20, -6, 20, 18 }, { -14, 18, 14, 36 }, { -44, -6, -20, 14 }, { 20, -10, 28, 2 }, { -14, 24, 14, 32 },
	}, CHAO)
	-- praia (−6) e degraus do terraço até a praia
	Kit.caixa(f, "MuroPraia", -150, -6, 40, 48, 0, 41, EXT)
	Kit.caixa(f, "Praia", -150, -7, 41, 70, -6, 78, AREIA)
	escada(f, "z", -40, -34, 47, 41, -6, 0, 8) -- escada da praia pro terraço (oeste)
	escada(f, "z", 34, 40, 47, 41, -6, 0, 8) -- escada da praia pro terraço (leste)
	-- escada do jardim até a rua (oeste)
	escada(f, "z", -64, -58, -2, -14, 0, 11, 15)
	-- mar
	workspace.Terrain:FillBlock(CFrame.new(0, -11, 260), Vector3.new(900, 8, 364), Enum.Material.Water)
	workspace.Terrain:FillBlock(CFrame.new(0, -17, 260), Vector3.new(900, 4, 364), Enum.Material.Sand)
	-- penhasco em 3 degraus (12, 24, 34) com rampas
	Kit.caixa(f, "Penhasco1", 48, -1, -60, 72, 12, 72, ROCHA)
	Kit.caixa(f, "Penhasco2", 72, -1, -60, 100, 24, 72, ROCHA)
	Kit.caixa(f, "Penhasco3", 100, -1, -60, 150, 34, 72, ROCHA)
	Kit.caixa(f, "PenhascoNorte", 48, -1, -110, 150, 11, -60, CHAO)
	Kit.viga(f, "Rampa1", Vector3.new(60, 11, -72), Vector3.new(60, 12, -60), 6, 1, ROCHA)
	Kit.viga(f, "Rampa2", Vector3.new(80, 12.5, -40), Vector3.new(94, 24.5, -40), 6, 1, ROCHA)
	Kit.viga(f, "Rampa3", Vector3.new(102, 24.5, -40), Vector3.new(114, 34.5, -40), 6, 1, ROCHA)
	-- trilha estreita do penhasco até a varanda de baixo (rota 8): desce de 12 até 0 encostada na rocha
	Kit.viga(f, "Trilha", Vector3.new(66, 12, 20), Vector3.new(34, 0.3, 12), 2.4, 0.6, ROCHA)
	-- píer e barco (extração)
	Kit.caixa(f, "Pier", -72, -5.5, 52, -60, -5, 104, ESC)
	for z = 56, 102, 8 do
		Kit.caixa(f, "Estaca", -71.5, -16, z, -70.5, -5.5, z + 1, ESC)
		Kit.caixa(f, "Estaca", -61.5, -16, z, -60.5, -5.5, z + 1, ESC)
	end
	Kit.caixa(f, "Barco", -58, -7, 92, -50, -4, 108, g(220, "MetalFino"))
end

local function casa(pai: Instance)
	local f = pasta(pai, "Casa")
	local y1, yT = 11, 22
	-- PORÃO (−11)
	local por = pasta(f, "Porao")
	Kit.caixa(por, "Piso", -20, -12, -6, 20, -11, 18, PISO)
	Kit.caixa(por, "PisoMaquinas", -14, -12, 18, 14, -11, 36, PISO)
	Kit.parede(por, "N", "x", -6, -20, 20, -11, -1, 1, nil, EXT)
	Kit.parede(por, "S", "x", 18, -20, 20, -11, -1, 1, { porta(0, -11) }, EXT)
	Kit.parede(por, "O", "z", -20, -6, 18, -11, -1, 1, nil, EXT)
	Kit.parede(por, "L", "z", 20, -6, 18, -11, -1, 1, { porta(-3, -11) }, EXT)
	Kit.parede(por, "AdegaDeposito", "z", 4, -6, 18, -11, -1, 0.5, { porta(8, -11) }, INT)
	Kit.parede(por, "MaqN", "x", 22, -14, 14, -11, -1, 1, { porta(0, -11) }, EXT)
	Kit.parede(por, "MaqS", "x", 36, -14, 14, -11, -1, 1, nil, EXT)
	Kit.parede(por, "MaqO", "z", -14, 22, 36, -11, -1, 1, { vao(27.5, 3, -11, -5, "Rota5_Duto") }, EXT)
	Kit.parede(por, "MaqL", "z", 14, 22, 36, -11, -1, 1, { vao(33.5, 3, -11, -5, "Rota4_Tubo") }, EXT)
	tunel(por, "z", 18, 22, -4, 4, -11, 8) -- passagem adega ↔ casa de máquinas
	-- rota 4: tubo de drenagem até a praia (sobe de −11 pra −6)
	local tubo = pasta(f, "Rota4_Tubo")
	tunel(tubo, "x", 14, 40, 32, 35, -11, 6)
	Kit.caixa(tubo, "Grade", 40, -11, 31, 40.3, -5, 36, g(60, "MetalFino"), { Colide = false })
	tunel(tubo, "x", 40, 44, 32, 35, -11, 6)
	Kit.caixa(tubo, "Saida", 44, -7, 31, 46, -6, 36, TUNEL)
	-- rota 5: duto até a lavanderia (sobe por um poço com escada)
	local duto = pasta(f, "Rota5_Duto")
	tunel(duto, "x", -38, -14, 26, 29, -11, 6)
	tunel(duto, "z", 11, 26, -38, -35, -11, 6)
	trelica(duto, "EscadaDuto", -36.5, 12.5, -11, 0)
	-- rota 6: túnel de rastejar do deque até o alçapão da despensa
	local rast = pasta(f, "Rota6_Deque")
	tunel(rast, "z", 12, 34, -22, -19, -6, 5.5)
	trelica(rast, "SobeAlcapao", -20.5, 12.5, -6, 0)
	Kit.caixa(rast, "BocaDeque", -22, -1, 32, -19, -0.2, 34, g(60, "Madeira"), { Colide = false })

	-- TÉRREO (0) — sala/átrio, ala da cozinha, varanda
	local ter = pasta(f, "Terreo")
	Kit.laje(ter, "Piso", -44, -6, 20, 18, -1, 0, { { -20, -6, -19, -5 } }, PISO)
	Kit.caixa(ter, "PisoVaranda", 20, -1, 2, 32, 0, 18, ESC)
	Kit.parede(ter, "SalaN", "x", -10, -20, 20, 0, y1, 1, nil, EXT)
	Kit.parede(ter, "SalaS", "x", 18, -20, 20, 0, y1, 1, { vao(0, 24, 0, 8.5, "Rota9_VidroSala") }, EXT)
	Kit.caixa(ter, "VidroCorrer", -12, 0, 18.3, -4, 8.5, 18.45, VIDRO)
	Kit.parede(ter, "SalaO", "z", -20, -10, 18, 0, y1, 0.5, { porta(4, 0) }, INT)
	Kit.parede(ter, "SalaL", "z", 20, 2, 18, 0, y1, 1, { porta(10, 0) }, EXT)
	-- escada da sala ao 1º andar, junto da parede norte, subindo pro oeste
	escada(ter, "x", -9.5, -6, -6, -20, 0, y1, 15)
	-- ala da cozinha (térreo) com terraço em cima
	Kit.parede(ter, "AlaN", "x", -6, -44, -20, 0, y1, 1, nil, EXT)
	Kit.parede(ter, "AlaS", "x", 14, -44, -20, 0, y1, 1, { porta(-31, 0), vidro(-40, 4, 3, 7) }, EXT)
	Kit.parede(ter, "AlaO", "z", -44, -6, 14, 0, y1, 1, { vidro(0, 6, 3, 7.5), vao(10, 2, 2, 4.6, "Rota10_Basculante") }, EXT)
	Kit.parede(ter, "CozinhaDespensa", "z", -26, -6, 14, 0, y1, 0.5, { porta(0, 0), porta(10, 0) }, INT)
	Kit.parede(ter, "CozinhaLavand", "x", 6, -44, -26, 0, y1, 0.5, { porta(-31, 0) }, INT)
	Kit.parede(ter, "BanhoLavand", "z", -36, 6, 14, 0, y1, 0.5, { porta(10, 0) }, INT)
	Kit.laje(ter, "TerracoAla", -44, -6, -20, 14, 10, 11, { { -38, 11, -35, 14 } }, PISO)
	Kit.guardaCorpo(ter, "GuardaTerracoS", "x", 14, -44, -20, 11)
	Kit.guardaCorpo(ter, "GuardaTerracoO", "z", -44, -6, 14, 11)
	Kit.guardaCorpo(ter, "GuardaTerracoN", "x", -6, -44, -20, 11) -- separa do platô da rua
	-- alçapão na despensa (rota 6) e grade do duto na lavanderia (rota 5)
	Kit.caixa(ter, "Alcapao", -22, -0.05, 11, -19, 0.05, 14, g(60, "Madeira"), { Colide = false })
	-- terraço da piscina e deque
	local pis = pasta(f, "Piscina")
	Kit.caixa(pis, "Fundo", -14, -5, 24, 14, -4, 32, g(160, "Concreto"))
	Kit.caixa(pis, "Borda", -14, -4, 24, 14, 0, 24.5, EXT)
	Kit.caixa(pis, "Borda", -14, -4, 31.5, 14, 0, 32, EXT)
	Kit.caixa(pis, "Borda", -14, -4, 24.5, -13.5, 0, 31.5, EXT)
	Kit.caixa(pis, "Borda", 13.5, -4, 24.5, 14, 0, 31.5, EXT)
	workspace.Terrain:FillBlock(CFrame.new(0, -2.5, 28), Vector3.new(27, 3, 7), Enum.Material.Water)
	Kit.caixa(pis, "Deque", -24, 0, 32, -14, 0.4, 40, ESC)

	-- 1º ANDAR (+11): hall, quartos, escritório, galeria, suíte em balanço
	local a1 = pasta(f, "Andar1")
	Kit.laje(a1, "Piso", -20, -14, 20, 18, 10, 11, { { -12, 2, 6, 14 }, { -20, -10, -6, -6 } }, PISO)
	Kit.caixa(a1, "PisoSuite", -8, 10, 18, 12, 11, 24, PISO)
	Kit.caixa(a1, "PisoCorredor", 10, 10, -14, 20, 11, -10, PISO)
	Kit.parede(a1, "Fachada", "x", -14, -20, 20, y1, yT, 1, { porta(0, y1, "Rota2_PortaFrente") }, EXT)
	Kit.parede(a1, "HallSala", "x", -10, -20, 20, y1, yT, 0.5, { porta(0, y1), porta(15, y1) }, INT)
	Kit.parede(a1, "O", "z", -20, -10, 18, y1, yT, 1, { porta(4, y1) }, EXT)
	Kit.parede(a1, "L", "z", 20, -14, 14, y1, yT, 1, { porta(-12, y1), porta(-4, y1) }, EXT)
	Kit.parede(a1, "S", "x", 18, -20, -8, y1, yT, 1, nil, EXT)
	Kit.parede(a1, "S2", "x", 14, 12, 20, y1, yT, 1, nil, EXT)
	Kit.parede(a1, "Q1Galeria", "z", -6, -10, 2, y1, yT, 0.5, { porta(-6, y1) }, INT)
	Kit.parede(a1, "GaleriaEsc", "z", 6, -10, 2, y1, yT, 0.5, { porta(-6, y1, "Porta_Escritorio") }, INT)
	Kit.parede(a1, "Q1Sul", "x", 2, -20, -12, y1, yT, 0.5, nil, INT)
	Kit.parede(a1, "Q2", "z", 6, 2, 14, y1, yT, 0.5, { porta(8, y1) }, INT)
	Kit.parede(a1, "EscQ2", "x", 2, 6, 20, y1, yT, 0.5, nil, INT)
	Kit.parede(a1, "Q2Sul", "x", 14, 6, 20, y1, yT, 0.5, nil, INT)
	Kit.guardaCorpo(a1, "GuardaVaoO", "z", -12, 2, 14, y1)
	Kit.guardaCorpo(a1, "GuardaVaoS", "x", 14, -12, 6, y1)
	Kit.guardaCorpo(a1, "GuardaVaoN", "x", 2, -6, 6, y1)
	-- suíte: caixa de vidro em balanço
	Kit.parede(a1, "SuiteN", "x", 18, -8, 12, y1, yT, 0.5, { porta(2, y1) }, INT)
	Kit.caixa(a1, "VidroSuiteS", -8, y1, 23.85, 12, yT, 24, VIDRO)
	Kit.caixa(a1, "VidroSuiteO", -8, y1, 18, -7.85, yT, 24, VIDRO)
	Kit.caixa(a1, "VidroSuiteL", 11.85, y1, 18, 12, yT, 24, VIDRO)
	Kit.parede(a1, "Closet", "z", 8, 18, 24, y1, yT, 0.5, { porta(21, y1) }, INT)
	-- telhado (22) com claraboia sobre o vão e chegada da tirolesa
	Kit.laje(a1, "Telhado", -20, -14, 20, 18, yT, yT + 1, { { -12, 2, 6, 14 } }, EXT)
	Kit.caixa(a1, "TelhadoSuite", -8, yT, 18, 12, yT + 1, 24, EXT)
	Kit.caixa(a1, "Claraboia", -12, yT + 0.6, 2, 6, yT + 0.8, 14, VIDRO)
	Kit.caixa(a1, "Platibanda", -20, yT + 1, -14, 20, yT + 2.5, -13.5, EXT)
	Kit.caixa(a1, "Platibanda", -20, yT + 1, 17.5, 20, yT + 2.5, 18, EXT)
	Kit.caixa(a1, "Platibanda", -20.5, yT + 1, -14, -20, yT + 2.5, 18, EXT)

	-- NÚCLEO B (escada interna do porão ao telhado + escada de marinheiro por fora)
	local nb = pasta(f, "NucleoB")
	Kit.parede(nb, "N", "x", -10, 20, 28, -11, 26, 1, nil, ESC)
	Kit.parede(nb, "S", "x", 2, 20, 28, -11, 26, 1, nil, ESC)
	Kit.parede(nb, "L", "z", 28, -10, 2, -11, 26, 1, nil, ESC)
	Kit.parede(nb, "O", "z", 20, -10, 2, -11, 26, 1, { porta(-4, -11), porta(-4, y1), porta(-4, yT + 0.5) }, ESC)
	escada(nb, "z", 20.5, 24, 1.5, -9.5, -11, 0, 15)
	Kit.caixa(nb, "Patamar0", 20.5, -1, -9.5, 27.5, 0, -6, PISO)
	escada(nb, "z", 24, 27.5, -6, 1.5, 0, y1, 15)
	Kit.caixa(nb, "Patamar1", 20.5, 10, -2, 27.5, 11, 1.5, PISO)
	escada(nb, "z", 20.5, 24, -2, -9.5, y1, yT, 15)
	Kit.caixa(nb, "Patamar2", 20.5, yT - 1, -9.5, 27.5, yT, -6, PISO)
	Kit.caixa(nb, "TetoB", 20, 26, -10, 28, 27, 2, ESC)
	Kit.caixa(nb, "PassarelaTelhado", 19, yT, -6, 20, yT + 1, -2, PISO)
	trelica(nb, "Rota7_Marinheiro", 29, -4, 0, yT + 4)

	-- GARAGEM (+11) no nível da rua
	local gar = pasta(f, "Garagem")
	Kit.caixa(gar, "Piso", 20, 10, -34, 46, 11, -10, PISO)
	Kit.parede(gar, "N", "x", -34, 20, 46, y1, yT, 1, { vao(33, 12, y1, y1 + 8, "Rota3_Portao") }, EXT)
	Kit.parede(gar, "S", "x", -10, 20, 46, y1, yT, 1, nil, EXT)
	Kit.parede(gar, "O", "z", 20, -34, -10, y1, yT, 1, { porta(-12, y1) }, EXT)
	Kit.parede(gar, "L", "z", 46, -34, -10, y1, yT, 1, { porta(-20, y1, "Rota3_PortaLateral") }, EXT)
	Kit.caixa(gar, "Teto", 20, yT, -34, 46, yT + 1, -10, EXT)
	Kit.caixa(gar, "CarroBloco", 24, y1, -30, 30, y1 + 4.5, -16, g(90, "MetalFino"))
	-- pátio de entrada
	Kit.caixa(gar, "MuretaPatio", -10, y1, -34, -9.5, y1 + 3, -14, EXT)
	Kit.caixa(gar, "MuretaPatio", 9.5, y1, -34, 10, y1 + 3, -24, EXT)

	-- TORRE E TIROLESA (rota 1)
	local tor = pasta(f, "Rota1_Tirolesa")
	trelica(tor, "Torre", 92, 18, 34, 52)
	Kit.caixa(tor, "Plataforma", 89, 52, 15, 95, 53, 21, g(90, "MetalFino"))
	Kit.viga(tor, "Cabo", Vector3.new(92, 54, 18), Vector3.new(0, yT + 3, 4), 0.2, 0.2, g(30, "MetalFino"), { Colide = false })
	Kit.caixa(tor, "PosteTelhado", -0.4, yT + 1, 3.6, 0.4, yT + 3.5, 4.4, g(90, "MetalFino"))

	-- rótulos e bonecos de escala
	local r = pasta(f, "Rotulos")
	for _, l in {
		{ "Adega", 0, -8, 4 }, { "Casa de máquinas", 0, -8, 29 }, { "Sala", 0, 3, 4 }, { "Cozinha", -35, 3, 0 },
		{ "Despensa", -23, 3, 4 }, { "Banho", -40, 3, 10 }, { "Lavanderia", -31, 3, 10 }, { "Varanda", 26, 3, 10 },
		{ "Hall", 0, 14, -12 }, { "Quarto 1", -13, 14, -4 }, { "Escritório", 13, 14, -4 }, { "Quarto 2", 13, 14, 8 },
		{ "Suíte", -2, 14, 21 }, { "Garagem", 33, 14, -22 }, { "Terraço", -32, 14, 4 },
	} do
		rotulo(r, l[1] :: string, Vector3.new(l[2] :: number, l[3] :: number, l[4] :: number))
	end
	for _, b in { { 3, 0, 8 }, { -35, 0, 2 }, { 13, 11, -6 }, { -8, -11, 10 }, { 30, 11, -24 } } do
		boneco(r, b[1], b[2], b[3])
	end
end

local function marcadores(pai: Instance)
	local m = pasta(pai, "Marcadores")
	local sp = Instance.new("SpawnLocation")
	sp.Name = "Spawn_Guardas"
	sp.Anchored, sp.Neutral, sp.CanCollide, sp.Transparency, sp.Duration = true, true, false, 0.7, 0
	sp.Size = Vector3.new(4, 0.1, 4)
	sp.CFrame = CFrame.new(0, 0.05, 6)
	sp.Parent = m
	local function marca(nome: string, pos: Vector3, tam: Vector3, cor: Color3)
		Kit.peca(m, nome, CFrame.new(pos), tam, { Cor = cor, Mat = Enum.Material.Neon, Transp = 0.6 }, { Colide = false, Sombra = false })
	end
	local verm, amar, verde = Color3.fromRGB(200, 60, 50), Color3.fromRGB(240, 200, 40), Color3.fromRGB(60, 200, 90)
	marca("Spawn_IntrusosEstrada", Vector3.new(-120, 12, -100), Vector3.new(8, 2, 8), verm)
	marca("Spawn_IntrusosPraia", Vector3.new(-130, -5, 60), Vector3.new(8, 2, 8), verm)
	marca("Maleta_Escritorio", Vector3.new(16, 12, -1), Vector3.new(2, 1.2, 1.4), amar)
	marca("Maleta_Adega", Vector3.new(-8, -10, 12), Vector3.new(2, 1.2, 1.4), amar)
	marca("Maleta_Garagem", Vector3.new(40, 12, -28), Vector3.new(2, 1.2, 1.4), amar)
	marca("Extracao_Barco", Vector3.new(-66, -4, 100), Vector3.new(10, 2, 8), verde)
	marca("Extracao_Estrada", Vector3.new(130, 12, -100), Vector3.new(10, 2, 10), verde)
end

function Praia.construir(): Model
	local velho = workspace:FindFirstChild("Mapa")
	if velho then
		velho:Destroy()
	end
	workspace.Terrain:Clear()
	for _, nome in { "Baseplate", "SpawnLocation" } do
		local p = workspace:FindFirstChild(nome)
		if p and p.Parent == workspace then
			p:Destroy()
		end
	end
	local mapa = Instance.new("Model")
	mapa.Name = "Mapa"
	mapa.Parent = workspace
	terreno(mapa)
	task.wait()
	casa(mapa)
	task.wait()
	marcadores(mapa)
	local L = game:GetService("Lighting")
	L.ClockTime = 14.5
	return mapa
end

return Praia
