--!strict
-- Casa da Serra (etapa 1): estrutura, acabamento, móveis e luz de cada cômodo. Planta própria.
-- Eixos: +X leste, -Z norte. Térreo y 0, 1º andar y 11, porão y -11. Casa x -45..45, z -30..30.
-- As rotas e os lugares de maleta seguem docs/mapa/CasaDaSerra.md.

local Kit = require(script.Parent.Kit)
local Mv = require(script.Parent.Moveis)
local E = Kit.E

local Casa = {}

local T1 = 11
local P, PA = 3.2, 7.5

local function R(x: number, y: number, z: number, graus: number?): CFrame
	return CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(graus or 0), 0)
end
local function porta(c: number, y: number, nome: string?): Kit.Abertura
	return { c = c, w = P, y0 = y, y1 = y + PA, tipo = "porta", nome = nome }
end
local function janela(c: number, w: number, y0: number, y1: number, nome: string?): Kit.Abertura
	return { c = c, w = w, y0 = y0, y1 = y1, tipo = "janela", nome = nome }
end
local function vao(c: number, w: number, y0: number, y1: number, nome: string?): Kit.Abertura
	return { c = c, w = w, y0 = y0, y1 = y1, tipo = "vao", nome = nome }
end
local function pasta(pai: Instance, nome: string): Folder
	local f = Instance.new("Folder")
	f.Name = nome
	f.Parent = pai
	return f
end

