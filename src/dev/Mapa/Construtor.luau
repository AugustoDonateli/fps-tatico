--!strict
-- Peças básicas pra montar mapa em blocos por código: caixa, parede com aberturas, laje com buracos e escada.
-- Tudo alinhado aos eixos. Medidas em studs. Usado só no Studio (ServerStorage.Dev).

local Construtor = {}

export type Props = {
	Cor: Color3?,
	Material: Enum.Material?,
	Balistico: string?, -- material balístico (Config.Materiais); vira atributo da peça
	Transparencia: number?,
	Colide: boolean?,
}

export type Abertura = {
	c: number, -- centro, na coordenada do eixo da parede
	w: number, -- largura
	y0: number, -- base (absoluta)
	y1: number, -- topo (absoluto)
	vidro: boolean?, -- coloca um vidro no vão
	nome: string?,
}

local VIDRO: Props = {
	Cor = Color3.fromRGB(170, 200, 215),
	Material = Enum.Material.Glass,
	Balistico = "Vidro",
	Transparencia = 0.55,
}

function Construtor.bloco(pai: Instance, nome: string, cf: CFrame, tamanho: Vector3, props: Props?): Part
	local pr = props or {}
	local p = Instance.new("Part")
	p.Name = nome
	p.Anchored = true
	p.Size = tamanho
	p.CFrame = cf
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = pr.Material or Enum.Material.SmoothPlastic
	p.Color = pr.Cor or Color3.fromRGB(200, 200, 200)
	p.Transparency = pr.Transparencia or 0
	if pr.Colide == false then
		p.CanCollide = false
	end
	if pr.Balistico then
		p:SetAttribute("Balistico", pr.Balistico)
	end
	p.Parent = pai
	return p
end

-- Caixa pelos cantos. Devolve nil se ficar sem volume.
function Construtor.caixa(
	pai: Instance,
	nome: string,
	x1: number,
	y1: number,
	z1: number,
	x2: number,
	y2: number,
	z2: number,
	props: Props?
): Part?
	local mn = Vector3.new(math.min(x1, x2), math.min(y1, y2), math.min(z1, z2))
	local mx = Vector3.new(math.max(x1, x2), math.max(y1, y2), math.max(z1, z2))
	local t = mx - mn
	if t.X < 0.01 or t.Y < 0.01 or t.Z < 0.01 then
		return nil
	end
	return Construtor.bloco(pai, nome, CFrame.new((mn + mx) / 2), t, props)
end

-- Parede reta. eixo "x": corre em x, fica em z = fixo. eixo "z": corre em z, fica em x = fixo.
function Construtor.parede(
	pai: Instance,
	nome: string,
	eixo: "x" | "z",
	fixo: number,
	de: number,
	ate: number,
	yBase: number,
	yTopo: number,
	espessura: number,
	aberturas: { Abertura }?,
	props: Props?
): Model
	local modelo = Instance.new("Model")
	modelo.Name = nome

	local function seg(a: number, b: number, y0: number, y1: number, nomeSeg: string, esp: number, pr: Props?)
		if b - a < 0.01 or y1 - y0 < 0.01 then
			return
		end
		if eixo == "x" then
			Construtor.caixa(modelo, nomeSeg, a, y0, fixo - esp / 2, b, y1, fixo + esp / 2, pr)
		else
			Construtor.caixa(modelo, nomeSeg, fixo - esp / 2, y0, a, fixo + esp / 2, y1, b, pr)
		end
	end

	-- Corta a parede em colunas nas bordas de todas as aberturas. Em cada coluna, preenche a altura
	-- que nenhuma abertura ocupa. Assim duas aberturas uma em cima da outra (porta e janela alta) funcionam.
	local lista = aberturas or {}
	local inicio, fim = math.min(de, ate), math.max(de, ate)
	local bordas = { inicio, fim }
	for _, ab in lista do
		for _, x in { ab.c - ab.w / 2, ab.c + ab.w / 2 } do
			if x > inicio and x < fim then
				table.insert(bordas, x)
			end
		end
	end
	table.sort(bordas)

	for i = 1, #bordas - 1 do
		local a, b = bordas[i], bordas[i + 1]
		if b - a > 0.01 then
			local meio = (a + b) / 2
			local furos = {}
			for _, ab in lista do
				if meio > ab.c - ab.w / 2 and meio < ab.c + ab.w / 2 then
					table.insert(furos, ab)
				end
			end
			table.sort(furos, function(p, q)
				return p.y0 < q.y0
			end)
			local y = yBase
			for _, ab in furos do
				seg(a, b, y, math.max(y, ab.y0), "Parede", espessura, props)
				if ab.vidro then
					seg(a, b, math.max(y, ab.y0), ab.y1, "Vidro", math.min(0.2, espessura), VIDRO)
				end
				y = math.max(y, ab.y1)
			end
			seg(a, b, y, yTopo, "Parede", espessura, props)
		end
	end

	-- Marca invisível em cada abertura com nome, pra achar portas e janelas depois (portas entram no passo 4).
	for _, ab in lista do
		if ab.nome then
			local marca = Instance.new("Part")
			marca.Name = ab.nome
			marca.Anchored = true
			marca.CanCollide = false
			marca.CanQuery = false
			marca.CanTouch = false
			marca.Transparency = 1
			if eixo == "x" then
				marca.Size = Vector3.new(ab.w, ab.y1 - ab.y0, espessura)
				marca.CFrame = CFrame.new(ab.c, (ab.y0 + ab.y1) / 2, fixo)
			else
				marca.Size = Vector3.new(espessura, ab.y1 - ab.y0, ab.w)
				marca.CFrame = CFrame.new(fixo, (ab.y0 + ab.y1) / 2, ab.c)
			end
			marca.Parent = modelo
		end
	end

	modelo.Parent = pai
	return modelo
