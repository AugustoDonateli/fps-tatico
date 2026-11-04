--!strict
-- Kit modular da casa (camadas 1 e 2 do plano de arte): estilos, peças, paredes com batente, caixilho e rodapé,
-- lajes, forro rebaixado com spots, escada vazada, guarda-corpo de vidro e vigas.
-- Grade de 0,5 stud. Pé-direito 10. Porta 3,2 × 7,5. Parede interna 0,5, externa 1.

local Kit = {}

export type Estilo = {
	Cor: Color3,
	Mat: Enum.Material,
	Bal: string?, -- material balístico (Config.Materiais)
	Transp: number?,
	Refl: number?,
}

local function mat(nome: string, reserva: Enum.Material): Enum.Material
	local ok, m = pcall(function()
		return (Enum.Material :: any)[nome]
	end)
	return if ok and m then m else reserva
end
local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local SM = Enum.Material.SmoothPlastic
Kit.E = {
	-- estrutura
	Concreto = { Cor = rgb(178, 174, 166), Mat = Enum.Material.Concrete, Bal = "Concreto" },
	ConcretoLiso = { Cor = rgb(198, 194, 186), Mat = SM, Bal = "Concreto" },
	ConcretoEscuro = { Cor = rgb(96, 94, 90), Mat = Enum.Material.Concrete, Bal = "Concreto" },
	Pedra = { Cor = rgb(116, 112, 104), Mat = Enum.Material.Slate, Bal = "Pedra" },
	PedraClara = { Cor = rgb(172, 164, 150), Mat = Enum.Material.Limestone, Bal = "Pedra" },
	Reboco = { Cor = rgb(236, 232, 224), Mat = mat("Plaster", SM), Bal = "Gesso" },
	RebocoQuente = { Cor = rgb(226, 214, 194), Mat = mat("Plaster", SM), Bal = "Gesso" },
	RebocoVerde = { Cor = rgb(128, 140, 118), Mat = mat("Plaster", SM), Bal = "Gesso" },
	RebocoAzul = { Cor = rgb(104, 122, 138), Mat = mat("Plaster", SM), Bal = "Gesso" },
	RebocoTerra = { Cor = rgb(176, 120, 92), Mat = mat("Plaster", SM), Bal = "Gesso" },
	Madeira = { Cor = rgb(122, 90, 64), Mat = Enum.Material.WoodPlanks, Bal = "Madeira" },
	MadeiraClara = { Cor = rgb(178, 142, 104), Mat = Enum.Material.Wood, Bal = "Madeira" },
	MadeiraEscura = { Cor = rgb(88, 60, 42), Mat = Enum.Material.Wood, Bal = "Madeira" },
	MadeiraRipa = { Cor = rgb(104, 76, 54), Mat = Enum.Material.Wood, Bal = "Madeira" },
	-- pisos
	PisoMadeira = { Cor = rgb(146, 100, 64), Mat = Enum.Material.WoodPlanks, Bal = "Madeira" },
	PisoMadeiraClara = { Cor = rgb(184, 142, 100), Mat = Enum.Material.WoodPlanks, Bal = "Madeira" },
	Ceramica = { Cor = rgb(214, 210, 202), Mat = mat("CeramicTiles", Enum.Material.Marble), Bal = "Concreto" },
	CeramicaEscura = { Cor = rgb(88, 86, 82), Mat = mat("CeramicTiles", Enum.Material.Slate), Bal = "Concreto" },
	Porcelanato = { Cor = rgb(190, 186, 178), Mat = Enum.Material.Marble, Bal = "Concreto" },
	Carpete = { Cor = rgb(122, 114, 104), Mat = mat("Carpet", Enum.Material.Fabric), Bal = "Tecido" },
	CarpeteAzul = { Cor = rgb(70, 84, 102), Mat = mat("Carpet", Enum.Material.Fabric), Bal = "Tecido" },
	-- acabamento
	Metal = { Cor = rgb(40, 40, 42), Mat = Enum.Material.Metal, Bal = "MetalFino" },
	MetalClaro = { Cor = rgb(160, 160, 162), Mat = Enum.Material.Metal, Bal = "MetalFino" },
	Inox = { Cor = rgb(196, 198, 200), Mat = Enum.Material.Metal, Bal = "MetalFino", Refl = 0.25 },
	Vidro = { Cor = rgb(150, 182, 192), Mat = Enum.Material.Glass, Bal = "Vidro", Transp = 0.62, Refl = 0.15 },
	VidroFosco = { Cor = rgb(214, 222, 224), Mat = Enum.Material.Glass, Bal = "Vidro", Transp = 0.3 },
	Branco = { Cor = rgb(242, 240, 236), Mat = SM, Bal = "Plastico" },
	Preto = { Cor = rgb(28, 28, 30), Mat = SM, Bal = "Plastico" },
	Cinza = { Cor = rgb(120, 120, 122), Mat = SM, Bal = "Plastico" },
	Luz = { Cor = rgb(255, 236, 200), Mat = Enum.Material.Neon },
	-- tecidos e estofados
	TecidoCinza = { Cor = rgb(110, 108, 104), Mat = Enum.Material.Fabric, Bal = "Tecido" },
	TecidoBege = { Cor = rgb(196, 182, 160), Mat = Enum.Material.Fabric, Bal = "Tecido" },
	TecidoVerde = { Cor = rgb(84, 102, 82), Mat = Enum.Material.Fabric, Bal = "Tecido" },
	TecidoAzul = { Cor = rgb(62, 78, 98), Mat = Enum.Material.Fabric, Bal = "Tecido" },
	TecidoTerra = { Cor = rgb(160, 96, 66), Mat = Enum.Material.Fabric, Bal = "Tecido" },
	Couro = { Cor = rgb(98, 62, 42), Mat = mat("Leather", Enum.Material.Fabric), Bal = "Tecido" },
	Folha = { Cor = rgb(72, 104, 60), Mat = Enum.Material.Grass, Bal = "Tecido" },
	FolhaClara = { Cor = rgb(108, 132, 70), Mat = Enum.Material.Grass, Bal = "Tecido" },
	Terra = { Cor = rgb(74, 58, 44), Mat = Enum.Material.Ground, Bal = "Tecido" },
	Papelao = { Cor = rgb(170, 132, 90), Mat = mat("Cardboard", SM), Bal = "Tecido" },
}
local E = Kit.E