----------------------------------------------------------------------------------------------------
-- Estrutura externa
----------------------------------------------------------------------------------------------------
local function fachadas(casa: Instance)
	local f = pasta(casa, "Fachadas")
	local ripa = { LadoMenos = nil :: Kit.Estilo?, LadoMais = nil :: Kit.Estilo? }
	local _ = ripa
	-- Térreo em pedra, 1º andar em madeira. Lado de dentro rebocado.
	local function dupla(nome: string, eixo: "x" | "z", fixo: number, de: number, ate: number, abT: { Kit.Abertura }, ab1: { Kit.Abertura }, dentroMenos: boolean)
		local dentro = E.Reboco
		local opT: Kit.OpParede = if dentroMenos then { LadoMenos = dentro, Rodape = false } else { LadoMais = dentro, Rodape = false }
		Kit.parede(f, nome .. "Terreo", eixo, fixo, de, ate, 0, T1 - 0.5, 1, abT, E.Pedra, opT)
		Kit.parede(f, nome .. "Faixa", eixo, fixo, de, ate, T1 - 0.5, T1 + 0.5, 1.4, nil, E.ConcretoLiso, { SemBatente = true })
		Kit.parede(f, nome .. "Andar", eixo, fixo, de, ate, T1 + 0.5, 22, 1, ab1, E.Madeira, opT)
	end
	-- Norte: cozinha (oeste), pano de vidro do átrio (centro), serviço/escritório (leste)
	dupla("NorteOeste", "x", -30, -45, -15, { porta(-30, 0, "Rota_PortaDosFundos"), janela(-22, 5, 3.5, 7.5) }, { janela(-33, 4, T1 + 3, T1 + 7) }, false)
	dupla("NorteLeste", "x", -30, 15, 45, { janela(30, 4, 4, 7.5) }, { janela(33, 4, T1 + 3, T1 + 7) }, false)
	-- Sul
	dupla("Sul", "x", 30, -45, 45, {
		porta(0, 0, "Rota_PortaDaFrente"),
		janela(-30, 6, 3, 7.5),
		janela(-8, 3, 2, 8), -- janela vertical ao lado da porta
		vao(30, 14, 0, 8.5, "Rota_PortaoGaragem"),
	}, {
		janela(0, 10, T1 + 2, T1 + 8),
		janela(-33, 4, T1 + 3, T1 + 7),
		janela(33, 4, T1 + 3, T1 + 7),
	}, true)
	dupla("Oeste", "z", -45, -30, 30, {
		vao(-17, 4, 2, 6.5, "Rota_JanelaCozinha"), -- janela deslizante aberta, peitoril baixo
		janela(12, 6, 3, 7.5),
	}, {
		janela(-18, 4, T1 + 3, T1 + 7),
		janela(0, 2, T1 + 4, T1 + 7),
		janela(18, 4, T1 + 3, T1 + 7),
	}, false)
	dupla("Leste", "z", 45, -30, 30, {
		porta(20, 0, "Rota_PortaLateralGaragem"),
		janela(-15, 4, 4, 7.5),
	}, {
		vao(-18, 4, T1 + 2, T1 + 7, "Rota_JanelaEscritorio"), -- aberta: chega pela trepadeira
		janela(0, 2, T1 + 4, T1 + 7),
		janela(18, 4, T1 + 3, T1 + 7),
	}, true)
	-- caixilho da janela aberta do escritório (sem vidro)
	Kit.caixa(f, "CaixilhoAberto", 44.4, T1 + 2, -20.1, 45.6, T1 + 2.2, -15.9, E.Metal)
	Kit.caixa(f, "CaixilhoAberto", 44.4, T1 + 6.8, -20.1, 45.6, T1 + 7, -15.9, E.Metal)

	-- Pano de vidro do átrio (x -15..15, z -30): montantes a cada 3, travessas, porta de correr no meio.
	local pv = pasta(f, "PanoDeVidro")
	Kit.caixa(pv, "Vidro", -15, 0, -30.05, -4, 22, -29.95, E.Vidro, { Sombra = false })
	Kit.caixa(pv, "Vidro", 4, 0, -30.05, 15, 22, -29.95, E.Vidro, { Sombra = false })
	Kit.caixa(pv, "Vidro", -4, 8.2, -30.05, 4, 22, -29.95, E.Vidro, { Sombra = false })
	for x = -15, 15, 3 do
		Kit.caixa(pv, "Montante", x - 0.15, 0, -30.35, x + 0.15, 22, -29.65, E.Metal)
	end
	Kit.caixa(pv, "Travessa", -15, 8, -30.35, 15, 8.3, -29.65, E.Metal)
	Kit.caixa(pv, "Travessa", -15, 15.5, -30.3, 15, 15.7, -29.7, E.Metal)
	Kit.caixa(pv, "Laje", -15, 10.2, -30.6, 15, 11, -29.4, E.ConcretoLiso)
	local rota = Instance.new("Part")
	rota.Name = "Rota_PortaDeVidro"
	rota.Anchored, rota.CanCollide, rota.CanQuery, rota.CanTouch, rota.Transparency = true, false, false, false, 1
	rota.Size = Vector3.new(8, 8, 1)
	rota.CFrame = CFrame.new(0, 4, -30)
	rota.Parent = pv
	-- folha de correr aberta, encostada por fora
	Kit.caixa(pv, "FolhaCorrer", 4.2, 0.1, -30.6, 8.2, 8, -30.45, E.Vidro, { Sombra = false })
	Kit.caixa(pv, "FolhaMoldura", 4.2, 0.1, -30.65, 4.4, 8, -30.4, E.Metal)
	Kit.caixa(pv, "Trilho", -8, 0, -30.7, 8.5, 0.12, -30.3, E.Metal)

	-- Ripado vertical de madeira no 1º andar (sul e oeste), fora das janelas.
	local rip = pasta(f, "Ripado")
	local function ripado(eixo: "x" | "z", fixo: number, de: number, ate: number, sinal: number, livres: { { number } })
		local x = de + 0.75
		while x < ate - 0.5 do
			local livre = true
			for _, l in livres do
				if x > l[1] - 0.4 and x < l[2] + 0.4 then
					livre = false
				end
			end
			if livre then
				local t0 = fixo + sinal * 0.5
				if eixo == "x" then
					Kit.caixa(rip, "Ripa", x - 0.18, T1 + 0.5, t0, x + 0.18, 21.6, t0 + sinal * 0.35, E.MadeiraRipa, { Sombra = false })
				else
					Kit.caixa(rip, "Ripa", t0, T1 + 0.5, x - 0.18, t0 + sinal * 0.35, 21.6, x + 0.18, E.MadeiraRipa, { Sombra = false })
				end
			end
			x += 1.2
		end
	end
	ripado("x", 30, -45, 45, 1, { { -5, 5 }, { -35, -31 }, { 31, 35 } })
	ripado("z", -45, -30, 30, -1, { { -20, -16 }, { -1, 1 }, { 16, 20 } })

	-- Telhado: laje, beiral em balanço, platibanda fina e claraboia elevada sobre o átrio.
	local tel = pasta(casa, "Telhado")
	Kit.laje(tel, "Laje", -45, -30, 45, 30, 21, 22, { { -10, -24, 10, -4 } }, E.ConcretoLiso)
	Kit.laje(tel, "Beiral", -48, -33, 48, 33, 22, 22.6, { { -45, -30, 45, 30 } }, E.ConcretoEscuro)
	Kit.laje(tel, "Cobertura", -45, -30, 45, 30, 22, 22.3, { { -10, -24, 10, -4 } }, { Cor = Color3.fromRGB(84, 84, 86), Mat = Enum.Material.Pebble, Bal = "Concreto" })
	Kit.caixa(tel, "Testeira", -48, 22, -33.3, 48, 23, -33, E.Metal)
	Kit.caixa(tel, "Testeira", -48, 22, 33, 48, 23, 33.3, E.Metal)
	Kit.caixa(tel, "Testeira", -48.3, 22, -33.3, -48, 23, 33.3, E.Metal)
	Kit.caixa(tel, "Testeira", 48, 22, -33.3, 48.3, 23, 33.3, E.Metal)
	-- claraboia: mureta, vidro inclinado em 2 águas e vigas de madeira por baixo
	Kit.caixa(tel, "Mureta", -10.5, 22, -24.5, 10.5, 24, -24, E.ConcretoLiso)
	Kit.caixa(tel, "Mureta", -10.5, 22, -4, 10.5, 24, -3.5, E.ConcretoLiso)
	Kit.caixa(tel, "Mureta", -10.5, 22, -24, -10, 24, -4, E.ConcretoLiso)
	Kit.caixa(tel, "Mureta", 10, 22, -24, 10.5, 24, -4, E.ConcretoLiso)
	Kit.caixa(tel, "VidroClaraboia", -10, 24, -24, 10, 24.15, -4, E.Vidro, { Sombra = false })
	for x = -10, 10, 4 do
		Kit.caixa(tel, "PerfilClaraboia", x - 0.1, 24.15, -24, x + 0.1, 24.3, -4, E.Metal, { Sombra = false })
	end
	for z = -23, -5, 2.25 do
		Kit.caixa(tel, "Viga", -10, 20.2, z - 0.3, 10, 21, z + 0.3, E.MadeiraClara)
	end
	Kit.caixa(tel, "VigaMestra", -7.2, 19.6, -24, -6.6, 20.2, -4, E.MadeiraEscura)
	Kit.caixa(tel, "VigaMestra", 6.6, 19.6, -24, 7.2, 20.2, -4, E.MadeiraEscura)

	-- Marquise da entrada e pilar de pedra
	Kit.caixa(f, "Marquise", -7, 9, 30.5, 9, 9.6, 37, E.ConcretoLiso)
	Kit.caixa(f, "MarquiseFaixa", -7, 8.8, 36.8, 9, 9.6, 37.1, E.Metal)
	Kit.caixa(f, "Pilar", 7.5, 0, 35.5, 8.7, 9, 36.7, E.Pedra)
	local arandela = Kit.caixa(f, "Arandela", -2.6, 6, 30.5, -2, 6.8, 30.7, E.Luz, { Sombra = false }) :: Part
	Kit.luz(arandela, 1, 12)
	local arandela2 = Kit.caixa(f, "Arandela", 2, 6, 30.5, 2.6, 6.8, 30.7, E.Luz, { Sombra = false }) :: Part
	Kit.luz(arandela2, 1, 12)
	-- número da casa
	Kit.caixa(f, "Placa", -6, 5.5, 30.5, -4, 6.4, 30.6, E.Metal, { Sombra = false })

	-- Portão basculante da garagem aberto (painel lá em cima, na horizontal)
	Kit.caixa(f, "Portao", 23.2, 8.5, 25, 36.8, 8.8, 30, E.Metal)
	for x = 24, 36, 2 do
		Kit.caixa(f, "Friso", x - 0.05, 8.45, 25.1, x + 0.05, 8.5, 29.9, E.MetalClaro, { Sombra = false })
	end

	-- Trepadeira (escada de treliça) até a janela do escritório, com folhagem
	local t = Instance.new("TrussPart")
	t.Name = "Trepadeira"
	t.Anchored = true
	t.Size = Vector3.new(2, T1 + 2, 2)
	t.CFrame = CFrame.new(46.6, (T1 + 2) / 2, -18)
	t.Color = Color3.fromRGB(70, 92, 52)
	t.Parent = f
	local rng = Random.new(5)
	for i = 1, 14 do
		Kit.peca(f, "FolhaTrepadeira", CFrame.new(46.3 + rng:NextNumber(-0.3, 0.6), rng:NextNumber(0.5, T1 + 1.5), -18 + rng:NextNumber(-1.8, 1.8)) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), 0), Vector3.new(1.4, 0.15, 1), E.Folha, { Colide = false, Sombra = false })
	end