end

-- Laje retangular com buracos retangulares { {x1, z1, x2, z2}, ... }.
-- Corta em grade e junta as células cheias de cada faixa, pra usar poucas peças.
function Construtor.laje(
	pai: Instance,
	nome: string,
	x1: number,
	z1: number,
	x2: number,
	z2: number,
	y0: number,
	y1: number,
	buracos: { { number } }?,
	props: Props?
): Model
	local modelo = Instance.new("Model")
	modelo.Name = nome
	local bs = buracos or {}

	local xs, zs = { x1, x2 }, { z1, z2 }
	for _, b in bs do
		for _, x in { b[1], b[3] } do
			if x > x1 and x < x2 then
				table.insert(xs, x)
			end
		end
		for _, z in { b[2], b[4] } do
			if z > z1 and z < z2 then
				table.insert(zs, z)
			end
		end
	end
	table.sort(xs)
	table.sort(zs)

	local function noBuraco(x: number, z: number): boolean
		for _, b in bs do
			if x > math.min(b[1], b[3]) and x < math.max(b[1], b[3]) and z > math.min(b[2], b[4]) and z < math.max(b[2], b[4]) then
				return true
			end
		end
		return false
	end

	for j = 1, #zs - 1 do
		local za, zb = zs[j], zs[j + 1]
		if zb - za > 0.01 then
			local inicio: number? = nil
			for i = 1, #xs - 1 do
				local xa, xb = xs[i], xs[i + 1]
				local cheia = xb - xa > 0.01 and not noBuraco((xa + xb) / 2, (za + zb) / 2)
				if cheia and inicio == nil then
					inicio = xa
				elseif not cheia and inicio ~= nil then
					Construtor.caixa(modelo, "Laje", inicio, y0, za, xa, y1, zb, props)
					inicio = nil
				end
			end
			if inicio ~= nil then
				Construtor.caixa(modelo, "Laje", inicio, y0, za, xs[#xs], y1, zb, props)
			end
		end
	end

	modelo.Parent = pai
	return modelo
end

-- Escada reta em z: sobe de zInicio (em yBase) até zFim (em yTopo). Largura de xa a xb.
function Construtor.escada(
	pai: Instance,
	nome: string,
	xa: number,
	xb: number,
	zInicio: number,
	zFim: number,
	yBase: number,
	yTopo: number,
	degraus: number,
	props: Props?
): Model
	local modelo = Instance.new("Model")
	modelo.Name = nome
	local dz = (zFim - zInicio) / degraus
	local dy = (yTopo - yBase) / degraus
	for i = 1, degraus do
		local za = zInicio + dz * (i - 1)
		Construtor.caixa(modelo, "Degrau" .. i, xa, yBase, za, xb, yBase + dy * i, za + dz, props)
	end
	modelo.Parent = pai
	return modelo
end

-- Escada de subir (treliça). O Humanoid sobe em TrussPart sozinho.
function Construtor.trelica(pai: Instance, nome: string, x: number, z: number, yBase: number, yTopo: number): TrussPart
	local t = Instance.new("TrussPart")
	t.Name = nome
	t.Anchored = true
	t.Size = Vector3.new(2, yTopo - yBase, 2)
	t.CFrame = CFrame.new(x, (yBase + yTopo) / 2, z)
	t.Color = Color3.fromRGB(90, 110, 70)
	t.Parent = pai
	return t
end

-- Marcador invisível (spawn, lugar de maleta, extração, cômodo).
function Construtor.marcador(pai: Instance, nome: string, centro: Vector3, tamanho: Vector3, cor: Color3?): Part
	local p = Instance.new("Part")
	p.Name = nome
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = tamanho
	p.CFrame = CFrame.new(centro)
	p.Color = cor or Color3.fromRGB(255, 200, 0)
	p.Transparency = 0.7
	p.Material = Enum.Material.Neon
	p.Parent = pai
	return p
end

return Construtor
