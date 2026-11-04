--!strict
-- Passa o mapa cinza da casa de praia pro visual do jogo (estilo chapado, cores limpas, luz de dia).
-- Não muda a planta nem as rotas: só troca cor/material das peças cinza e põe natureza e detalhes por cima.
-- Rodar depois do Praia.construir():  require(game.ServerStorage.Dev.Mapa.PraiaEstilo).aplicar()

local Kit = require(script.Parent.Kit)

local Estilo = {}

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end
local function cinza(c: number): Color3
	return Color3.fromRGB(c, c, c + 4)
end

-- cor cinza do bloco → (cor, material) do acabamento
local TROCA: { [string]: { Color3 | Enum.Material } } = {
	[tostring(cinza(176))] = { rgb(238, 236, 230), Enum.Material.SmoothPlastic }, -- externa: concreto branco
	[tostring(cinza(206))] = { rgb(232, 226, 214), Enum.Material.SmoothPlastic }, -- interna
	[tostring(cinza(140))] = { rgb(196, 170, 134), Enum.Material.WoodPlanks }, -- pisos
	[tostring(cinza(120))] = { rgb(104, 130, 74), Enum.Material.Grass }, -- jardim e platô
	[tostring(cinza(100))] = { rgb(126, 124, 118), Enum.Material.Slate }, -- penhasco
	[tostring(cinza(90))] = { rgb(84, 84, 86), Enum.Material.Concrete }, -- túneis
	[tostring(rgb(150, 128, 104))] = { rgb(214, 208, 196), Enum.Material.Concrete }, -- escadas e deque
	[tostring(rgb(196, 186, 156))] = { rgb(228, 214, 172), Enum.Material.Sand }, -- areia
}

local function luz()
	local L = game:GetService("Lighting")
	pcall(function()
		L.LightingStyle = Enum.LightingStyle.Realistic
	end)
	L.ClockTime = 13.6
	L.GeographicLatitude = 18
	L.Brightness = 3.2
	L.Ambient = rgb(118, 114, 110)
	L.OutdoorAmbient = rgb(150, 152, 158)
	L.ColorShift_Top = rgb(255, 246, 232)
	L.ColorShift_Bottom = rgb(80, 86, 96)
	L.EnvironmentDiffuseScale = 0.7
	L.EnvironmentSpecularScale = 0.4
	L.ShadowSoftness = 0.12
	L.ExposureCompensation = 0.1
	local function efeito(classe: string): Instance
		local e = L:FindFirstChildOfClass(classe :: any)
		if not e then
			e = Instance.new(classe :: any)
			e.Parent = L
		end
		return e
	end
	local atm = efeito("Atmosphere") :: Atmosphere
	atm.Density, atm.Offset, atm.Color, atm.Decay, atm.Glare, atm.Haze = 0.24, 0.12, rgb(204, 220, 236), rgb(140, 160, 186), 0.2, 0.8
	local bloom = efeito("BloomEffect") :: BloomEffect
	bloom.Intensity, bloom.Size, bloom.Threshold = 0.35, 24, 1.8
	local cc = efeito("ColorCorrectionEffect") :: ColorCorrectionEffect
	cc.Brightness, cc.Contrast, cc.Saturation, cc.TintColor = 0.02, 0.1, 0.06, rgb(255, 252, 246)
	local dof = L:FindFirstChildOfClass("DepthOfFieldEffect")
	if dof then
		dof.Enabled = false
	end
	workspace.Terrain.WaterColor = rgb(40, 120, 150)
	workspace.Terrain.WaterTransparency = 0.6
	workspace.Terrain.WaterWaveSize = 0.12
	workspace.Terrain.WaterReflectance = 0.6
end