end

----------------------------------------------------------------------------------------------------
-- Lajes e pisos
----------------------------------------------------------------------------------------------------
local function pisos(casa: Instance)
	local f = pasta(casa, "Pisos")
	local buracoPorao = { 28, -28, 34, -6 }
	Kit.laje(f, "LajeTerreo", -45, -30, 45, 30, -1, -0.15, { buracoPorao }, E.Concreto)
	Kit.laje(f, "Laje1Andar", -45, -30, 45, 30, 10, 10.85, { { -15, -30, 9, 12 }, { 9, -24, 15, 12 } }, E.Concreto)
	Kit.caixa(f, "LajePorao", -15, -12, -30, 45, -11.15, 0, E.Concreto)
	local function piso(nome: string, x1: number, z1: number, x2: number, z2: number, y: number, e: Kit.Estilo, buracos: { { number } }?)
		Kit.laje(f, nome, x1, z1, x2, z2, y - 0.15, y, buracos, e, { Sombra = false })
	end
	-- térreo
	piso("Cozinha", -45, -30, -15, -4, 0, E.Ceramica)
	piso("Jantar", -45, -4, -15, 30, 0, E.PisoMadeira)
	piso("Atrio", -15, -30, 15, 18, 0, E.Porcelanato)
	piso("Hall", -15, 18, 15, 30, 0, E.Porcelanato)
	piso("Servico", 15, -30, 45, 0, 0, E.Ceramica, { buracoPorao })
	piso("Garagem", 15, 0, 45, 30, 0, E.ConcretoLiso)
	-- 1º andar
	piso("Galeria", -21, -30, 21, 30, T1, E.PisoMadeira, { { -15, -30, 9, 12 }, { 9, -24, 15, 12 } })
	piso("Quarto1", -45, -30, -21, -6, T1, E.Carpete)
	piso("Banho1", -45, -6, -21, 6, T1, E.Ceramica)
	piso("Quarto2", -45, 6, -21, 30, T1, E.CarpeteAzul)
	piso("Escritorio", 21, -30, 45, -6, T1, E.PisoMadeiraClara)
	piso("Banho2", 21, -6, 45, 6, T1, E.Ceramica)
	piso("Quarto4", 21, 6, 45, 30, T1, E.Carpete)
	-- porão
	piso("Adega", -15, -30, 15, 0, -11, E.CeramicaEscura)
	piso("Lavanderia", 15, -30, 45, 0, -11, E.Concreto)
end