export type Opcoes = { Sombra: boolean?, Colide: boolean?, Forma: Enum.PartType? }

-- Peça básica.
function Kit.peca(pai: Instance, nome: string, cf: CFrame, tam: Vector3, est: Estilo, op: Opcoes?): Part
	local p = Instance.new("Part")
	p.Name = nome
	p.Anchored = true
	p.Size = tam
	p.CFrame = cf
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = est.Mat
	p.Color = est.Cor
	p.Transparency = est.Transp or 0
	p.Reflectance = est.Refl or 0
	if op then
		if op.Forma then
			p.Shape = op.Forma
		end
		if op.Sombra == false then
			p.CastShadow = false
		end
		if op.Colide == false then
			p.CanCollide = false
			p.CanTouch = false
		end
	end
	-- Peça pequena: sem sombra (regra de desempenho do plano).
	if tam.X * tam.Y * tam.Z < 0.4 then
		p.CastShadow = false
	end
	if est.Bal then
		p:SetAttribute("Balistico", est.Bal)
	end
	p.Parent = pai
	return p
end

-- Caixa pelos cantos.
function Kit.caixa(pai: Instance, nome: string, x1: number, y1: number, z1: number, x2: number, y2: number, z2: number, est: Estilo, op: Opcoes?): Part?
	local mn = Vector3.new(math.min(x1, x2), math.min(y1, y2), math.min(z1, z2))
	local mx = Vector3.new(math.max(x1, x2), math.max(y1, y2), math.max(z1, z2))
	local t = mx - mn
	if t.X < 0.01 or t.Y < 0.01 or t.Z < 0.01 then
		return nil
	end
	return Kit.peca(pai, nome, CFrame.new((mn + mx) / 2), t, est, op)