-- Palmeira low poly: tronco em gomos inclinados e copa de folhas caídas.
local function palmeira(pai: Instance, pos: Vector3, alt: number, rng: Random)
	local m = Instance.new("Model")
	m.Name = "Palmeira"
	local tronco: Kit.Estilo = { Cor = rgb(120, 96, 70), Mat = Enum.Material.Wood, Bal = "Madeira" }
	local inc = Vector3.new(rng:NextNumber(-0.25, 0.25), 1, rng:NextNumber(-0.25, 0.25)).Unit
	local p = pos
	local gomos = 6
	for i = 1, gomos do
		local q = p + inc * (alt / gomos) + Vector3.new(inc.X, 0, inc.Z) * i * 0.15
		Kit.viga(m, "Gomo", p, q, 0.9 - i * 0.05, 0.9 - i * 0.05, tronco)
		p = q
	end
	local folha: Kit.Estilo = { Cor = rgb(86, 120, 62), Mat = Enum.Material.SmoothPlastic, Bal = "Tecido" }
	for i = 1, 8 do
		local ang = i * math.pi * 2 / 8 + rng:NextNumber(-0.2, 0.2)
		local cf = CFrame.new(p) * CFrame.Angles(0, ang, 0) * CFrame.Angles(math.rad(-25 - rng:NextNumber(0, 20)), 0, 0) * CFrame.new(0, 0, -3.2)
		Kit.peca(m, "Folha", cf, Vector3.new(1.6, 0.15, 6.5), folha, { Colide = false })
	end
	Kit.peca(m, "Coco", CFrame.new(p - Vector3.new(0, 0.4, 0)), Vector3.new(1.1, 1.1, 1.1), { Cor = rgb(90, 70, 40), Mat = Enum.Material.SmoothPlastic }, { Forma = Enum.PartType.Ball, Colide = false })
	m.Parent = pai
end

-- Pedra grande facetada: blocos girados que se cruzam.
local function pedra(pai: Instance, pos: Vector3, tam: number, rng: Random)
	local m = Instance.new("Model")
	m.Name = "Pedra"
	local cor = rgb(130, 128, 124):Lerp(rgb(104, 104, 102), rng:NextNumber())
	for _ = 1, 3 do
		local s = tam * rng:NextNumber(0.7, 1)
		Kit.peca(m, "Bloco", CFrame.new(pos + Vector3.new(rng:NextNumber(-0.3, 0.3) * tam, s * 0.3, rng:NextNumber(-0.3, 0.3) * tam)) * CFrame.Angles(rng:NextNumber(-0.6, 0.6), rng:NextNumber(0, 3), rng:NextNumber(-0.6, 0.6)), Vector3.new(s * 1.2, s * 0.85, s), { Cor = cor, Mat = Enum.Material.Slate, Bal = "Pedra" })
	end
	m.Parent = pai
end

local function arbusto(pai: Instance, pos: Vector3, tam: number, rng: Random)
	for _ = 1, 3 do
		local s = tam * rng:NextNumber(0.6, 1)
		Kit.peca(pai, "Arbusto", CFrame.new(pos + Vector3.new(rng:NextNumber(-0.4, 0.4) * tam, s * 0.35, rng:NextNumber(-0.4, 0.4) * tam)), Vector3.new(s, s * 0.85, s), { Cor = rgb(64, 112, 46):Lerp(rgb(96, 140, 56), rng:NextNumber()), Mat = Enum.Material.SmoothPlastic, Bal = "Tecido" }, { Forma = Enum.PartType.Ball, Colide = false })
	end
end

local function canteiro(pai: Instance, x1: number, z1: number, x2: number, z2: number, y: number, rng: Random)
	Kit.caixa(pai, "Canteiro", x1, y, z1, x2, y + 2.2, z2, { Cor = rgb(236, 234, 228), Mat = Enum.Material.SmoothPlastic, Bal = "Concreto" })
	Kit.caixa(pai, "Terra", x1 + 0.4, y + 2.2, z1 + 0.4, x2 - 0.4, y + 2.3, z2 - 0.4, { Cor = rgb(70, 54, 40), Mat = Enum.Material.Ground }, { Sombra = false })
	local n = math.max(1, math.floor(math.max(x2 - x1, z2 - z1) / 3))
	for i = 1, n do
		local t = (i - 0.5) / n
		local px = if x2 - x1 > z2 - z1 then x1 + (x2 - x1) * t else (x1 + x2) / 2
		local pz = if x2 - x1 > z2 - z1 then (z1 + z2) / 2 else z1 + (z2 - z1) * t
		arbusto(pai, Vector3.new(px, y + 2.2, pz), 2.2, rng)
	end
end