----------------------------------------------------------------------------------------------------
-- Paredes internas
----------------------------------------------------------------------------------------------------
local function paredes(casa: Instance)
	local f = pasta(casa, "Paredes")
	local y0, y1 = T1, 21
	-- térreo
	Kit.parede(f, "CozinhaJantarAtrio", "z", -15, -30, 30, 0, 10, 0.5, { vao(-14, 6, 0, 8), vao(8, 8, 0, 8), porta(24, 0) }, E.Reboco, { LadoMenos = E.Reboco, LadoMais = E.PedraClara, Rodape = true })
	Kit.parede(f, "CozinhaJantar", "x", -4, -45, -15, 0, 10, 0.5, { porta(-30, 0) }, E.Reboco, { LadoMenos = E.Reboco, LadoMais = E.RebocoVerde, Rodape = true })
	Kit.parede(f, "AtrioServico", "z", 15, -30, 30, 0, 10, 0.5, { porta(-27, 0), porta(24, 0) }, E.Reboco, { LadoMenos = E.Reboco, LadoMais = E.ConcretoLiso, Rodape = true })
	Kit.parede(f, "ServicoGaragem", "x", 0, 15, 45, 0, 10, 0.5, { porta(24, 0) }, E.ConcretoLiso, { LadoMenos = E.Reboco, LadoMais = E.ConcretoLiso })
	Kit.parede(f, "AtrioHall", "x", 18, -15, 15, 0, 10, 0.5, { vao(0, 14, 0, 8) }, E.Reboco, { LadoMenos = E.Reboco, LadoMais = E.RebocoQuente, Rodape = true })
	-- revestimento de madeira na viga sobre o vão do hall
	Kit.caixa(f, "VigaHall", -7, 8, 17.6, 7, 10, 18.4, E.MadeiraEscura)
	-- 1º andar
	Kit.parede(f, "AlaOeste", "z", -21, -30, 30, y0, y1, 0.5, { porta(-18, y0), porta(0, y0), porta(12, y0) }, E.Reboco, { LadoMenos = E.Reboco, LadoMais = E.Reboco, Rodape = true })
	Kit.parede(f, "Q1Banho", "x", -6, -45, -21, y0, y1, 0.5, nil, E.Reboco, { LadoMenos = E.RebocoAzul, LadoMais = E.Ceramica, Rodape = true })
	Kit.parede(f, "BanhoQ2", "x", 6, -45, -21, y0, y1, 0.5, nil, E.Reboco, { LadoMenos = E.Ceramica, LadoMais = E.RebocoTerra, Rodape = true })
	Kit.parede(f, "AlaLeste", "z", 21, -30, 30, y0, y1, 0.5, { porta(-18, y0), porta(0, y0), porta(12, y0) }, E.Reboco, { LadoMenos = E.Reboco, LadoMais = E.Reboco, Rodape = true })
	Kit.parede(f, "EscBanho", "x", -6, 21, 45, y0, y1, 0.5, nil, E.Reboco, { LadoMenos = E.RebocoVerde, LadoMais = E.Ceramica, Rodape = true })
	Kit.parede(f, "BanhoQ4", "x", 6, 21, 45, y0, y1, 0.5, nil, E.Reboco, { LadoMenos = E.Ceramica, LadoMais = E.RebocoQuente, Rodape = true })
	Kit.parede(f, "Quarto3", "x", 18, -21, 21, y0, y1, 0.5, { porta(0, y0) }, E.Reboco, { LadoMenos = E.Reboco, LadoMais = E.RebocoAzul, Rodape = true })
	-- guarda-corpos da galeria
	Kit.guardaCorpo(f, "GuardaOeste", "z", -15, -30, 12, T1)
	Kit.guardaCorpo(f, "GuardaSul", "x", 12, -15, 15, T1)
	Kit.guardaCorpo(f, "GuardaLeste", "z", 15, -24, 12, T1)
	Kit.guardaCorpo(f, "GuardaPatamar", "z", 9, -30, -24, T1)
	-- testa da laje vista do átrio
	Kit.caixa(f, "TestaLaje", -15.1, 10, -30, -14.9, 11, 12, E.Branco)
	Kit.caixa(f, "TestaLaje", -15, 10, 11.9, 15, 11, 12.1, E.Branco)
	Kit.caixa(f, "TestaLaje", 14.9, 10, -24, 15.1, 11, 12, E.Branco)
	-- porão
	Kit.parede(f, "PoraoNorte", "x", -30, -15, 45, -12, -1, 1, nil, E.ConcretoEscuro, { LadoMais = E.ConcretoLiso })
	Kit.parede(f, "PoraoSul", "x", 0, -15, 45, -12, -1, 1, nil, E.ConcretoEscuro, { LadoMenos = E.ConcretoLiso })
	Kit.parede(f, "PoraoOeste", "z", -15, -30, 0, -12, -1, 1, nil, E.ConcretoEscuro, { LadoMais = E.ConcretoLiso })
	Kit.parede(f, "PoraoLeste", "z", 45, -30, 0, -12, -1, 1, { vao(-20, 4, -11, -4, "Rota_DutoPorao") }, E.ConcretoEscuro, { LadoMenos = E.ConcretoLiso })
	Kit.parede(f, "AdegaLavanderia", "z", 15, -30, 0, -11, -1, 0.5, { porta(-15, -11) }, E.ConcretoLiso, { LadoMenos = E.RebocoTerra, LadoMais = E.ConcretoLiso })
	-- grade de proteção em volta da escada do porão
	Kit.guardaCorpo(f, "GuardaPoraoO", "z", 27.85, -28, -6, 0)
	Kit.guardaCorpo(f, "GuardaPoraoL", "z", 34.15, -28, -6, 0)
	Kit.guardaCorpo(f, "GuardaPoraoN", "x", -28.15, 28, 34, 0)
	-- duto do porão: túnel e poço com escada até a grade no jardim
	local d = pasta(casa, "Duto")
	Kit.caixa(d, "Piso", 45, -12, -22, 64, -11, -18, E.ConcretoEscuro)
	Kit.caixa(d, "Teto", 45, -4, -22, 60, -3, -18, E.ConcretoEscuro)
	Kit.caixa(d, "LadoN", 45, -11, -23, 64, -1, -22, E.ConcretoEscuro)
	Kit.caixa(d, "LadoS", 45, -11, -18, 64, -1, -17, E.ConcretoEscuro)
	Kit.caixa(d, "Fundo", 64, -11, -22, 65, -1, -18, E.ConcretoEscuro)
	local tr = Instance.new("TrussPart")
	tr.Name = "EscadaDuto"
	tr.Anchored = true
	tr.Size = Vector3.new(2, 11, 2)
	tr.CFrame = CFrame.new(62.5, -5.5, -20)
	tr.Color = Color3.fromRGB(60, 60, 62)
	tr.Parent = d
	for x = 60.3, 63.8, 0.5 do
		Kit.caixa(d, "Grade", x - 0.06, -0.15, -22, x + 0.06, 0.05, -18, E.Metal, { Colide = false, Sombra = false })
	end
