--!strict
-- Casa da Serra, etapa 1 (só a casa), em blocos. Planta própria.
-- Rodar no Studio (modo Edit) pelo MCP:
--   local p = game.ServerStorage.Dev.Mapa:Clone(); p.Parent = game.ServerStorage
--   require(p.CasaDaSerra).construir(); p:Destroy()
-- (copia a pasta inteira pra não pegar versão velha do Construtor no cache do require)
-- Apaga e refaz workspace.Mapa inteiro.
--
-- Eixos: +X = leste, -Z = norte, Y = altura. Casa de x -45..45, z -30..30.
-- Térreo: piso em y 0, paredes até 10, laje 10..11.
-- 1º andar: piso em y 11, paredes até 21, telhado 21..22.
-- Porão: piso em y -11, laje do térreo -1..0.
--
-- Térreo                         1º andar
--  z-30 ┌────────┬────────┬────────┐   ┌────┬──┬────────┬──┬────┐
--       │Cozinha │  Sala  │Serviço │   │Q1  │G │  vão   │G │Esc.│
--       │        │ (pé-   │(desce) │   ├────┤a │ (sala) │a ├────┤
--  z -4 ├────────┤ direito├────────┤   │Banh│l │        │l │Bnh2│
--       │ Jantar │ duplo) │Garagem │   ├────┤  ├────────┤  ├────┤
--  z 18 │        ├────────┤        │   │Q2  │  │ galeria│  │Q4  │
--       │        │  Hall  │        │   │    ├──┴────────┴──┤    │
--  z 30 └────────┴───┬────┴────────┘   └────┴─── Q3 ───────┴────┘
--             porta da frente
-- Porão: Adega dos servidores (x -15..15) e Lavanderia (x 15..45), z -30..0.

local Construtor = require(script.Parent.Construtor)
local C = Construtor

local CasaDaSerra = {}

-- Cores e materiais do bloco (o acabamento visual vem depois).
local EXTERNA: Construtor.Props = {
	Cor = Color3.fromRGB(205, 200, 190),
	Material = Enum.Material.Concrete,
	Balistico = "Concreto",
}
local INTERNA: Construtor.Props = {
	Cor = Color3.fromRGB(232, 229, 220),
	Material = Enum.Material.SmoothPlastic,
	Balistico = "Gesso",
}
local LAJE: Construtor.Props = {
	Cor = Color3.fromRGB(150, 148, 142),
	Material = Enum.Material.Concrete,
	Balistico = "Concreto",
}
local ESCADA: Construtor.Props = {
	Cor = Color3.fromRGB(125, 98, 72),
	Material = Enum.Material.WoodPlanks,
	Balistico = "Madeira",
}
local GRADIL: Construtor.Props = {
	Cor = Color3.fromRGB(60, 60, 60),
	Material = Enum.Material.Metal,
	Balistico = "MetalFino",
}
local CHAO: Construtor.Props = {
	Cor = Color3.fromRGB(92, 108, 66),
	Material = Enum.Material.Grass,
	Balistico = "Pedra",
}
local ESTRADA: Construtor.Props = {
	Cor = Color3.fromRGB(70, 70, 72),
	Material = Enum.Material.Asphalt,
	Balistico = "Pedra",
}
local MURO: Construtor.Props = {
	Cor = Color3.fromRGB(140, 132, 120),
	Material = Enum.Material.Brick,
	Balistico = "Tijolo",
}

-- Medidas
local PD = 10 -- pé-direito
local T1 = 11 -- piso do 1º andar
local TOPO = 22 -- topo do telhado
local P = 3.2 -- largura de porta
local PA = 7.5 -- altura de porta

local function porta(c: number, y: number, nome: string?): Construtor.Abertura
	return { c = c, w = P, y0 = y, y1 = y + PA, nome = nome }
end
local function janela(c: number, w: number, y0: number, y1: number, nome: string?): Construtor.Abertura
	return { c = c, w = w, y0 = y0, y1 = y1, vidro = true, nome = nome }
