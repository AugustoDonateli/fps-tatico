--!strict
-- Exterior da Casa da Serra: luz de fim de tarde, terreno com serra ao fundo, mata de pinheiros low poly,
-- pedras, jardim com canteiros elevados, deque com pergolado, caminhos, muro de pedra, estrada e marcadores.

local Kit = require(script.Parent.Kit)
local Mv = require(script.Parent.Moveis)
local E = Kit.E

local Ambiente = {}

local function pasta(pai: Instance, nome: string): Folder
	local f = Instance.new("Folder")
	f.Name = nome
	f.Parent = pai
	return f
end
local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

----------------------------------------------------------------------------------------------------
-- Luz
----------------------------------------------------------------------------------------------------
function Ambiente.luz()
	local L = game:GetService("Lighting")
	pcall(function()
		L.LightingStyle = Enum.LightingStyle.Realistic
		L.PrioritizeLightingQuality = true
	end)
	L.ClockTime = 17.1
	L.GeographicLatitude = 28
	L.Brightness = 2.5
	L.ExposureCompensation = 0.05
	L.EnvironmentDiffuseScale = 0.55
	L.EnvironmentSpecularScale = 0.35
	L.Ambient = rgb(92, 86, 80)
	L.OutdoorAmbient = rgb(122, 118, 112)
	L.ColorShift_Top = rgb(255, 216, 182)
	L.ColorShift_Bottom = rgb(60, 48, 44)
	L.ShadowSoftness = 0.22
	L.GlobalShadows = true
	local function efeito(classe: string, nome: string): Instance
		local e = L:FindFirstChildOfClass(classe :: any)
		if not e then
			e = Instance.new(classe :: any)
			e.Parent = L
		end
		e.Name = nome
		return e
	end
	local atm = efeito("Atmosphere", "Atmosfera") :: Atmosphere
	atm.Density = 0.3
	atm.Offset = 0.18
	atm.Color = rgb(206, 196, 182)
	atm.Decay = rgb(110, 112, 120)
	atm.Glare = 0.45
	atm.Haze = 1.2
	local bloom = efeito("BloomEffect", "Brilho") :: BloomEffect
	bloom.Intensity = 0.55
	bloom.Size = 30
	bloom.Threshold = 1.5
	local cc = efeito("ColorCorrectionEffect", "Cor") :: ColorCorrectionEffect
	cc.Brightness = 0.01
	cc.Contrast = 0.12
	cc.Saturation = -0.06
	cc.TintColor = rgb(255, 245, 234)
	local raios = efeito("SunRaysEffect", "Raios") :: SunRaysEffect
	raios.Intensity = 0.07
	raios.Spread = 0.55
	local dof = L:FindFirstChildOfClass("DepthOfFieldEffect")
	if dof then
		dof.Enabled = false
	end
	local ceu = L:FindFirstChildOfClass("Sky")
	if ceu then
		ceu.SunAngularSize = 16
		ceu.MoonAngularSize = 8
	end
end