end

----------------------------------------------------------------------------------------------------
-- Forros e luz dos cômodos
----------------------------------------------------------------------------------------------------
local function forros(casa: Instance)
	local f = pasta(casa, "Forros")
	local qt = Color3.fromRGB(255, 212, 160)
	Kit.forro(f, "Hall", -15, 18, 15, 30, 10, 0.8, 1.6, { { -9, 22 }, { 9, 22 }, { -3, 26 }, { 3, 26 } }, qt)
	Kit.forro(f, "AtrioBaixo", -15, 12, 15, 18, 10, 0.6, 1.2, { { -10, 15 }, { 0, 15 }, { 10, 15 } }, qt)
	Kit.forro(f, "Cozinha", -45, -30, -15, -4, 10, 0.8, 1.8, { { -40, -23 }, { -30, -23 }, { -21, -23 }, { -40, -10 }, { -21, -10 } }, Color3.fromRGB(255, 232, 200))
	Kit.forro(f, "Jantar", -45, -4, -15, 30, 10, 0.8, 1.8, { { -40, 0 }, { -20, 0 }, { -40, 24 }, { -20, 24 } }, qt)
	-- 1º andar: luminária de teto simples (painel com luz)
	local function plafon(x: number, z: number, cor: Color3?)
		local p = Kit.caixa(f, "Plafon", x - 1.2, 20.75, z - 1.2, x + 1.2, 21, z + 1.2, E.Luz, { Sombra = false, Colide = false }) :: Part
		Kit.luz(p, 0.8, 18, cor)
	end
	plafon(-33, -18)
	plafon(-33, 0)
	plafon(-33, 18)
	plafon(0, 24)
	plafon(33, -18, Color3.fromRGB(240, 236, 226))
	plafon(33, 0)
	plafon(33, 18)
	-- porão: luminárias tubulares frias
	local function tubo(x1: number, x2: number, z: number, y: number)
		local p = Kit.caixa(f, "Tubo", x1, y - 0.25, z - 0.15, x2, y, z + 0.15, { Cor = Color3.fromRGB(220, 236, 255), Mat = Enum.Material.Neon }, { Sombra = false, Colide = false }) :: Part
		Kit.luz(p, 0.9, 16, Color3.fromRGB(205, 225, 255))
	end
	tubo(-6, 6, -23, -1.2)
	tubo(-6, 6, -8, -1.2)
	tubo(18, 26, -15, -1.2)
	tubo(36, 44, -10, -1.2)
	tubo(18, 26, -15, 9.8) -- serviço
	tubo(26, 34, 15, 9.8) -- garagem
	tubo(26, 34, 5, 9.8)
end