end
local function vao(c: number, w: number, y0: number, y1: number, nome: string?): Construtor.Abertura
	return { c = c, w = w, y0 = y0, y1 = y1, nome = nome }
end

local function casa(pai: Instance)
	local casaM = Instance.new("Model")
	casaM.Name = "Casa"
	casaM.Parent = pai

	-- Paredes externas (do chão ao telhado, 1 stud).
	local ext = Instance.new("Folder")
	ext.Name = "Externas"
	ext.Parent = casaM
	C.parede(ext, "Norte", "x", -30, -45, 45, 0, TOPO, 1, {
		porta(-30, 0, "Rota_PortaDosFundos"),
		vao(0, 8, 0, 8, "Rota_PortaDeVidro"), -- porta de vidro da sala (entrada)
		janela(0, 20, T1 + 1, T1 + 8), -- janelão da sala no alto
		janela(-33, 4, T1 + 3, T1 + 7),
		janela(33, 4, T1 + 3, T1 + 7),
		janela(30, 4, 4, 7),
	}, EXTERNA)
	C.parede(ext, "Sul", "x", 30, -45, 45, 0, TOPO, 1, {
		porta(0, 0, "Rota_PortaDaFrente"),
		janela(-30, 6, 3, 7),
		vao(30, 14, 0, 8, "Rota_PortaoGaragem"), -- portão basculante (entra no passo 4)
		janela(0, 8, T1 + 2, T1 + 8),
		janela(-33, 4, T1 + 3, T1 + 7),
		janela(33, 4, T1 + 3, T1 + 7),
	}, EXTERNA)
	C.parede(ext, "Oeste", "z", -45, -30, 30, 0, TOPO, 1, {
		vao(-17, 4, 2, 6.5, "Rota_JanelaCozinha"), -- janela deslizante, peitoril baixo pra pular
		janela(12, 6, 3, 7),
		janela(-18, 4, T1 + 3, T1 + 7),
		janela(0, 2, T1 + 4, T1 + 7),
		janela(18, 4, T1 + 3, T1 + 7),
	}, EXTERNA)
	C.parede(ext, "Leste", "z", 45, -30, 30, 0, TOPO, 1, {
		porta(20, 0, "Rota_PortaLateralGaragem"),
		janela(-15, 4, 4, 7),
		vao(-18, 4, T1 + 2, T1 + 7, "Rota_JanelaEscritorio"), -- chega pela trepadeira
		janela(0, 2, T1 + 4, T1 + 7),
		janela(18, 4, T1 + 3, T1 + 7),
	}, EXTERNA)

	-- Lajes
	local lajes = Instance.new("Folder")
	lajes.Name = "Lajes"
	lajes.Parent = casaM
	C.laje(lajes, "PisoTerreo", -45, -30, 45, 30, -1, 0, { { 37, -28, 43, -6 } }, LAJE) -- buraco: escada do porão
	C.laje(lajes, "Piso1Andar", -45, -30, 45, 30, PD, T1, {
		{ -15, -30, 9, 12 }, -- vão da sala
		{ 9, -24, 15, 12 }, -- vão da sala (a parte de cima da escada fica com patamar)
	}, LAJE)
	C.laje(lajes, "Telhado", -45, -30, 45, 30, TOPO - 1, TOPO, { { -8, -20, 8, 0 } }, LAJE)
	C.caixa(lajes, "Claraboia", -8, TOPO - 0.6, -20, 8, TOPO - 0.4, 0, {
		Cor = Color3.fromRGB(170, 200, 215),
		Material = Enum.Material.Glass,
		Balistico = "Vidro",
		Transparencia = 0.5,
	})

	-- Térreo: paredes internas (0,5 stud, gesso)
	local ter = Instance.new("Folder")
	ter.Name = "Terreo"
	ter.Parent = casaM
	C.parede(ter, "SalaOeste", "z", -15, -30, 30, 0, PD, 0.5, {
		vao(-14, 6, 0, 8), -- cozinha ↔ sala
		vao(8, 8, 0, 8), -- jantar ↔ sala
		porta(24, 0), -- jantar ↔ hall
	}, INTERNA)
	C.parede(ter, "CozinhaJantar", "x", -4, -45, -15, 0, PD, 0.5, { porta(-30, 0) }, INTERNA)
	C.parede(ter, "SalaLeste", "z", 15, -30, 30, 0, PD, 0.5, {
		porta(-27, 0), -- sala ↔ serviço (passa por baixo do patamar)
		porta(24, 0), -- hall ↔ garagem
	}, INTERNA)
	C.parede(ter, "ServicoGaragem", "x", 0, 15, 45, 0, PD, 0.5, { porta(24, 0) }, INTERNA)
	C.parede(ter, "SalaHall", "x", 18, -15, 15, 0, PD, 0.5, { vao(0, 14, 0, 8) }, INTERNA)

	-- Escada principal: dentro da sala, sobe do sul pro norte até o patamar do 1º andar.
	C.escada(ter, "EscadaPrincipal", 9, 14, 0, -24, 0, T1, 15, ESCADA)

	-- 1º andar
	local and1 = Instance.new("Folder")
	and1.Name = "PrimeiroAndar"
	and1.Parent = casaM
	local y0, y1 = T1, T1 + PD
	C.parede(and1, "AlaOeste", "z", -21, -30, 30, y0, y1, 0.5, { porta(-18, y0), porta(0, y0), porta(12, y0) }, INTERNA)
	C.parede(and1, "Quarto1Banheiro", "x", -6, -45, -21, y0, y1, 0.5, nil, INTERNA)
	C.parede(and1, "BanheiroQuarto2", "x", 6, -45, -21, y0, y1, 0.5, nil, INTERNA)
	C.parede(and1, "AlaLeste", "z", 21, -30, 30, y0, y1, 0.5, { porta(-18, y0), porta(0, y0), porta(12, y0) }, INTERNA)
	C.parede(and1, "EscritorioBanheiro", "x", -6, 21, 45, y0, y1, 0.5, nil, INTERNA)
	C.parede(and1, "BanheiroQuarto4", "x", 6, 21, 45, y0, y1, 0.5, nil, INTERNA)
	C.parede(and1, "Quarto3", "x", 18, -21, 21, y0, y1, 0.5, { porta(0, y0) }, INTERNA)
	-- Gradil da galeria em volta do vão (1,1 m de altura)
	C.parede(and1, "GradilOeste", "z", -15, -30, 12, y0, y0 + 3.5, 0.3, nil, GRADIL)
	C.parede(and1, "GradilSul", "x", 12, -15, 15, y0, y0 + 3.5, 0.3, nil, GRADIL)
	C.parede(and1, "GradilLeste", "z", 15, -24, 12, y0, y0 + 3.5, 0.3, nil, GRADIL)
	C.parede(and1, "GradilPatamar", "z", 9, -30, -24, y0, y0 + 3.5, 0.3, nil, GRADIL)

	-- Porão
	local por = Instance.new("Folder")
	por.Name = "Porao"
	por.Parent = casaM
	local yp = -11
	C.caixa(por, "PisoPorao", -15, yp - 1, -30, 45, yp, 0, LAJE)
	C.parede(por, "Norte", "x", -30, -15, 45, yp - 1, -1, 1, nil, EXTERNA)
	C.parede(por, "Sul", "x", 0, -15, 45, yp - 1, -1, 1, nil, EXTERNA)
	C.parede(por, "Oeste", "z", -15, -30, 0, yp - 1, -1, 1, nil, EXTERNA)
	-- Duto: por enquanto alto o bastante pra passar em pé (deitar ainda não muda a colisão).
	C.parede(por, "Leste", "z", 45, -30, 0, yp - 1, -1, 1, { vao(-20, 4, yp, yp + 7, "Rota_DutoPorao") }, EXTERNA)
	C.parede(por, "AdegaLavanderia", "z", 15, -30, 0, yp, -1, 0.5, { porta(-15, yp) }, INTERNA)
	C.escada(por, "EscadaPorao", 37, 43, -28, -6, yp, 0, 15, ESCADA)

	-- Duto do porão: túnel pro leste e poço com escada até a grade no jardim.
	local duto = Instance.new("Folder")
	duto.Name = "Duto"
	duto.Parent = casaM
	C.caixa(duto, "Piso", 45, yp - 1, -22, 64, yp, -18, LAJE)
	C.caixa(duto, "Teto", 45, yp + 7, -22, 60, yp + 8, -18, LAJE)
	C.caixa(duto, "LadoNorte", 45, yp, -23, 64, -1, -22, LAJE)
	C.caixa(duto, "LadoSul", 45, yp, -18, 64, -1, -17, LAJE)
	C.caixa(duto, "Fundo", 64, yp, -22, 65, -1, -18, LAJE)
	C.trelica(duto, "EscadaDuto", 62, -20, yp, 0)

	-- Trepadeira até a janela do escritório
	C.trelica(casaM, "Trepadeira", 46.5, -18, 0, T1 + 2)