end

-- Cilindro em pé (eixo Y).
function Kit.cilindro(pai: Instance, nome: string, centroBase: Vector3, raio: number, altura: number, est: Estilo, op: Opcoes?): Part
	local o: Opcoes = op or {}
	o.Forma = Enum.PartType.Cylinder
	local cf = CFrame.new(centroBase + Vector3.new(0, altura / 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
	return Kit.peca(pai, nome, cf, Vector3.new(altura, raio * 2, raio * 2), est, o)
end

-- Viga entre dois pontos.
function Kit.viga(pai: Instance, nome: string, a: Vector3, b: Vector3, larg: number, alt: number, est: Estilo, op: Opcoes?): Part
	local meio = (a + b) / 2
	local cf = CFrame.lookAt(meio, b)
	return Kit.peca(pai, nome, cf, Vector3.new(larg, alt, (b - a).Magnitude), est, op)
end

export type Abertura = {
	c: number, -- centro no eixo da parede
	w: number,
	y0: number,
	y1: number,
	tipo: ("porta" | "janela" | "vao" | "vidro")?, -- vidro = painel de vidro do chão ao topo da abertura
	nome: string?, -- marca invisível (rotas, portas)
	batente: Estilo?, -- cor do batente/caixilho
}

export type OpParede = {
	LadoMenos: Estilo?, -- revestimento do lado de coordenada menor (x- ou z-)
	LadoMais: Estilo?,
	Rodape: boolean?, -- rodapé dos dois lados revestidos
	SemBatente: boolean?,
}

-- Parede reta, cortada em colunas pelas aberturas. eixo "x": corre em x, fica em z = fixo.
function Kit.parede(pai: Instance, nome: string, eixo: "x" | "z", fixo: number, de: number, ate: number, yBase: number, yTopo: number, esp: number, aberturas: { Abertura }?, est: Estilo, op: OpParede?): Model
	local m = Instance.new("Model")
	m.Name = nome
	local o: OpParede = op or {}
	local lista = aberturas or {}

	-- coordenadas: (ao longo, altura, através)
	local function caixaLocal(nm: string, a: number, b: number, y0: number, y1: number, t0: number, t1: number, e: Estilo, opc: Opcoes?)
		if b - a < 0.01 or y1 - y0 < 0.01 or t1 - t0 < 0.005 then
			return
		end
		if eixo == "x" then
			Kit.caixa(m, nm, a, y0, fixo + t0, b, y1, fixo + t1, e, opc)
		else
			Kit.caixa(m, nm, fixo + t0, y0, a, fixo + t1, y1, b, e, opc)
		end
	end
	local h = esp / 2
	local pele = 0.04
	local function cheio(a: number, b: number, y0: number, y1: number)
		local t0 = if o.LadoMenos then -h + pele else -h
		local t1 = if o.LadoMais then h - pele else h
		caixaLocal("Parede", a, b, y0, y1, t0, t1, est)
		if o.LadoMenos then
			caixaLocal("Revest", a, b, y0, y1, -h, -h + pele, o.LadoMenos, { Sombra = false })
		end
		if o.LadoMais then
			caixaLocal("Revest", a, b, y0, y1, h - pele, h, o.LadoMais, { Sombra = false })
		end
	end

	local ini, fim = math.min(de, ate), math.max(de, ate)
	local bordas = { ini, fim }
	for _, ab in lista do
		for _, x in { ab.c - ab.w / 2, ab.c + ab.w / 2 } do
			if x > ini and x < fim then
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
				local y0 = math.clamp(ab.y0, yBase, yTopo)
				local y1 = math.clamp(ab.y1, yBase, yTopo)
				cheio(a, b, y, math.max(y, y0))
				-- rodapé só onde a parede encosta no chão
				if o.Rodape and y == yBase and y0 > yBase + 0.4 then
					if o.LadoMenos then caixaLocal("Rodape", a, b, yBase, yBase + 0.35, -h - 0.08, -h, E.Branco, { Sombra = false }) end
					if o.LadoMais then caixaLocal("Rodape", a, b, yBase, yBase + 0.35, h, h + 0.08, E.Branco, { Sombra = false }) end
				end
				y = math.max(y, y1)
			end
			if o.Rodape and y == yBase then
				if o.LadoMenos then caixaLocal("Rodape", a, b, yBase, yBase + 0.35, -h - 0.08, -h, E.Branco, { Sombra = false }) end
				if o.LadoMais then caixaLocal("Rodape", a, b, yBase, yBase + 0.35, h, h + 0.08, E.Branco, { Sombra = false }) end
			end
			cheio(a, b, y, yTopo)
		end
	end

	-- Batentes, caixilhos, vidros e peitoris.
	for _, ab in lista do
		local a, b = ab.c - ab.w / 2, ab.c + ab.w / 2
		local tipo = ab.tipo or "vao"
		if not o.SemBatente and tipo ~= "vao" then
			local cor = ab.batente or (if tipo == "porta" then E.MadeiraClara else E.Metal)
			local f = if tipo == "porta" then 0.22 else 0.16
			local ex = h + (if tipo == "porta" then 0.06 else 0.02)
			local op2 = { Sombra = false }
			caixaLocal("Batente", a, a + f, ab.y0, ab.y1, -ex, ex, cor, op2)
			caixaLocal("Batente", b - f, b, ab.y0, ab.y1, -ex, ex, cor, op2)
			caixaLocal("Batente", a, b, ab.y1 - f, ab.y1, -ex, ex, cor, op2)
			if tipo ~= "porta" then
				caixaLocal("Batente", a, b, ab.y0, ab.y0 + f, -ex, ex, cor, op2)
				-- montantes a cada ~3 studs e travessa em portas de vidro
				local n = math.max(1, math.floor(ab.w / 3 + 0.5))
				for k = 1, n - 1 do
					local x = a + ab.w * k / n
					caixaLocal("Montante", x - f / 2, x + f / 2, ab.y0, ab.y1, -ex * 0.6, ex * 0.6, cor, op2)
				end
				caixaLocal("Vidro", a + f, b - f, ab.y0 + f, ab.y1 - f, -0.06, 0.06, E.Vidro, { Sombra = false })
				if tipo == "janela" and ab.y0 > yBase + 0.5 then
					caixaLocal("Peitoril", a - 0.2, b + 0.2, ab.y0 - 0.15, ab.y0, -h - 0.35, h + 0.35, E.PedraClara, op2)
				end
			end
		end
		if ab.nome then
			local marca = Instance.new("Part")
			marca.Name = ab.nome
			marca.Anchored = true
			marca.CanCollide = false
			marca.CanQuery = false
			marca.CanTouch = false
			marca.Transparency = 1
			if eixo == "x" then
				marca.Size = Vector3.new(ab.w, ab.y1 - ab.y0, esp)
				marca.CFrame = CFrame.new(ab.c, (ab.y0 + ab.y1) / 2, fixo)
			else
				marca.Size = Vector3.new(esp, ab.y1 - ab.y0, ab.w)
				marca.CFrame = CFrame.new(fixo, (ab.y0 + ab.y1) / 2, ab.c)
			end
			marca.Parent = m
		end
	end

	m.Parent = pai
	return m
end

-- Laje retangular com buracos { {x1, z1, x2, z2} }.
function Kit.laje(pai: Instance, nome: string, x1: number, z1: number, x2: number, z2: number, y0: number, y1: number, buracos: { { number } }?, est: Estilo, op: Opcoes?): Model
	local m = Instance.new("Model")
	m.Name = nome
	local bs = buracos or {}
	local xs, zs = { x1, x2 }, { z1, z2 }
	for _, b in bs do
		for _, x in { b[1], b[3] } do
			if x > x1 and x < x2 then table.insert(xs, x) end
		end
		for _, z in { b[2], b[4] } do
			if z > z1 and z < z2 then table.insert(zs, z) end
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
					Kit.caixa(m, "Laje", inicio, y0, za, xa, y1, zb, est, op)
					inicio = nil
				end
			end
			if inicio ~= nil then
				Kit.caixa(m, "Laje", inicio, y0, za, xs[#xs], y1, zb, est, op)
			end
		end
	end
	m.Parent = pai
	return m
end

-- Forro rebaixado: faixa de sanca em volta, miolo mais alto com fita de luz escondida, spots embutidos na faixa.
-- yLaje = face de baixo da laje. Spots: lista de {x, z}. Só os 2 primeiros spots fazem sombra.
function Kit.forro(pai: Instance, nome: string, x1: number, z1: number, x2: number, z2: number, yLaje: number, rebaixo: number, sanca: number, spots: { { number } }?, corLuz: Color3?): Model
	local m = Instance.new("Model")
	m.Name = nome
	local yb = yLaje - rebaixo
	local e = E.Branco
	Kit.caixa(m, "Sanca", x1, yb, z1, x2, yb + 0.25, z1 + sanca, e)
	Kit.caixa(m, "Sanca", x1, yb, z2 - sanca, x2, yb + 0.25, z2, e)
	Kit.caixa(m, "Sanca", x1, yb, z1 + sanca, x1 + sanca, yb + 0.25, z2 - sanca, e)
	Kit.caixa(m, "Sanca", x2 - sanca, yb, z1 + sanca, x2, yb + 0.25, z2 - sanca, e)
	-- miolo branco colado na laje e fita de luz quente na borda interna da sanca
	Kit.caixa(m, "Miolo", x1 + sanca, yLaje - 0.1, z1 + sanca, x2 - sanca, yLaje, z2 - sanca, e, { Sombra = false })
	local fita = Kit.caixa(m, "Fita", x1 + sanca, yb + 0.25, z1 + sanca, x2 - sanca, yb + 0.35, z1 + sanca + 0.12, E.Luz, { Sombra = false, Colide = false })
	if fita then
		local sl = Instance.new("SurfaceLight")
		sl.Face = Enum.NormalId.Top
		sl.Brightness = 0.6
		sl.Range = 10
		sl.Angle = 120
		sl.Color = corLuz or Color3.fromRGB(255, 214, 160)
		sl.Shadows = false
		sl.Parent = fita
	end
	for i, s in spots or {} do
		local p = Kit.cilindro(m, "Spot", Vector3.new(s[1], yb - 0.05, s[2]), 0.28, 0.08, E.Luz, { Sombra = false, Colide = false })
		local l = Instance.new("SpotLight")
		l.Face = Enum.NormalId.Left -- o cilindro tem o eixo X virado pra cima; Left aponta pra baixo
		l.Angle = 75
		l.Brightness = 1.6
		l.Range = 16
		l.Color = corLuz or Color3.fromRGB(255, 220, 176)
		l.Shadows = i <= 2
		l.Parent = p
	end
	m.Parent = pai
	return m
end

-- Escada vazada: degraus soltos de madeira grossa sobre uma longarina de aço.
-- Sobe de zIni (y0) até zFim (y1), largura xa..xb.
function Kit.escadaVazada(pai: Instance, nome: string, xa: number, xb: number, zIni: number, zFim: number, y0: number, y1: number, n: number): Model
	local m = Instance.new("Model")
	m.Name = nome
	local dz = (zFim - zIni) / n
	local dy = (y1 - y0) / n
	for i = 1, n do
		local top = y0 + dy * i
		local za = zIni + dz * (i - 1)
		Kit.caixa(m, "Degrau", xa, top - 0.35, za, xb, top, za + dz * 1.08, E.MadeiraClara)
	end
	local xc = (xa + xb) / 2
	Kit.viga(m, "Longarina", Vector3.new(xc, y0 - 0.4, zIni), Vector3.new(xc, y1 - 0.4, zFim), 0.8, 0.5, E.Metal)
	-- guarda-corpo do lado aberto (xa): vidro inclinado + corrimão
	local comp = math.sqrt((zFim - zIni) ^ 2 + (y1 - y0) ^ 2)
	local meio = Vector3.new(xa + 0.15, (y0 + y1) / 2 + 2, (zIni + zFim) / 2)
	local cf = CFrame.lookAt(meio, meio + Vector3.new(0, y1 - y0, zFim - zIni))
	Kit.peca(m, "VidroEscada", cf, Vector3.new(0.12, 3.2, comp), E.Vidro, { Sombra = false })
	Kit.peca(m, "Corrimao", cf * CFrame.new(0, 1.75, 0), Vector3.new(0.25, 0.2, comp), E.Inox, { Sombra = false })
	m.Parent = pai
	return m
end

-- Escada fechada (degraus maciços), pra porão e serviço.
function Kit.escadaMacica(pai: Instance, nome: string, xa: number, xb: number, zIni: number, zFim: number, y0: number, y1: number, n: number, est: Estilo): Model
	local m = Instance.new("Model")
	m.Name = nome
	local dz = (zFim - zIni) / n
	local dy = (y1 - y0) / n
	for i = 1, n do
		local za = zIni + dz * (i - 1)
		Kit.caixa(m, "Degrau", xa, y0, za, xb, y0 + dy * i, za + dz, est)
		Kit.caixa(m, "Bocel", xa, y0 + dy * i - 0.08, za + dz * 0.9, xb, y0 + dy * i, za + dz * 1.02, E.Metal, { Sombra = false })
	end
	m.Parent = pai
	return m
end

-- Guarda-corpo de vidro com corrimão e postes.
function Kit.guardaCorpo(pai: Instance, nome: string, eixo: "x" | "z", fixo: number, de: number, ate: number, y: number): Model
	local m = Instance.new("Model")
	m.Name = nome
	local a, b = math.min(de, ate), math.max(de, ate)
	local function cx(nm: string, p: number, q: number, y0: number, y1: number, t: number, e: Estilo)
		if eixo == "x" then
			Kit.caixa(m, nm, p, y0, fixo - t, q, y1, fixo + t, e, { Sombra = false })
		else
			Kit.caixa(m, nm, fixo - t, y0, p, fixo + t, y1, q, e, { Sombra = false })
		end
	end
	cx("Vidro", a, b, y + 0.15, y + 3.3, 0.06, E.Vidro)
	cx("Corrimao", a, b, y + 3.3, y + 3.55, 0.14, E.Inox)
	cx("Base", a, b, y, y + 0.15, 0.12, E.Metal)
	local n = math.max(1, math.floor((b - a) / 4))
	for k = 0, n do
		local p = a + (b - a) * k / n
		cx("Poste", p - 0.08, p + 0.08, y, y + 3.4, 0.08, E.Inox)
	end
	m.Parent = pai
	return m
end

-- Luz pontual dentro de uma peça (luminária).
function Kit.luz(p: BasePart, brilho: number, alcance: number, cor: Color3?, sombra: boolean?): PointLight
	local l = Instance.new("PointLight")
	l.Brightness = brilho
	l.Range = alcance
	l.Color = cor or Color3.fromRGB(255, 214, 168)
	l.Shadows = sombra == true
	l.Parent = p
	return l
end

return Kit