----------------------------------------------------------------------------------------------------
-- Átrio: escada vazada, canteiros, sala de estar, pendentes
----------------------------------------------------------------------------------------------------
local function atrio(casa: Instance)
	local f = pasta(casa, "Atrio")
	Kit.escadaVazada(f, "EscadaPrincipal", 9.4, 14.7, 0, -24, 0, T1, 15)
	Mv.canteiro(f, -6, -19, 3, -12, 0, 1.4)
	Mv.canteiro(f, 9.6, -13, 14.6, -2, 0, 1.0) -- embaixo da escada
	-- estar
	Mv.tapete(f, R(-5, 0, -2.5), 11, 8, E.TecidoCinza)
	Mv.sofa(f, R(-5, 0, 1.8), 8, E.TecidoBege)
	Mv.sofa(f, R(-11.4, 0, -3.6, -90), 5.5, E.TecidoBege)
	Mv.poltrona(f, R(1.8, 0, -4, 90), E.Couro)
	Mv.mesaCentro(f, R(-5, 0, -3), 4.2, 2.6)
	Mv.luminariaChao(f, Vector3.new(-12.6, 0, 1.6))
	Mv.estante(f, R(-14.15, 0, -9.5, -90), 3.4, 7.5, 5)
	-- canto de leitura junto do vidro
	Mv.poltrona(f, R(-11.5, 0, -26), E.TecidoVerde)
	Mv.poltrona(f, R(-7.5, 0, -26), E.TecidoTerra)
	Kit.cilindro(f, "MesaApoio", Vector3.new(-9.5, 0, -26.4), 0.8, 1.8, E.MadeiraClara)
	Mv.planta(f, Vector3.new(-13.4, 0, -28.3), 7)
	Mv.planta(f, Vector3.new(7.6, 0, -28.4), 6)
	Mv.planta(f, Vector3.new(6.5, 0, 9.5), 5.5)
	Mv.planta(f, Vector3.new(-13.2, 0, 10.5), 6)
	-- quadros na parede do hall, virados pro átrio
	Mv.quadro(f, R(-11, 5, 17.7), 5, 3.5)
	Mv.quadro(f, R(11, 5, 17.7), 4, 5)
	-- pendentes descendo do teto do átrio
	for i, p in { { -8, -6 }, { -5, -2 }, { -2, -6 } } do
		local x, z = p[1], p[2]
		local yb = 11 + i
		Kit.caixa(f, "Cabo", x - 0.03, yb + 1, z - 0.03, x + 0.03, 21, z + 0.03, E.Preto, { Sombra = false, Colide = false })
		local c = Kit.cilindro(f, "Pendente", Vector3.new(x, yb, z), 0.9, 1, E.Metal, { Sombra = false, Colide = false })
		local l = Kit.cilindro(f, "Lampada", Vector3.new(x, yb - 0.08, z), 0.6, 0.08, E.Luz, { Sombra = false, Colide = false })
		Kit.luz(l, 1.2, 18, nil, i == 2)
		local _ = c
	end
	-- sofá na galeria sul, olhando pro átrio
	Mv.sofa(f, R(9, T1, 16.5), 5, E.TecidoVerde)
	Mv.planta(f, Vector3.new(-13.3, T1, 16.5), 6)
	Mv.planta(f, Vector3.new(19.2, T1, -28.5), 5)
	Mv.estante(f, R(-20.15, T1, -12, -90), 6, 8, 5)
	-- vida no hall
	Mv.mesaTrabalho(f, R(-11.5, 0, 28.6, 180), 4)
	Mv.planta(f, Vector3.new(12.5, 0, 28), 6)
	Mv.planta(f, Vector3.new(-13.4, 0, 20), 4.5)
	Mv.quadro(f, R(-14.65, 5.5, 24, -90), 3, 4)
	Mv.tapete(f, R(0, 0, 27.5), 5, 3, E.TecidoTerra)
end