----------------------------------------------------------------------------------------------------
-- Terreno
----------------------------------------------------------------------------------------------------
local function terreno()
	local T = workspace.Terrain
	T:Clear()
	pcall(function()
		-- grama 3D desligada: ela some em qualidade gráfica baixa e esconde quem está deitado só pra alguns
		T.Decoration = false
	end)
	T:SetMaterialColor(Enum.Material.Grass, rgb(92, 110, 60))
	T:SetMaterialColor(Enum.Material.LeafyGrass, rgb(78, 96, 54))
	T:SetMaterialColor(Enum.Material.Ground, rgb(104, 88, 66))
	T:SetMaterialColor(Enum.Material.Rock, rgb(118, 114, 108))
	T:SetMaterialColor(Enum.Material.Mud, rgb(84, 70, 56))
	local function bloco(x1: number, y1: number, z1: number, x2: number, y2: number, z2: number, m: Enum.Material)
		T:FillBlock(CFrame.new((x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2), Vector3.new(math.abs(x2 - x1), math.abs(y2 - y1), math.abs(z2 - z1)), m)
	end
	-- chão jogável (até a cerca invisível) e entorno
	bloco(-400, -8, -400, 400, 0, 400, Enum.Material.Grass)
	bloco(-148, -8, -116, -60, 0, 100, Enum.Material.LeafyGrass) -- mata oeste
	bloco(-148, -8, -116, 132, 0, -48, Enum.Material.LeafyGrass) -- mata norte
	-- buraco da casa e do poço do duto
	bloco(-48, -16, -32, 48, 0, 32, Enum.Material.Air)
	bloco(60, -16, -24, 64, 0, -16, Enum.Material.Air)
	bloco(45, -12, -24, 64, -4, -16, Enum.Material.Air)
	-- morros fora do muro
	local rng = Random.new(11)
	for _ = 1, 26 do
		local ang = rng:NextNumber(0, math.pi * 2)
		local dist = rng:NextNumber(185, 320)
		local r = rng:NextNumber(30, 70)
		T:FillBall(Vector3.new(math.cos(ang) * dist, -r * 0.55, math.sin(ang) * dist), r, if rng:NextNumber() < 0.5 then Enum.Material.LeafyGrass else Enum.Material.Grass)
	end
	-- cordilheiras: cadeias de bolas de tamanhos diferentes ao longo de uma linha, pra silhueta de serra
	local function serra(x1: number, z1: number, x2: number, z2: number, rMax: number, seed: number)
		local r2 = Random.new(seed)
		local n = 9
		for i = 0, n do
			local t = i / n
			local x = x1 + (x2 - x1) * t + r2:NextNumber(-40, 40)
			local z = z1 + (z2 - z1) * t + r2:NextNumber(-40, 40)
			local r = rMax * (0.55 + 0.45 * math.sin(t * math.pi)) * r2:NextNumber(0.75, 1.1)
			T:FillBall(Vector3.new(x, -r * 0.45, z), r, Enum.Material.Grass)
			if r > rMax * 0.7 then
				T:FillBall(Vector3.new(x, r * 0.32, z), r * 0.38, Enum.Material.Rock)
			end
		end
	end
	serra(-900, -700, 600, -950, 230, 1)
	serra(-950, 600, -800, -500, 200, 2)
	serra(700, -800, 950, 500, 180, 3)
	serra(-500, 950, 700, 900, 150, 4)
	-- picos soltos na frente da serra, com pedra no alto
	for _, s in { { -260, -820, 260 }, { 220, -900, 300 }, { -820, -260, 280 }, { -700, 420, 220 }, { 760, -520, 260 }, { 40, -1150, 340 }, { 820, 260, 200 }, { -380, 900, 240 } } do
		local x, z, r = s[1], s[2], s[3]
		T:FillBall(Vector3.new(x, -r * 0.35, z), r, Enum.Material.Grass)
		T:FillBall(Vector3.new(x + r * 0.1, r * 0.35, z - r * 0.05), r * 0.42, Enum.Material.Rock)
	end
end

----------------------------------------------------------------------------------------------------
-- Natureza: pinheiros low poly (pirâmides), árvores redondas, pedras, arbustos
----------------------------------------------------------------------------------------------------
-- Pirâmide de base quadrada feita com 4 CornerWedgeParts (o pico da CornerWedge fica no canto +X,-Z).
local function piramide(pai: Instance, centro: Vector3, base: number, alt: number, cor: Color3)
	local h = base / 2
	for _, q in { { 1, 1, 90 }, { -1, 1, 0 }, { -1, -1, 270 }, { 1, -1, 180 } } do
		local w = Instance.new("CornerWedgePart")
		w.Anchored = true
		w.CanCollide = false
		w.Size = Vector3.new(h, alt, h)
		w.CFrame = CFrame.new(centro + Vector3.new(q[1] * h / 2, alt / 2, q[2] * h / 2)) * CFrame.Angles(0, math.rad(q[3]), 0)
		w.Color = cor
		w.Material = Enum.Material.SmoothPlastic
		w:SetAttribute("Balistico", "Tecido")
		w.Parent = pai
	end
end

local function pinheiro(pai: Instance, pos: Vector3, alt: number, rng: Random)
	local m = Instance.new("Model")
	m.Name = "Pinheiro"
	local tronco = rng:NextNumber(0.5, 0.8)
	Kit.cilindro(m, "Tronco", pos - Vector3.new(0, 1, 0), tronco, alt * 0.35 + 1, { Cor = rgb(82, 62, 46), Mat = Enum.Material.Wood, Bal = "Madeira" })
	local verdes = { rgb(52, 74, 50), rgb(60, 84, 54), rgb(46, 66, 48), rgb(70, 90, 58) }
	local cor = verdes[rng:NextInteger(1, #verdes)]
	local camadas = 3
	for i = 0, camadas - 1 do
		local base = alt * (0.55 - i * 0.13)
		local y = alt * (0.22 + i * 0.22)
		local c = cor:Lerp(rgb(110, 120, 70), i * 0.08)
		piramide(m, pos + Vector3.new(0, y, 0), base, alt * 0.38, c)
	end
	m.Parent = pai
end

local function arvoreRedonda(pai: Instance, pos: Vector3, alt: number, rng: Random)
	local m = Instance.new("Model")
	m.Name = "Arvore"
	Kit.cilindro(m, "Tronco", pos - Vector3.new(0, 1, 0), 0.6, alt * 0.55 + 1, { Cor = rgb(92, 70, 52), Mat = Enum.Material.Wood, Bal = "Madeira" })
	for i = 1, 4 do
		local r = alt * rng:NextNumber(0.18, 0.26)
		local off = Vector3.new(rng:NextNumber(-1, 1) * alt * 0.12, alt * rng:NextNumber(0.6, 0.8), rng:NextNumber(-1, 1) * alt * 0.12)
		local p = Kit.peca(m, "Copa", CFrame.new(pos + off) * CFrame.Angles(rng:NextNumber(0, 1), rng:NextNumber(0, 3), rng:NextNumber(0, 1)), Vector3.new(r * 2, r * 1.7, r * 2), { Cor = rgb(88, 108, 60):Lerp(rgb(120, 128, 66), rng:NextNumber()), Mat = Enum.Material.SmoothPlastic, Bal = "Tecido" }, { Colide = false })
		local _ = p
	end
	m.Parent = pai
end

local function pedra(pai: Instance, pos: Vector3, tam: number, rng: Random)
	local m = Instance.new("Model")
	m.Name = "Pedra"
	local cor = rgb(124, 120, 112):Lerp(rgb(100, 96, 92), rng:NextNumber())
	for i = 1, rng:NextInteger(2, 3) do
		local s = tam * rng:NextNumber(0.6, 1)
		local off = Vector3.new(rng:NextNumber(-0.4, 0.4) * tam, s * 0.25, rng:NextNumber(-0.4, 0.4) * tam)
		Kit.peca(m, "Bloco", CFrame.new(pos + off) * CFrame.Angles(rng:NextNumber(-0.5, 0.5), rng:NextNumber(0, 3), rng:NextNumber(-0.5, 0.5)), Vector3.new(s * 1.3, s * 0.8, s), { Cor = cor, Mat = Enum.Material.Slate, Bal = "Pedra" })
		local _ = i
	end
	m.Parent = pai
end

local function arbusto(pai: Instance, pos: Vector3, tam: number, rng: Random)
	for i = 1, 3 do
		local s = tam * rng:NextNumber(0.6, 1)
		Kit.peca(pai, "Arbusto", CFrame.new(pos + Vector3.new(rng:NextNumber(-0.5, 0.5) * tam, s * 0.35, rng:NextNumber(-0.5, 0.5) * tam)), Vector3.new(s, s * 0.8, s), { Cor = rgb(76, 98, 56):Lerp(rgb(104, 120, 64), rng:NextNumber()), Mat = Enum.Material.Grass, Bal = "Tecido" }, { Forma = Enum.PartType.Ball, Colide = false })
		local _ = i
	end
end

local function natureza(pai: Instance)
	local f = pasta(pai, "Natureza")
	local rng = Random.new(7)
	local function livre(x: number, z: number): boolean
		if math.abs(x) < 58 and math.abs(z) < 50 then return false end -- casa e jardim
		if math.abs(z + 90) < 8 and x < -100 then return false end -- trilha oeste
		if math.abs(x + 40) < 8 and z < -60 then return false end -- trilha norte
		if math.abs(x + 110) < 10 and z > 60 then return false end -- entrada do portão
		if math.abs(z - 72) < 8 and x > -116 and x < 36 then return false end -- caminho do carro
		if math.abs(x - 30) < 8 and z > 30 and z < 76 then return false end
		if x > 74 and x < 100 and z > 24 and z < 50 then return false end -- depósito
		if math.abs(x - 120) < 14 and math.abs(z + 85) < 14 then return false end -- extração leste
		return true
	end
	-- mata dentro do muro
	local n = 0
	local tent = 0
	while n < 85 and tent < 2000 do
		tent += 1
		local x = rng:NextNumber(-126, 126)
		local z = rng:NextNumber(-96, 96)
		local naMata = x < -62 or z < -50 or (x > 70 and z < 10)
		if naMata and livre(x, z) then
			n += 1
			if rng:NextNumber() < 0.8 then
				pinheiro(f, Vector3.new(x, 0, z), rng:NextNumber(18, 32), rng)
			else
				arvoreRedonda(f, Vector3.new(x, 0, z), rng:NextNumber(14, 20), rng)
			end
		end
	end
	-- floresta fora do muro (cenário)
	for _ = 1, 140 do
		local ang = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(150, 260)
		local x, z = math.cos(ang) * d, math.sin(ang) * d * 0.8
		if math.abs(x) > 140 or math.abs(z) > 112 then
			pinheiro(f, Vector3.new(x, -1, z), rng:NextNumber(24, 40), rng)
		end
	end
	-- pedras grandes de cobertura e arbustos
	for _ = 1, 40 do
		local x, z = rng:NextNumber(-126, 126), rng:NextNumber(-96, 96)
		if livre(x, z) then
			pedra(f, Vector3.new(x, 0, z), rng:NextNumber(2, 6), rng)
		end
	end
	for _, p in { { -64, 4, 7 }, { -58, -40, 6 }, { 62, 40, 5 }, { -30, -60, 8 }, { 20, -62, 6 }, { 70, -30, 5 } } do
		pedra(f, Vector3.new(p[1], 0, p[2]), p[3], rng)
	end
	for _ = 1, 60 do
		local x, z = rng:NextNumber(-126, 126), rng:NextNumber(-96, 96)
		if livre(x, z) then
			arbusto(f, Vector3.new(x, 0, z), rng:NextNumber(2, 4), rng)
		end
	end
end

----------------------------------------------------------------------------------------------------
-- Construções e jardim
----------------------------------------------------------------------------------------------------
local function exterior(pai: Instance)
	local f = pasta(pai, "Exterior")
	local rng = Random.new(3)
	-- calçada em volta da casa
	Kit.laje(f, "Calcada", -48, -33, 48, 33, -0.2, 0.08, { { -45, -30, 45, 30 }, { -16, -33, 16, -30 } }, { Cor = rgb(168, 162, 152), Mat = Enum.Material.Pavement, Bal = "Concreto" })
	-- deque norte com degrau e pergolado
	local deque = pasta(f, "Deque")
	Kit.caixa(deque, "Base", -16, -0.6, -46, 16, 0.25, -30.6, E.MadeiraEscura)
	for z = -45.8, -30.8, 0.75 do
		Kit.caixa(deque, "Tabua", -16, 0.25, z, 16, 0.35, z + 0.68, E.MadeiraClara, { Sombra = false })
	end
	for _, x in { -15.5, -5.5, 5.5, 15.5 } do
		Kit.caixa(deque, "Pilar", x - 0.35, 0.35, -45.4, x + 0.35, 9.5, -44.7, E.MadeiraEscura)
	end
	Kit.caixa(deque, "Viga", -16.5, 9.5, -45.6, 16.5, 10.2, -44.5, E.MadeiraEscura)
	for x = -15, 15, 1.5 do
		Kit.caixa(deque, "Caibro", x - 0.15, 10.2, -45.8, x + 0.15, 10.6, -30.6, E.MadeiraClara)
	end
	for _, x in { -11, -7 } do
		Mv.poltrona(deque, CFrame.new(x, 0.35, -40) * CFrame.Angles(0, math.rad(180), 0), E.TecidoBege)
	end
	Kit.cilindro(deque, "Mesinha", Vector3.new(-9, 0.35, -38.5), 0.9, 1.6, E.Metal)
	Mv.mesaJantar(deque, CFrame.new(7, 0.35, -38), 7, 3.5, 2)
	Mv.planta(deque, Vector3.new(-14.5, 0.35, -31.5), 5)
	Mv.planta(deque, Vector3.new(14.5, 0.35, -31.5), 5)
	-- caminho do carro (cascalho) do portão até a garagem
	local cam: Kit.Estilo = { Cor = rgb(150, 140, 126), Mat = Enum.Material.Pebble, Bal = "Pedra" }
	Kit.caixa(f, "Cascalho", -115, -0.2, 68, -105, 0.06, 101, cam, { Sombra = false })
	Kit.caixa(f, "Cascalho", -115, -0.2, 67, 35, 0.06, 77, cam, { Sombra = false })
	Kit.caixa(f, "Cascalho", 25, -0.2, 33, 35, 0.06, 77, cam, { Sombra = false })
	-- caminho de placas até a porta da frente
	for z = 39, 65, 2.4 do
		Kit.caixa(f, "Placa", -1.6 + rng:NextNumber(-0.2, 0.2), -0.2, z, 1.6 + rng:NextNumber(-0.2, 0.2), 0.12, z + 1.7, E.PedraClara, { Sombra = false })
	end
	Kit.caixa(f, "Patamar", -7, -0.2, 33, 9, 0.2, 38, E.PedraClara)
	-- canteiros elevados de pedra no jardim da frente (cobertura)
	local function canteiroExterno(x1: number, z1: number, x2: number, z2: number)
		Kit.caixa(f, "Canteiro", x1, -0.2, z1, x2, 2.6, z2, E.Pedra)
		Kit.caixa(f, "Terra", x1 + 0.5, 2.6, z1 + 0.5, x2 - 0.5, 2.7, z2 - 0.5, E.Terra, { Sombra = false })
		local nx = math.max(1, math.floor((x2 - x1) / 4))
		for i = 1, nx do
			arbusto(f, Vector3.new(x1 + (x2 - x1) * (i - 0.5) / nx, 2.6, (z1 + z2) / 2), 2.4, rng)
		end
	end
	canteiroExterno(-26, 42, -8, 46)
	canteiroExterno(8, 50, 20, 54)
	canteiroExterno(-40, 54, -30, 64)
	canteiroExterno(-60, -20, -56, 0)
	-- carro do lado de fora
	Mv.carro(f, CFrame.new(30, 0.06, 47), rgb(150, 60, 50))
	-- balizadores de luz no caminho
	for _, p in { { -3, 44 }, { 3, 50 }, { -3, 56 }, { 3, 62 }, { 25, 42 }, { 35, 42 } } do
		Kit.cilindro(f, "Balizador", Vector3.new(p[1], 0, p[2]), 0.3, 1.6, E.Metal)
		local l = Kit.cilindro(f, "LuzBalizador", Vector3.new(p[1], 1.6, p[2]), 0.32, 0.25, E.Luz, { Sombra = false })
		Kit.luz(l, 0.6, 8)
	end
	-- depósito de madeira com telhado de uma água
	local dep = pasta(f, "Deposito")
	Kit.parede(dep, "Frente", "x", 45, 80, 95, 0, 8, 0.6, { { c = 87.5, w = 4, y0 = 0, y1 = 7, tipo = "porta" } }, E.MadeiraRipa)
	Kit.parede(dep, "Fundo", "x", 30, 80, 95, 0, 10, 0.6, nil, E.MadeiraRipa)
	Kit.parede(dep, "Oeste", "z", 80, 30, 45, 0, 9, 0.6, { { c = 37.5, w = 3, y0 = 4, y1 = 6.5, tipo = "janela" } }, E.MadeiraRipa)
	Kit.parede(dep, "Leste", "z", 95, 30, 45, 0, 9, 0.6, nil, E.MadeiraRipa)
	Kit.peca(dep, "Telhado", CFrame.new(87.5, 9.6, 37.5) * CFrame.Angles(math.rad(-7.6), 0, 0), Vector3.new(17, 0.4, 17.5), E.Metal)
	Mv.caixas(dep, CFrame.new(84, 0, 33), 3)
	Mv.bancadaFerramentas(dep, CFrame.new(90, 0, 31.6) * CFrame.Angles(0, math.rad(180), 0), 7)
end

local function muro(pai: Instance)
	local f = pasta(pai, "Muro")
	local function trecho(eixo: "x" | "z", fixo: number, de: number, ate: number, vaos: { Kit.Abertura })
		Kit.parede(f, "Muro", eixo, fixo, de, ate, -0.5, 5.6, 1.2, vaos, E.Pedra, { SemBatente = true })
		-- capa de concreto
		local a, b = math.min(de, ate), math.max(de, ate)
		local bordas = { a }
		for _, v in vaos do
			table.insert(bordas, v.c - v.w / 2)
			table.insert(bordas, v.c + v.w / 2)
		end
		table.insert(bordas, b)
		table.sort(bordas)
		for i = 1, #bordas - 1, 2 do
			if eixo == "x" then
				Kit.caixa(f, "Capa", bordas[i], 5.6, fixo - 0.8, bordas[i + 1], 6.1, fixo + 0.8, E.ConcretoLiso)
			else
				Kit.caixa(f, "Capa", fixo - 0.8, 5.6, bordas[i], fixo + 0.8, 6.1, bordas[i + 1], E.ConcretoLiso)
			end
		end
	end
	trecho("x", 100, -130, 130, { { c = -110, w = 10, y0 = -1, y1 = 7 } })
	trecho("x", -100, -130, 130, { { c = -40, w = 6, y0 = -1, y1 = 7 } })
	trecho("z", -130, -100, 100, { { c = -90, w = 6, y0 = -1, y1 = 7 } })
	trecho("z", 130, -100, 100, {})
	-- pilares e folhas do portão (abertas pra dentro)
	for _, x in { -115.6, -104.4 } do
		Kit.caixa(f, "PilarPortao", x - 0.8, 0, 99.2, x + 0.8, 7.5, 100.8, E.ConcretoLiso)
		local l = Kit.caixa(f, "LuzPilar", x - 0.4, 7.5, 99.6, x + 0.4, 8.1, 100.4, E.Luz, { Sombra = false }) :: Part
		Kit.luz(l, 0.8, 14)
	end
	Kit.peca(f, "FolhaPortao", CFrame.new(-114.6, 3, 97.5) * CFrame.Angles(0, math.rad(80), 0), Vector3.new(5, 5.5, 0.2), E.Metal)
	Kit.peca(f, "FolhaPortao", CFrame.new(-105.4, 3, 97.5) * CFrame.Angles(0, math.rad(-80), 0), Vector3.new(5, 5.5, 0.2), E.Metal)
	-- estrada lá fora
	Kit.caixa(f, "Estrada", -150, -0.3, 103, 150, 0.05, 116, { Cor = rgb(62, 62, 64), Mat = Enum.Material.Asphalt, Bal = "Pedra" }, { Sombra = false })
	for x = -146, 146, 8 do
		Kit.caixa(f, "Faixa", x, 0.05, 109.3, x + 4, 0.07, 109.7, { Cor = rgb(214, 180, 60), Mat = Enum.Material.SmoothPlastic }, { Sombra = false, Colide = false })
	end
	for _, x in { -130, -80, -30, 20, 70, 120 } do
		Kit.cilindro(f, "Poste", Vector3.new(x, 0, 103.5), 0.3, 14, E.Metal)
		Kit.caixa(f, "Braco", x - 0.15, 13.5, 103.5, x + 0.15, 13.8, 107, E.Metal)
		local l = Kit.caixa(f, "Lampada", x - 0.6, 13.2, 106.4, x + 0.6, 13.5, 107.6, E.Luz, { Sombra = false }) :: Part
		Kit.luz(l, 1, 26)
	end
	-- caixa de correio
	Kit.caixa(f, "Correio", -119.6, 0, 98, -119, 3.2, 98.6, E.Metal)
	Kit.caixa(f, "Correio", -120.2, 3.2, 97.6, -118.4, 4.4, 99, E.MadeiraEscura)
	-- cerca invisível no limite do mapa
	local inv: Kit.Estilo = { Cor = rgb(255, 255, 255), Mat = Enum.Material.SmoothPlastic, Transp = 1 }
	Kit.caixa(f, "Limite", -150, -1, -118, 150, 60, -116, inv)
	Kit.caixa(f, "Limite", -150, -1, 116, 150, 60, 118, inv)
	Kit.caixa(f, "Limite", -150, -1, -118, -148, 60, 118, inv)
	Kit.caixa(f, "Limite", 132, -1, -118, 134, 60, 118, inv)
end

local function marcadores(pai: Instance)
	local m = pasta(pai, "Marcadores")
	local sp = Instance.new("SpawnLocation")
	sp.Name = "Spawn_Guardas"
	sp.Anchored, sp.Neutral, sp.CanCollide, sp.Transparency, sp.Duration = true, true, false, 1, 0
	sp.Size = Vector3.new(4, 0.1, 4)
	sp.CFrame = CFrame.new(-6, 0.05, 8)
	local d = sp:FindFirstChildOfClass("Decal")
	if d then d:Destroy() end
	sp.Parent = m
	local function marca(nome: string, pos: Vector3, tam: Vector3)
		local p = Instance.new("Part")
		p.Name = nome
		p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.Transparency = true, false, false, false, 1
		p.Size = tam
		p.CFrame = CFrame.new(pos)
		p.Parent = m
	end
	marca("Spawn_IntrusosSul", Vector3.new(-118, 1, 110), Vector3.new(8, 2, 8))
	marca("Spawn_IntrusosOeste", Vector3.new(-140, 1, -90), Vector3.new(8, 2, 8))
	marca("Maleta_Escritorio", Vector3.new(36, 12, -20), Vector3.new(3, 2, 3))
	marca("Maleta_Adega", Vector3.new(-3, -10, -14), Vector3.new(3, 2, 3))
	marca("Maleta_Garagem", Vector3.new(38, 1, 20), Vector3.new(3, 2, 3))
	marca("Extracao_Norte", Vector3.new(-40, 1, -108), Vector3.new(10, 2, 10))
	marca("Extracao_Leste", Vector3.new(120, 1, -85), Vector3.new(12, 2, 12))
end

function Ambiente.construir(pai: Instance)
	terreno()
	task.wait()
	exterior(pai)
	task.wait()
	muro(pai)
	task.wait()
	natureza(pai)
	task.wait()
	marcadores(pai)
	Ambiente.luz()
end

return Ambiente