end

local function exterior(pai: Instance)
	local ext = Instance.new("Model")
	ext.Name = "Exterior"
	ext.Parent = pai

	-- Chão: terreno + estrada ao sul + trilhas, com buraco da casa e da grade do duto.
	C.laje(ext, "Chao", -146, -116, 130, 116, -1, 0, {
		{ -45, -30, 45, 30 },
		{ 60, -22, 64, -18 },
	}, CHAO)
	C.caixa(ext, "Estrada", -146, 0, 101, 130, 0.05, 116, ESTRADA)

	-- Muro em volta do terreno, com o portão sul e as trilhas oeste e norte.
	local h = 6
	C.parede(ext, "MuroSul", "x", 100, -130, 130, 0, h, 1, { vao(-110, 10, 0, h, "PortaoSul") }, MURO)
	C.parede(ext, "MuroNorte", "x", -100, -130, 130, 0, h, 1, { vao(-40, 6, 0, h, "TrilhaNorte") }, MURO)
	C.parede(ext, "MuroOeste", "z", -130, -100, 100, 0, h, 1, { vao(-90, 6, 0, h, "TrilhaOeste") }, MURO)
	C.parede(ext, "MuroLeste", "z", 130, -100, 100, 0, h, 1, nil, MURO)

	-- Limite invisível pra ninguém sair do mapa.
	local inv: Construtor.Props = { Transparencia = 1 }
	C.caixa(ext, "Limite", -147, 0, -117, 131, 40, -116, inv)
	C.caixa(ext, "Limite", -147, 0, 116, 131, 40, 117, inv)
	C.caixa(ext, "Limite", -147, 0, -117, -146, 40, 117, inv)
	C.caixa(ext, "Limite", 130, 0, -117, 131, 40, 117, inv)

	-- Mata: árvores em blocos a oeste e ao norte, fora dos caminhos principais.
	local mata = Instance.new("Folder")
	mata.Name = "Mata"
	mata.Parent = ext
	local rng = Random.new(7)
	local tronco: Construtor.Props = { Cor = Color3.fromRGB(85, 65, 50), Material = Enum.Material.Wood, Balistico = "Madeira" }
	local copa: Construtor.Props = { Cor = Color3.fromRGB(60, 85, 50), Material = Enum.Material.Grass, Balistico = "Tecido" }
	local colocadas = 0
	local tentativas = 0
	while colocadas < 45 and tentativas < 500 do
		tentativas += 1
		local x = rng:NextNumber(-125, 125)
		local z = rng:NextNumber(-95, 95)
		local naMata = x < -60 or z < -45
		local longeDaCasa = math.abs(x) > 55 or math.abs(z) > 40
		local foraDasTrilhas = math.abs(z + 90) > 8 and math.abs(x + 40) > 8 and math.abs(x + 110) > 10
		if naMata and longeDaCasa and foraDasTrilhas then
			colocadas += 1
			local alt = rng:NextNumber(14, 22)
			C.caixa(mata, "Tronco", x - 1, 0, z - 1, x + 1, alt, z + 1, tronco)
			local r = rng:NextNumber(4, 6)
			C.caixa(mata, "Copa", x - r, alt - 6, z - r, x + r, alt + 2, z + r, copa)
		end
	end

	-- Cobertura no jardim: muretas e um carro na frente da garagem.
	local cob = Instance.new("Folder")
	cob.Name = "Cobertura"
	cob.Parent = ext
	C.caixa(cob, "Carro", 24, 0, 40, 36, 4.5, 46, { Cor = Color3.fromRGB(80, 90, 110), Material = Enum.Material.Metal, Balistico = "MetalFino" })
	C.caixa(cob, "MuretaFrente", -20, 0, 48, -6, 3, 49, MURO)
	C.caixa(cob, "MuretaOeste", -70, 0, -10, -69, 3, 10, MURO)
	C.caixa(cob, "MuretaNorte", -10, 0, -55, 10, 3, -54, MURO)
	C.caixa(cob, "Deposito", 80, 0, 30, 95, 9, 45, EXTERNA)