----------------------------------------------------------------------------------------------------
-- Demais cômodos
----------------------------------------------------------------------------------------------------
local function comodos(casa: Instance)
	local f = pasta(casa, "Moveis")
	-- Cozinha
	Mv.bancada(f, R(-38.5, 0, -28.3, 180), 11, true)
	Mv.aereo(f, R(-38.5, 0, -28.3, 180), 11)
	Mv.bancada(f, R(-21.5, 0, -28.3, 180), 11, false, true)
	Mv.geladeira(f, R(-43.2, 0, -8.5, -90))
	Mv.bancada(f, R(-29, 0, -17), 8, false, false)
	for _, x in { -32, -29, -26 } do
		Mv.banqueta(f, Vector3.new(x, 0, -14.6))
	end
	for _, x in { -31, -27 } do
		Kit.caixa(f, "CaboPendente", x - 0.03, 6.5, -17.03, x + 0.03, 9.2, -16.97, E.Preto, { Sombra = false, Colide = false })
		local l = Kit.cilindro(f, "PendenteIlha", Vector3.new(x, 6, -17), 0.5, 0.6, E.Luz, { Sombra = false, Colide = false })
		Kit.luz(l, 0.8, 10)
	end
	Mv.planta(f, Vector3.new(-17, 0, -6), 5)
	-- Jantar e estar de TV
	Mv.tapete(f, R(-32, 0, 11), 13, 8, E.TecidoTerra)
	Mv.mesaJantar(f, R(-32, 0, 11), 9, 4, 3)
	Kit.caixa(f, "PendenteLinear", -36, 6.6, 10.7, -28, 7.0, 11.3, E.Metal, { Sombra = false, Colide = false })
	local lj = Kit.caixa(f, "LuzLinear", -35.8, 6.5, 10.8, -28.2, 6.6, 11.2, E.Luz, { Sombra = false, Colide = false }) :: Part
	Kit.luz(lj, 1, 14)
	Mv.quadro(f, R(-32, 5.5, -3.6, 180), 6, 3.5)
	Mv.rackTV(f, R(-16, 0, 17, 90), 7)
	Mv.sofa(f, R(-25, 0, 17, -90), 7, E.TecidoAzul)
	Mv.tapete(f, R(-21, 0, 17), 6, 8, E.TecidoBege)
	Mv.planta(f, Vector3.new(-43.5, 0, -2.5), 6)
	Mv.planta(f, Vector3.new(-43.5, 0, 28.5), 5)
	-- Serviço
	Mv.estante(f, R(40, 0, -28.9, 180), 8, 8, 4)
	Mv.geladeira(f, R(16.6, 0, -15, -90))
	Mv.caixas(f, R(41, 0, -4), 3)
	Mv.caixas(f, R(38, 0, -3), 2)
	-- Garagem
	Mv.carro(f, R(21.6, 0, 12, 180), Color3.fromRGB(70, 82, 96))
	Mv.bancadaFerramentas(f, R(43.3, 0, 8, 90), 8)
	Mv.estante(f, R(37, 0, 0.9, 180), 8, 8, 4)
	Mv.caixas(f, R(42, 0, 27), 3)
	Mv.caixas(f, R(17.5, 0, 27.5), 2)
	-- Quarto 1
	Mv.cama(f, R(-40.6, T1, -12, -90), 5, E.TecidoAzul)
	Mv.criadoMudo(f, R(-43.6, T1, -16.2, -90), true)
	Mv.criadoMudo(f, R(-43.6, T1, -7.8, -90), true)
	Mv.guardaRoupa(f, R(-31, T1, -7.4), 6)
	Mv.mesaTrabalho(f, R(-33, T1, -28.4, 180), 5, true)
	Mv.cadeiraEscritorio(f, R(-33, T1, -26.4))
	Mv.quadro(f, R(-44.4, T1 + 6.5, -12, -90), 4, 2.6)
	Mv.tapete(f, R(-35, T1, -12), 5, 7, E.TecidoBege)
	-- Banheiro 1
	Mv.box(f, R(-42.25, T1, -3.6, -90), 4.2, 4.5)
	Mv.vaso(f, R(-43.7, T1, 3.6, -90))
	Mv.pia(f, R(-31, T1, 4.8), 4)
	-- Quarto 2
	Mv.cama(f, R(-40.6, T1, 24, -90), 5, E.TecidoTerra)
	Mv.criadoMudo(f, R(-43.6, T1, 20.2, -90), true)
	Mv.guardaRoupa(f, R(-31, T1, 7.4, 180), 6)
	Mv.mesaTrabalho(f, R(-33, T1, 28.4), 5, true)
	Mv.cadeiraEscritorio(f, R(-33, T1, 26.4, 180))
	Mv.caixas(f, R(-24, T1, 28), 2)
	-- Quarto 3 (suíte da frente)
	Mv.cama(f, R(-16.9, T1, 24, -90), 6, E.TecidoBege)
	Mv.criadoMudo(f, R(-19.9, T1, 19.9, -90), true)
	Mv.criadoMudo(f, R(-19.9, T1, 28.1, -90), true)
	Mv.guardaRoupa(f, R(19.6, T1, 24, 90), 7)
	Mv.poltrona(f, R(6, T1, 26.5, 180), E.TecidoVerde)
	Mv.planta(f, Vector3.new(9, T1, 28.6), 5)
	Mv.quadro(f, R(-20.65, T1 + 6.5, 24, -90), 6, 3)
	Mv.tapete(f, R(-10, T1, 24), 8, 7, E.TecidoCinza)
	-- Escritório (lugar de maleta)
	Mv.mesaTrabalho(f, R(33, T1, -12), 6, true)
	Mv.cadeiraEscritorio(f, R(33, T1, -14, 180))
	Mv.estante(f, R(21.85, T1, -25, -90), 8, 8.5, 5)
	Mv.estante(f, R(21.85, T1, -10, -90), 6, 8.5, 5)
	Mv.mesaTrabalho(f, R(36, T1, -27.8, 180), 6)
	Mv.planta(f, Vector3.new(43.5, T1, -28.5), 5)
	Mv.quadro(f, R(33, T1 + 6, -6.65), 7, 4)
	Mv.tapete(f, R(33, T1, -15), 8, 6, E.TecidoAzul)
	-- Banheiro 2
	Mv.box(f, R(42.25, T1, -3.6, 90), 4.2, 4.5)
	Mv.vaso(f, R(43.7, T1, 3.6, 90))
	Mv.pia(f, R(31, T1, 4.8), 4)
	-- Quarto 4
	Mv.cama(f, R(40.6, T1, 24, 90), 5, E.TecidoVerde)
	Mv.criadoMudo(f, R(43.6, T1, 27.8, 90), true)
	Mv.guardaRoupa(f, R(31, T1, 7.4, 180), 6)
	Mv.mesaTrabalho(f, R(33, T1, 28.4), 5, true)
	Mv.cadeiraEscritorio(f, R(33, T1, 26.4, 180))
	-- Adega dos servidores (lugar de maleta)
	for _, z in { -26, -22, -18, -9, -5 } do
		Mv.rackServidor(f, R(-10, -11, z, -90))
		Mv.rackServidor(f, R(4, -11, z, 90))
	end
	Mv.adega(f, R(-13.1, -11, -24, -90), 8)
	Mv.adega(f, R(-13.1, -11, -12, -90), 8)
	Mv.caixas(f, R(11, -11, -27), 3)
	Kit.caixa(f, "Calha", -11, -2.2, -28, 5, -1.8, -3, E.Metal) -- calha de cabos no teto
	-- Lavanderia
	for i, x in { 17.5, 20.2, 22.9 } do
		Mv.maquinaLavar(f, R(x, -11, -1.7))
		local _ = i
	end
	Mv.estante(f, R(21, -11, -28.9, 180), 8, 8, 4)
	Mv.caixas(f, R(40, -11, -27), 3)
	Mv.caixas(f, R(42, -11, -3), 2)