local function detalhes(mapa: Instance)
	local f = Instance.new("Folder")
	f.Name = "Estilo"
	f.Parent = mapa
	local rng = Random.new(21)
	local PRETO: Kit.Estilo = { Cor = rgb(30, 30, 32), Mat = Enum.Material.SmoothPlastic, Bal = "MetalFino" }
	local MADEIRA: Kit.Estilo = { Cor = rgb(150, 100, 62), Mat = Enum.Material.WoodPlanks, Bal = "Madeira" }
	-- grama por cima do platô da rua (o bloco vira muro de pedra)
	Kit.caixa(f, "GramaPlato", -150, 11, -88, 48, 11.08, -14, { Cor = rgb(104, 130, 74), Mat = Enum.Material.Grass, Bal = "Pedra" }, { Sombra = false })
	-- moldura preta grossa da caixa de vidro da suíte e do vidro da sala
	for _, z in { 18, 24 } do
		Kit.caixa(f, "MolduraSuite", -8.6, 10.4, z - 0.3, 12.6, 11, z + 0.3, PRETO)
		Kit.caixa(f, "MolduraSuite", -8.6, 22, z - 0.3, 12.6, 23.4, z + 0.3, PRETO)
	end
	for _, x in { -8.3, 12.3 } do
		Kit.caixa(f, "MolduraSuite", x - 0.3, 10.4, 17.7, x + 0.3, 23.4, 24.3, PRETO)
	end
	Kit.caixa(f, "MolduraSala", -12.4, 8.5, 18.3, 12.4, 9.2, 18.9, PRETO)
	-- painel de madeira na fachada sul do quarto 2 e no núcleo B por fora
	Kit.caixa(f, "PainelMadeira", 12.6, 11, 18.5, 20, 22, 18.65, MADEIRA)
	Kit.caixa(f, "PainelMadeira", 28.5, -11, -10, 28.65, 26, 2, MADEIRA)
	-- pingadeira preta no topo das platibandas
	Kit.caixa(f, "Pingadeira", -20.6, 24.5, -14.4, 20.4, 24.9, -13.6, PRETO)
	Kit.caixa(f, "Pingadeira", -20.6, 24.5, 17.4, 20.4, 24.9, 18.4, PRETO)
	-- caminho de placas do terraço até a escada da praia
	for x = -36, -22, 2.6 do
		Kit.caixa(f, "Placa", x, 0, 34 + rng:NextNumber(-0.2, 0.2), x + 2, 0.12, 36.5, { Cor = rgb(222, 216, 204), Mat = Enum.Material.SmoothPlastic, Bal = "Pedra" }, { Sombra = false })
	end
	-- canteiros elevados no jardim e no pátio da rua
	canteiro(f, -60, 20, -46, 23, 0, rng)
	canteiro(f, -40, 22, -30, 25, 0, rng)
	canteiro(f, 22, 22, 34, 25, 0, rng)
	canteiro(f, -9, -32, -2, -30, 11, rng)
	canteiro(f, 2, -32, 9, -30, 11, rng)
	-- espreguiçadeiras e guarda-sol no terraço da piscina
	for _, x in { -10, -5, 5, 10 } do
		Kit.caixa(f, "Espreguicadeira", x - 1, 0, 34.5, x + 1, 0.9, 39, { Cor = rgb(240, 240, 236), Mat = Enum.Material.SmoothPlastic, Bal = "Plastico" })
		Kit.viga(f, "Encosto", Vector3.new(x, 0.9, 38.4), Vector3.new(x, 2.4, 39.4), 2, 0.2, { Cor = rgb(240, 240, 236), Mat = Enum.Material.SmoothPlastic, Bal = "Plastico" })
	end
	Kit.cilindro(f, "Haste", Vector3.new(0, 0, 37), 0.12, 7, PRETO)
	Kit.peca(f, "GuardaSol", CFrame.new(0, 7, 37), Vector3.new(0.4, 8, 8), { Cor = rgb(236, 230, 214), Mat = Enum.Material.Fabric, Bal = "Tecido" }, { Forma = Enum.PartType.Cylinder, Colide = false })
	-- palmeiras
	for _, p in { { -52, 0, 8 }, { -48, 0, 30 }, { -28, 0, 30 }, { 24, 0, 30 }, { 36, 0, 22 }, { -90, -6, 50 }, { -40, -6, 60 }, { 10, -6, 62 }, { 50, -6, 58 }, { 58, 12, 0 }, { 66, 12, 40 }, { -20, 11, -40 }, { 18, 11, -44 }, { -70, 11, -30 } } do
		palmeira(f, Vector3.new(p[1], p[2], p[3]), rng:NextNumber(14, 22), rng)
	end
	-- pedras grandes na praia, no pé do penhasco e no platô
	for _, p in { { -100, -6, 66, 7 }, { -84, -6, 70, 5 }, { -20, -6, 70, 6 }, { 30, -6, 68, 8 }, { 44, -6, 52, 9 }, { 50, -6, 44, 7 }, { 48, 0, -4, 6 }, { 47, 0, 34, 5 }, { -80, 0, 30, 5 }, { -110, 0, 10, 6 }, { 70, 12, -10, 7 }, { 98, 24, 50, 9 }, { 84, 24, -20, 6 }, { 120, 34, 30, 10 } } do
		pedra(f, Vector3.new(p[1], p[2], p[3]), p[4], rng)
	end
	-- arbustos soltos
	for _ = 1, 30 do
		local x, z = rng:NextNumber(-140, 44), rng:NextNumber(-12, 38)
		if not (x > -46 and x < 34 and z > -12 and z < 40) then
			arbusto(f, Vector3.new(x, 0, z), rng:NextNumber(2, 3.5), rng)
		end
	end