end

local function marcadores(pai: Instance)
	local m = Instance.new("Folder")
	m.Name = "Marcadores"
	m.Parent = pai

	-- Spawn dos Guardas: SpawnLocation de verdade, pra testar já nascendo na sala.
	local sp = Instance.new("SpawnLocation")
	sp.Name = "Spawn_Guardas"
	sp.Anchored = true
	sp.Neutral = true
	sp.Size = Vector3.new(6, 0.2, 6)
	sp.CFrame = CFrame.new(0, 0.1, -10)
	sp.Transparency = 0.6
	sp.CanCollide = false
	sp.Color = Color3.fromRGB(60, 120, 200)
	sp.Duration = 0
	sp.Parent = m

	local azul = Color3.fromRGB(60, 120, 200)
	local vermelho = Color3.fromRGB(200, 70, 60)
	local amarelo = Color3.fromRGB(240, 200, 40)
	local verde = Color3.fromRGB(60, 200, 90)
	C.marcador(m, "Spawn_IntrusosSul", Vector3.new(-118, 1, 108), Vector3.new(8, 2, 8), vermelho)
	C.marcador(m, "Spawn_IntrusosOeste", Vector3.new(-138, 1, -90), Vector3.new(8, 2, 8), vermelho)
	C.marcador(m, "Maleta_Escritorio", Vector3.new(36, T1 + 1, -20), Vector3.new(3, 2, 3), amarelo)
	C.marcador(m, "Maleta_Adega", Vector3.new(0, -10, -20), Vector3.new(3, 2, 3), amarelo)
	C.marcador(m, "Maleta_Garagem", Vector3.new(38, 1, 8), Vector3.new(3, 2, 3), amarelo)
	C.marcador(m, "Extracao_Norte", Vector3.new(-40, 1, -108), Vector3.new(10, 2, 10), verde)
	C.marcador(m, "Extracao_Leste", Vector3.new(120, 1, -85), Vector3.new(12, 2, 12), verde)
	local _ = azul
end

function CasaDaSerra.construir(): Model
	local velho = workspace:FindFirstChild("Mapa")
	if velho then
		velho:Destroy()
	end
	local mapa = Instance.new("Model")
	mapa.Name = "Mapa"

	casa(mapa)
	task.wait()
	exterior(mapa)
	task.wait()
	marcadores(mapa)
	mapa.Parent = workspace

	-- Tira a baseplate e o spawn padrão do lugar vazio, se existirem.
	for _, nome in { "Baseplate", "SpawnLocation" } do
		local p = workspace:FindFirstChild(nome)
		if p and p.Parent == workspace then
			p:Destroy()
		end
	end

	-- Luz provisória de fim de tarde (o acabamento visual vem no passo 6).
	local Lighting = game:GetService("Lighting")
	Lighting.ClockTime = 17.2
	Lighting.GeographicLatitude = 20

	return mapa
end

return CasaDaSerra