end


----------------------------------------------------------------------------------------------------
-- Detalhes de fachada: lareira de pedra, concreto aparente na garagem, floreira na frente
----------------------------------------------------------------------------------------------------
local function detalhes(casa: Instance)
	local f = pasta(casa, "Detalhes")
	-- chaminé de pedra na fachada oeste, passando do telhado
	Kit.caixa(f, "Chamine", -49.5, 0, 22, -45.5, 26, 29, E.Pedra)
	Kit.caixa(f, "ChamineTopo", -49.8, 26, 21.7, -45.2, 26.6, 29.3, E.ConcretoEscuro)
	-- lareira por dentro (jantar), no lugar do aparador
	Kit.caixa(f, "Lareira", -44.5, 0, 22.5, -42.6, 9.2, 28.5, E.Pedra)
	Kit.caixa(f, "Fornalha", -42.7, 0.8, 24, -42.5, 3.4, 27, E.Preto, { Sombra = false })
	local fogo = Kit.caixa(f, "Brasa", -43.4, 0.85, 24.4, -42.8, 1.4, 26.6, { Cor = Color3.fromRGB(255, 120, 40), Mat = Enum.Material.Neon }, { Sombra = false, Colide = false }) :: Part
	Kit.luz(fogo, 1.4, 14, Color3.fromRGB(255, 140, 70), true)
	Kit.caixa(f, "Prateleira", -43, 4.6, 22.3, -42.3, 4.85, 28.7, E.MadeiraEscura)
	-- concreto aparente na garagem (por fora), com juntas
	local conc: Kit.Estilo = { Cor = Color3.fromRGB(170, 168, 162), Mat = Enum.Material.Concrete, Bal = "Concreto" }
	Kit.caixa(f, "ConcretoSul", 15, 0, 30.5, 23, 10.5, 30.58, conc, { Sombra = false })
	Kit.caixa(f, "ConcretoSul", 37, 0, 30.5, 45.5, 10.5, 30.58, conc, { Sombra = false })
	Kit.caixa(f, "ConcretoSul", 23, 8.5, 30.5, 37, 10.5, 30.58, conc, { Sombra = false })
	Kit.caixa(f, "ConcretoLeste", 45.5, 0, -0.5, 45.58, 10.5, 18.4, conc, { Sombra = false })
	Kit.caixa(f, "ConcretoLeste", 45.5, 0, 21.6, 45.58, 10.5, 30.5, conc, { Sombra = false })
	Kit.caixa(f, "ConcretoLeste", 45.5, 7.5, 18.4, 45.58, 10.5, 21.6, conc, { Sombra = false })
	for _, y in { 2.6, 5.2, 7.8 } do
		Kit.caixa(f, "Junta", 15, y - 0.04, 30.58, 23, y + 0.04, 30.62, E.Cinza, { Sombra = false })
		Kit.caixa(f, "Junta", 37, y - 0.04, 30.58, 45.5, y + 0.04, 30.62, E.Cinza, { Sombra = false })
		Kit.caixa(f, "Junta", 45.58, y - 0.04, -0.5, 45.62, y + 0.04, 18.4, E.Cinza, { Sombra = false })
	end
	-- floreira ao longo da frente (oeste da porta)
	Kit.caixa(f, "Floreira", -44, 0, 31, -11, 1.3, 33.2, E.ConcretoEscuro)
	Kit.caixa(f, "TerraFloreira", -43.6, 1.3, 31.3, -11.4, 1.4, 32.9, E.Terra, { Sombra = false })
	local rng = Random.new(9)
	local cores = { Color3.fromRGB(236, 232, 220), Color3.fromRGB(220, 190, 70), Color3.fromRGB(150, 110, 170), Color3.fromRGB(200, 90, 70) }
	for x = -43, -12, 1.1 do
		local s = rng:NextNumber(0.9, 1.6)
		Kit.peca(f, "Moita", CFrame.new(x, 1.4 + s * 0.3, 32.1 + rng:NextNumber(-0.4, 0.4)), Vector3.new(s, s * 0.8, s), E.Folha, { Forma = Enum.PartType.Ball, Colide = false, Sombra = false })
		if rng:NextNumber() < 0.6 then
			Kit.peca(f, "Flor", CFrame.new(x + rng:NextNumber(-0.3, 0.3), 1.6 + s * 0.6, 32.1 + rng:NextNumber(-0.5, 0.5)), Vector3.new(0.35, 0.35, 0.35), { Cor = cores[rng:NextInteger(1, #cores)], Mat = Enum.Material.SmoothPlastic }, { Forma = Enum.PartType.Ball, Colide = false, Sombra = false })
		end
	end
end

function Casa.construir(pai: Instance): Model
	local casa = Instance.new("Model")
	casa.Name = "Casa"
	fachadas(casa)
	task.wait()
	pisos(casa)
	paredes(casa)
	task.wait()
	forros(casa)
	atrio(casa)
	task.wait()
	comodos(casa)
	detalhes(casa)
	casa.Parent = pai
	return casa
end

return Casa