end


-- Penhasco em rocha de terreno nas mesmas alturas (12, 24, 34). As caixas cinza ficam invisíveis.
local function penhasco(mapa: Instance)
	local T = workspace.Terrain
	T:SetMaterialColor(Enum.Material.Rock, rgb(132, 128, 120))
	T:SetMaterialColor(Enum.Material.Grass, rgb(100, 128, 70))
	local terr = mapa:FindFirstChild("Terreno") :: Instance
	for _, nome in { "Penhasco1", "Penhasco2", "Penhasco3" } do
		local p = terr:FindFirstChild(nome)
		if p and p:IsA("BasePart") then
			T:FillBlock(p.CFrame, p.Size, Enum.Material.Rock)
			p.Transparency, p.CanCollide, p.CanQuery, p.CanTouch = 1, false, false, false
		end
	end
	-- bordas irregulares só nas faces sul/leste e no pé, longe das rampas (z -40) e da trilha (z 12..20)
	local rng = Random.new(5)
	for _ = 1, 40 do
		local x = rng:NextNumber(52, 148)
		local topo = if x < 72 then 12 elseif x < 100 then 24 else 34
		T:FillBall(Vector3.new(x, rng:NextNumber(0, topo - 2), rng:NextNumber(60, 80)), rng:NextNumber(5, 11), Enum.Material.Rock)
	end
	for _ = 1, 24 do
		T:FillBall(Vector3.new(rng:NextNumber(46, 52), rng:NextNumber(0, 9), rng:NextNumber(26, 70)), rng:NextNumber(3, 6), Enum.Material.Rock)
	end
	for _, s in { { 72, 46 }, { 100, 50 }, { 72, -54 }, { 100, -54 }, { 72, 60 }, { 100, 4 } } do
		T:FillBall(Vector3.new(s[1], (if s[1] < 100 then 12 else 24) + 2, s[2]), rng:NextNumber(5, 8), Enum.Material.Rock)
	end
	T:FillBlock(CFrame.new(60, 12.5, 6), Vector3.new(20, 1, 120), Enum.Material.Grass)
	T:FillBlock(CFrame.new(86, 24.5, 6), Vector3.new(24, 1, 120), Enum.Material.Grass)
end

function Estilo.aplicar()
	local mapa = workspace:FindFirstChild("Mapa")
	assert(mapa, "rode Praia.construir() antes")
	local madeiraB: Kit.Estilo = { Cor = rgb(150, 100, 62), Mat = Enum.Material.WoodPlanks, Bal = "Madeira" }
	for _, p in mapa:GetDescendants() do
		if p:IsA("BasePart") and not p:IsA("TrussPart") then
			local t = TROCA[tostring(p.Color)]
			if t then
				p.Color = t[1] :: Color3
				p.Material = t[2] :: Enum.Material
			end
		end
	end
	-- o platô vira muro de pedra (a grama vai por cima)
	for _, nome in { "PlatoRua", "PlatoAla", "PlatoCasa", "PenhascoNorte" } do
		local p = mapa.Terreno:FindFirstChild(nome)
		if p and p:IsA("BasePart") then
			p.Color = rgb(150, 146, 138)
			p.Material = Enum.Material.Slate
		end
	end
	-- núcleo B em painel de madeira
	for _, p in mapa.Casa.NucleoB:GetDescendants() do
		if p:IsA("BasePart") and not p:IsA("TrussPart") and p.Name ~= "Degrau" then
			p.Color = madeiraB.Cor
			p.Material = madeiraB.Mat
		end
	end
	-- rótulos e bonecos ficam escondidos no visual (continuam no lugar)
	for _, p in mapa.Casa.Rotulos:GetChildren() do
		if p:IsA("BasePart") and p.Name == "Boneco6_3" then
			p.Transparency = 1
		end
		local bb = p:FindFirstChildOfClass("BillboardGui")
		if bb then
			bb.Enabled = false
		end
	end
	detalhes(mapa)
	penhasco(mapa)
	luz()
end

return Estilo
