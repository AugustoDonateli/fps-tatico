--!strict
-- Móveis e objetos retos por código (camadas 3 e 4 do plano de arte).
-- Cada função recebe a CFrame da base (no piso, centro do móvel). A frente do móvel olha pra -Z local.

local Kit = require(script.Parent.Kit)
local E = Kit.E

local M = {}

type Est = Kit.Estilo

-- Caixa em coordenadas locais do móvel (cantos x1..x2, y1..y2, z1..z2).
local function cx(m: Instance, nm: string, base: CFrame, x1: number, y1: number, z1: number, x2: number, y2: number, z2: number, e: Est, op: Kit.Opcoes?): Part
	local c = Vector3.new((x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2)
	local t = Vector3.new(math.abs(x2 - x1), math.abs(y2 - y1), math.abs(z2 - z1))
	return Kit.peca(m, nm, base * CFrame.new(c), t, e, op)
end
M.cx = cx

local function modelo(pai: Instance, nome: string): Model
	local m = Instance.new("Model")
	m.Name = nome
	m.Parent = pai
	return m
end

local rng = Random.new(42)

function M.sofa(pai: Instance, base: CFrame, larg: number, tecido: Est): Model
	local m = modelo(pai, "Sofa")
	local h = larg / 2
	cx(m, "Base", base, -h, 0.25, -1.3, h, 1.3, 1.3, tecido)
	cx(m, "Encosto", base, -h, 1.3, 0.75, h, 2.9, 1.3, tecido)
	cx(m, "Braco", base, -h, 1.3, -1.3, -h + 0.6, 2.2, 1.3, tecido)
	cx(m, "Braco", base, h - 0.6, 1.3, -1.3, h, 2.2, 1.3, tecido)
	local n = math.max(2, math.floor((larg - 1.2) / 2.4))
	local w = (larg - 1.2) / n
	for i = 0, n - 1 do
		local x = -h + 0.6 + w * i
		cx(m, "Almofada", base, x + 0.05, 1.3, -1.25, x + w - 0.05, 1.75, 0.75, tecido, { Sombra = false })
		cx(m, "AlmofadaEnc", base, x + 0.1, 1.75, 0.35, x + w - 0.1, 2.75, 0.75, tecido, { Sombra = false })
	end
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			cx(m, "Pe", base, sx * (h - 0.4) - 0.1, 0, sz * 1 - 0.1, sx * (h - 0.4) + 0.1, 0.25, sz * 1 + 0.1, E.MadeiraEscura)
		end
	end
	return m
end

function M.poltrona(pai: Instance, base: CFrame, tecido: Est): Model
	local m = modelo(pai, "Poltrona")
	cx(m, "Assento", base, -1.4, 0.6, -1.3, 1.4, 1.5, 1.2, tecido)
	cx(m, "Encosto", base, -1.4, 1.5, 0.6, 1.4, 3.2, 1.2, tecido)
	cx(m, "Braco", base, -1.4, 1.5, -1.3, -1.0, 2.3, 1.2, tecido)
	cx(m, "Braco", base, 1.0, 1.5, -1.3, 1.4, 2.3, 1.2, tecido)
	for _, sx in { -1.2, 1.2 } do
		for _, sz in { -1.1, 1.0 } do
			cx(m, "Pe", base, sx - 0.08, 0, sz - 0.08, sx + 0.08, 0.6, sz + 0.08, E.MadeiraEscura)
		end
	end
	return m
end

function M.mesaCentro(pai: Instance, base: CFrame, larg: number, prof: number): Model
	local m = modelo(pai, "MesaCentro")
	cx(m, "Tampo", base, -larg / 2, 1.1, -prof / 2, larg / 2, 1.35, prof / 2, E.MadeiraClara)
	cx(m, "Base", base, -larg / 2 + 0.3, 0, -prof / 2 + 0.3, larg / 2 - 0.3, 1.1, prof / 2 - 0.3, E.Metal)
	-- livros e uma caneca
	cx(m, "Livro", base, -0.6, 1.35, -0.3, 0.4, 1.5, 0.5, E.TecidoTerra, { Sombra = false })
	cx(m, "Livro", base, -0.5, 1.5, -0.2, 0.3, 1.62, 0.4, E.TecidoAzul, { Sombra = false })
	Kit.cilindro(m, "Caneca", (base * CFrame.new(0.9, 1.35, 0.2)).Position, 0.18, 0.35, E.Branco, { Sombra = false })
	return m
end

function M.tapete(pai: Instance, base: CFrame, larg: number, prof: number, e: Est): Model
	local m = modelo(pai, "Tapete")
	cx(m, "Tapete", base, -larg / 2, 0, -prof / 2, larg / 2, 0.06, prof / 2, e, { Sombra = false, Colide = false })
	cx(m, "Borda", base, -larg / 2 + 0.3, 0.06, -prof / 2 + 0.3, larg / 2 - 0.3, 0.07, -prof / 2 + 0.5, E.TecidoBege, { Sombra = false, Colide = false })
	cx(m, "Borda", base, -larg / 2 + 0.3, 0.06, prof / 2 - 0.5, larg / 2 - 0.3, 0.07, prof / 2 - 0.3, E.TecidoBege, { Sombra = false, Colide = false })
	return m
end

-- Estante com livros de cores e alturas variadas.
function M.estante(pai: Instance, base: CFrame, larg: number, alt: number, prateleiras: number): Model
	local m = modelo(pai, "Estante")
	local h = larg / 2
	cx(m, "Lado", base, -h, 0, -0.6, -h + 0.2, alt, 0.6, E.MadeiraEscura)
	cx(m, "Lado", base, h - 0.2, 0, -0.6, h, alt, 0.6, E.MadeiraEscura)
	cx(m, "Fundo", base, -h, 0, 0.5, h, alt, 0.6, E.MadeiraEscura)
	local cores = { E.TecidoTerra, E.TecidoAzul, E.TecidoVerde, E.TecidoBege, E.Couro, E.Branco, E.Preto, E.TecidoCinza }
	for i = 0, prateleiras do
		local y = i * (alt - 0.2) / prateleiras
		cx(m, "Prateleira", base, -h, y, -0.6, h, y + 0.2, 0.5, E.MadeiraEscura)
		if i < prateleiras then
			local x = -h + 0.3
			while x < h - 0.6 do
				if rng:NextNumber() < 0.2 then
					x += rng:NextNumber(0.4, 1.0) -- vão
				else
					local w = rng:NextNumber(0.15, 0.3)
					local ht = rng:NextNumber(0.9, 1.5)
					cx(m, "Livro", base, x, y + 0.2, -0.45, x + w, y + 0.2 + ht, 0.35, cores[rng:NextInteger(1, #cores)], { Sombra = false, Colide = false })
					x += w + 0.02
				end
			end
		end
	end
	return m
end

-- Planta em vaso: vaso cilíndrico e folhas em blocos girados.
function M.planta(pai: Instance, pos: Vector3, alt: number, vaso: Est?): Model
	local m = modelo(pai, "Planta")
	local r = math.max(0.5, alt * 0.16)
	Kit.cilindro(m, "Vaso", pos, r, alt * 0.28, vaso or E.ConcretoEscuro)
	Kit.cilindro(m, "Terra", pos + Vector3.new(0, alt * 0.28, 0), r * 0.9, 0.05, E.Terra, { Sombra = false })
	Kit.cilindro(m, "Caule", pos + Vector3.new(0, alt * 0.28, 0), 0.08, alt * 0.45, E.MadeiraEscura, { Sombra = false })
	for i = 1, 7 do
		local ang = i * 2.39
		local y = alt * (0.45 + 0.08 * (i % 4))
		local folha = if i % 2 == 0 then E.Folha else E.FolhaClara
		local cf = CFrame.new(pos + Vector3.new(math.cos(ang) * r * 0.9, y, math.sin(ang) * r * 0.9))
			* CFrame.Angles(0, -ang, 0)
			* CFrame.Angles(0, 0, math.rad(35 + 10 * (i % 3)))
		Kit.peca(m, "Folha", cf, Vector3.new(alt * 0.42, 0.12, alt * 0.16), folha, { Colide = false })
	end
	return m
end

function M.luminariaChao(pai: Instance, pos: Vector3): Model
	local m = modelo(pai, "Luminaria")
	Kit.cilindro(m, "Base", pos, 0.5, 0.1, E.Metal)
	Kit.cilindro(m, "Haste", pos, 0.06, 5.2, E.Metal, { Sombra = false })
	local cupula = Kit.cilindro(m, "Cupula", pos + Vector3.new(0, 4.6, 0), 0.7, 0.9, E.TecidoBege, { Sombra = false })
	cupula.Transparency = 0.15
	Kit.luz(cupula, 0.9, 12)
	return m
end

function M.mesaJantar(pai: Instance, base: CFrame, larg: number, prof: number, cadeirasPorLado: number): Model
	local m = modelo(pai, "MesaJantar")
	cx(m, "Tampo", base, -larg / 2, 2.4, -prof / 2, larg / 2, 2.6, prof / 2, E.MadeiraClara)
	for _, sx in { -1, 1 } do
		cx(m, "Cavalete", base, sx * (larg / 2 - 0.8) - 0.15, 0, -prof / 2 + 0.4, sx * (larg / 2 - 0.8) + 0.15, 2.4, prof / 2 - 0.4, E.Metal)
	end
	for i = 1, cadeirasPorLado do
		local x = -larg / 2 + larg * (i - 0.5) / cadeirasPorLado
		M.cadeira(m, base * CFrame.new(x, 0, -prof / 2 - 0.7))
		M.cadeira(m, base * CFrame.new(x, 0, prof / 2 + 0.7) * CFrame.Angles(0, math.pi, 0))
	end
	-- centro de mesa
	Kit.cilindro(m, "Fruteira", (base * CFrame.new(0, 2.6, 0)).Position, 0.6, 0.25, E.Branco, { Sombra = false })
	for i = 1, 4 do
		Kit.peca(m, "Fruta", base * CFrame.new(-0.25 + 0.17 * i, 2.95, 0.1 * (i % 2)), Vector3.new(0.3, 0.3, 0.3), E.TecidoTerra, { Forma = Enum.PartType.Ball, Sombra = false })
	end
	return m
end

-- Cadeira olhando pra +Z local (encosto em -Z), pra encostar na mesa.
function M.cadeira(pai: Instance, base: CFrame): Model
	local m = modelo(pai, "Cadeira")
	cx(m, "Assento", base, -0.8, 1.5, -0.8, 0.8, 1.7, 0.8, E.MadeiraEscura)
	cx(m, "Encosto", base, -0.8, 1.7, -0.8, 0.8, 3.4, -0.65, E.MadeiraEscura)
	for _, sx in { -0.7, 0.7 } do
		for _, sz in { -0.7, 0.7 } do
			cx(m, "Pe", base, sx - 0.06, 0, sz - 0.06, sx + 0.06, 1.5, sz + 0.06, E.Metal)
		end
	end
	return m
end

function M.banqueta(pai: Instance, pos: Vector3): Model
	local m = modelo(pai, "Banqueta")
	Kit.cilindro(m, "Assento", pos + Vector3.new(0, 2.5, 0), 0.55, 0.2, E.Couro)
	Kit.cilindro(m, "Haste", pos, 0.07, 2.5, E.Inox, { Sombra = false })
	Kit.cilindro(m, "Base", pos, 0.45, 0.06, E.Inox, { Sombra = false })
	return m
end

-- Bancada de cozinha com armários embaixo, tampo de pedra, puxadores; opcional pia e cooktop.
function M.bancada(pai: Instance, base: CFrame, larg: number, comPia: boolean?, comFogao: boolean?): Model
	local m = modelo(pai, "Bancada")
	local h = larg / 2
	cx(m, "Rodape", base, -h + 0.1, 0, -0.9, h - 0.1, 0.4, 1.1, E.Preto)
	cx(m, "Armario", base, -h, 0.4, -1.0, h, 2.9, 1.2, E.Branco)
	cx(m, "Tampo", base, -h - 0.05, 2.9, -1.15, h + 0.05, 3.1, 1.2, E.CeramicaEscura)
	local portas = math.max(1, math.floor(larg / 2))
	for i = 0, portas - 1 do
		local x = -h + larg * (i + 0.5) / portas
		cx(m, "Junta", base, x + larg / portas / 2 - 0.03, 0.45, -1.02, x + larg / portas / 2 + 0.03, 2.85, -1.0, E.Cinza, { Sombra = false })
		cx(m, "Puxador", base, x - 0.4, 2.55, -1.08, x + 0.4, 2.62, -1.0, E.Inox, { Sombra = false })
	end
	if comPia then
		cx(m, "Cuba", base, -1.0, 2.6, -0.8, 1.0, 3.11, 0.5, E.Inox, { Colide = false })
		cx(m, "Torneira", base, -0.06, 3.1, 0.55, 0.06, 4.0, 0.67, E.Inox, { Sombra = false })
		cx(m, "Bica", base, -0.06, 3.9, 0.1, 0.06, 4.0, 0.67, E.Inox, { Sombra = false })
	end
	if comFogao then
		local x0 = if comPia then h - 2.2 else 0
		cx(m, "Cooktop", base, x0 - 1.1, 3.1, -0.8, x0 + 1.1, 3.16, 0.6, E.Preto, { Sombra = false })
		for _, p in { { -0.5, -0.35 }, { 0.5, -0.35 }, { -0.5, 0.25 }, { 0.5, 0.25 } } do
			Kit.cilindro(m, "Boca", (base * CFrame.new(x0 + p[1], 3.16, p[2])).Position, 0.25, 0.02, E.Cinza, { Sombra = false })
		end
	end
	return m
end

-- Armário aéreo de cozinha.
function M.aereo(pai: Instance, base: CFrame, larg: number): Model
	local m = modelo(pai, "Aereo")
	local h = larg / 2
	cx(m, "Corpo", base, -h, 5.6, 0.0, h, 8.2, 1.2, E.Branco)
	local portas = math.max(1, math.floor(larg / 2))
	for i = 1, portas - 1 do
		local x = -h + larg * i / portas
		cx(m, "Junta", base, x - 0.03, 5.65, -0.02, x + 0.03, 8.15, 0.0, E.Cinza, { Sombra = false })
	end
	cx(m, "Puxadores", base, -h + 0.3, 5.65, -0.07, h - 0.3, 5.72, 0.0, E.Inox, { Sombra = false })
	local fita = cx(m, "LuzSob", base, -h + 0.2, 5.55, 0.2, h - 0.2, 5.6, 0.4, E.Luz, { Sombra = false, Colide = false })
	Kit.luz(fita, 0.5, 6)
	return m
end

function M.geladeira(pai: Instance, base: CFrame): Model
	local m = modelo(pai, "Geladeira")
	cx(m, "Corpo", base, -1.5, 0, -1.2, 1.5, 7, 1.3, E.Inox)
	cx(m, "Junta", base, -1.5, 4.6, -1.22, 1.5, 4.65, -1.2, E.Preto, { Sombra = false })
	cx(m, "Junta", base, -0.02, 0.1, -1.22, 0.02, 4.6, -1.2, E.Preto, { Sombra = false })
	cx(m, "Puxador", base, -0.25, 1.5, -1.35, -0.15, 4.2, -1.22, E.Preto, { Sombra = false })
	cx(m, "Puxador", base, 0.15, 1.5, -1.35, 0.25, 4.2, -1.22, E.Preto, { Sombra = false })
	cx(m, "Puxador", base, -1.2, 4.8, -1.35, 1.2, 4.9, -1.22, E.Preto, { Sombra = false })
	return m
end

function M.cama(pai: Instance, base: CFrame, larg: number, roupa: Est): Model
	local m = modelo(pai, "Cama")
	local h = larg / 2
	cx(m, "Estrado", base, -h, 0.3, -3.5, h, 1.1, 3.5, E.MadeiraEscura)
	cx(m, "Colchao", base, -h + 0.15, 1.1, -3.4, h - 0.15, 1.9, 3.35, E.Branco)
	cx(m, "Edredom", base, -h + 0.1, 1.9, -3.45, h - 0.1, 2.15, 1.6, roupa)
	cx(m, "Dobra", base, -h + 0.1, 1.9, 1.6, h - 0.1, 2.25, 2.1, E.Branco, { Sombra = false })
	local nTr = if larg > 4 then 2 else 1
	for i = 1, nTr do
		local x = -h + larg * (i - 0.5) / nTr
		cx(m, "Travesseiro", base, x - 0.9, 1.9, 2.35, x + 0.9, 2.45, 3.25, E.Branco, { Sombra = false })
	end
	cx(m, "Cabeceira", base, -h - 0.2, 0, 3.5, h + 0.2, 4.4, 3.85, roupa)
	return m
end

function M.criadoMudo(pai: Instance, base: CFrame, comAbajur: boolean?): Model
	local m = modelo(pai, "CriadoMudo")
	cx(m, "Corpo", base, -0.8, 0, -0.8, 0.8, 2.0, 0.8, E.MadeiraClara)
	cx(m, "Gaveta", base, -0.7, 1.1, -0.82, 0.7, 1.8, -0.8, E.MadeiraEscura, { Sombra = false })
	if comAbajur then
		local p = (base * CFrame.new(0, 2.0, 0.1)).Position
		Kit.cilindro(m, "Pe", p, 0.15, 0.9, E.Branco, { Sombra = false })
		local c = Kit.cilindro(m, "Cupula", p + Vector3.new(0, 0.9, 0), 0.4, 0.6, E.TecidoBege, { Sombra = false })
		c.Transparency = 0.2
		Kit.luz(c, 0.6, 8)
	end
	return m
end

function M.guardaRoupa(pai: Instance, base: CFrame, larg: number): Model
	local m = modelo(pai, "GuardaRoupa")
	local h = larg / 2
	cx(m, "Corpo", base, -h, 0, -1.1, h, 8.5, 1.1, E.MadeiraClara)
	local portas = math.max(2, math.floor(larg / 1.8))
	for i = 1, portas - 1 do
		local x = -h + larg * i / portas
		cx(m, "Junta", base, x - 0.03, 0.1, -1.12, x + 0.03, 8.4, -1.1, E.MadeiraEscura, { Sombra = false })
	end
	for i = 0, portas - 1 do
		local x = -h + larg * (i + 0.5) / portas + (if i % 2 == 0 then 0.5 else -0.5)
		cx(m, "Puxador", base, x - 0.04, 3.6, -1.2, x + 0.04, 4.8, -1.1, E.Metal, { Sombra = false })
	end
	return m
end

function M.mesaTrabalho(pai: Instance, base: CFrame, larg: number, comPC: boolean?): Model
	local m = modelo(pai, "Mesa")
	local h = larg / 2
	cx(m, "Tampo", base, -h, 2.5, -1.2, h, 2.7, 1.2, E.MadeiraClara)
	cx(m, "Gaveteiro", base, h - 1.6, 0, -1.0, h - 0.1, 2.5, 1.1, E.Branco)
	cx(m, "Pe", base, -h + 0.1, 0, -1.0, -h + 0.3, 2.5, 1.1, E.Metal)
	if comPC then
		cx(m, "Monitor", base, -1.4, 3.4, 0.55, 1.4, 5.0, 0.65, E.Preto)
		local tela = cx(m, "Tela", base, -1.3, 3.5, 0.53, 1.3, 4.9, 0.55, { Cor = Color3.fromRGB(90, 140, 170), Mat = Enum.Material.Neon }, { Sombra = false, Colide = false })
		tela.Transparency = 0.2
		cx(m, "Suporte", base, -0.1, 2.7, 0.6, 0.1, 3.4, 0.7, E.Preto, { Sombra = false })
		cx(m, "Teclado", base, -0.9, 2.7, -0.5, 0.9, 2.78, -0.05, E.Preto, { Sombra = false })
		cx(m, "Mouse", base, 1.2, 2.7, -0.4, 1.4, 2.78, -0.1, E.Preto, { Sombra = false })
		cx(m, "Papeis", base, -h + 0.4, 2.7, -0.9, -h + 1.4, 2.74, 0.4, E.Branco, { Sombra = false })
	end
	return m
end

function M.cadeiraEscritorio(pai: Instance, base: CFrame): Model
	local m = modelo(pai, "CadeiraEscritorio")
	cx(m, "Assento", base, -0.9, 1.6, -0.9, 0.9, 1.9, 0.9, E.Preto)
	cx(m, "Encosto", base, -0.85, 2.1, 0.75, 0.85, 4.1, 0.95, E.Preto)
	Kit.cilindro(m, "Coluna", (base * CFrame.new(0, 0.3, 0)).Position, 0.1, 1.3, E.Inox, { Sombra = false })
	for i = 0, 4 do
		local a = i * math.pi * 2 / 5
		Kit.peca(m, "Rodizio", base * CFrame.Angles(0, a, 0) * CFrame.new(0, 0.25, -0.55), Vector3.new(0.15, 0.12, 1.1), E.Preto, { Sombra = false })
	end
	return m
end

function M.rackTV(pai: Instance, base: CFrame, larg: number): Model
	local m = modelo(pai, "RackTV")
	local h = larg / 2
	cx(m, "Rack", base, -h, 0.3, -0.9, h, 1.7, 0.9, E.MadeiraEscura)
	cx(m, "TV", base, -2.6, 2.4, 0.5, 2.6, 5.4, 0.7, E.Preto)
	cx(m, "Pe", base, -0.4, 1.7, 0.3, 0.4, 2.4, 0.7, E.Preto, { Sombra = false })
	cx(m, "Console", base, h - 1.6, 1.7, -0.5, h - 0.4, 1.95, 0.5, E.Branco, { Sombra = false })
	return m
end

-- Rack de servidor com luzinhas (adega dos servidores).
function M.rackServidor(pai: Instance, base: CFrame): Model
	local m = modelo(pai, "RackServidor")
	cx(m, "Gabinete", base, -1.2, 0, -1.6, 1.2, 8, 1.6, { Cor = Color3.fromRGB(34, 36, 40), Mat = Enum.Material.Metal, Bal = "ChapaGrossa" })
	cx(m, "Porta", base, -1.1, 0.2, -1.65, 1.1, 7.8, -1.6, { Cor = Color3.fromRGB(20, 22, 24), Mat = Enum.Material.DiamondPlate, Bal = "MetalFino" }, { Sombra = false })
	local cores = { Color3.fromRGB(80, 220, 120), Color3.fromRGB(80, 160, 255), Color3.fromRGB(255, 170, 60) }
	for i = 0, 11 do
		local y = 0.6 + i * 0.6
		cx(m, "Gaveta", base, -1.0, y, -1.7, 1.0, y + 0.45, -1.65, { Cor = Color3.fromRGB(48, 50, 56), Mat = Enum.Material.Metal }, { Sombra = false })
		for k = 0, 2 do
			if rng:NextNumber() < 0.6 then
				cx(m, "Led", base, -0.8 + k * 0.18, y + 0.15, -1.72, -0.72 + k * 0.18, y + 0.23, -1.7, { Cor = cores[rng:NextInteger(1, 3)], Mat = Enum.Material.Neon }, { Sombra = false, Colide = false })
			end
		end
	end
	return m
end

-- Estante de vinho com garrafas deitadas.
function M.adega(pai: Instance, base: CFrame, larg: number): Model
	local m = modelo(pai, "Adega")
	local h = larg / 2
	cx(m, "Corpo", base, -h, 0, 0.0, h, 7.5, 1.4, E.MadeiraEscura)
	local vidros = { Color3.fromRGB(40, 70, 40), Color3.fromRGB(70, 30, 30), Color3.fromRGB(30, 50, 30) }
	for linha = 0, 9 do
		local y = 0.5 + linha * 0.7
		cx(m, "Prateleira", base, -h + 0.1, y - 0.08, -0.05, h - 0.1, y, 1.3, E.MadeiraClara, { Sombra = false })
		local x = -h + 0.45
		while x < h - 0.4 do
			if rng:NextNumber() < 0.85 then
				local cf = base * CFrame.new(x, y + 0.25, 0.6) * CFrame.Angles(0, math.rad(90), 0)
				Kit.peca(m, "Garrafa", cf, Vector3.new(1.2, 0.4, 0.4), { Cor = vidros[rng:NextInteger(1, 3)], Mat = Enum.Material.Glass }, { Forma = Enum.PartType.Cylinder, Sombra = false, Colide = false })
			end
			x += 0.5
		end
	end
	return m
end

function M.caixas(pai: Instance, base: CFrame, n: number): Model
	local m = modelo(pai, "Caixas")
	local y = 0
	for i = 1, n do
		local s = rng:NextNumber(1.2, 2)
		local off = CFrame.new(rng:NextNumber(-0.3, 0.3), y + s * 0.4, rng:NextNumber(-0.3, 0.3)) * CFrame.Angles(0, rng:NextNumber(-0.4, 0.4), 0)
		Kit.peca(m, "Caixa", base * off, Vector3.new(s * 1.3, s * 0.8, s), E.Papelao)
		Kit.peca(m, "Fita", base * off, Vector3.new(0.2, s * 0.8 + 0.02, s + 0.02), E.TecidoBege, { Sombra = false, Colide = false })
		y += s * 0.8
		if y > 4 then
			break
		end
	end
	return m
end

-- Quadro na parede: moldura e "tela" de 2 a 3 manchas de cor (abstrato), olhando pra -Z local.
function M.quadro(pai: Instance, base: CFrame, larg: number, alt: number): Model
	local m = modelo(pai, "Quadro")
	cx(m, "Moldura", base, -larg / 2, -alt / 2, 0, larg / 2, alt / 2, 0.12, E.Preto, { Sombra = false, Colide = false })
	cx(m, "Fundo", base, -larg / 2 + 0.15, -alt / 2 + 0.15, -0.02, larg / 2 - 0.15, alt / 2 - 0.15, 0, E.Branco, { Sombra = false, Colide = false })
	local cores = { E.TecidoTerra, E.TecidoAzul, E.TecidoVerde, E.RebocoQuente, E.Preto }
	for i = 1, 3 do
		local w = rng:NextNumber(0.25, 0.6) * larg
		local hh = rng:NextNumber(0.2, 0.5) * alt
		local x = rng:NextNumber(-larg / 2 + 0.3 + w / 2, larg / 2 - 0.3 - w / 2)
		local y = rng:NextNumber(-alt / 2 + 0.3 + hh / 2, alt / 2 - 0.3 - hh / 2)
		cx(m, "Mancha", base, x - w / 2, y - hh / 2, -0.03 - i * 0.005, x + w / 2, y + hh / 2, -0.02, cores[rng:NextInteger(1, #cores)], { Sombra = false, Colide = false })
	end
	return m
end

function M.vaso(pai: Instance, base: CFrame): Model
	local m = modelo(pai, "VasoSanitario")
	cx(m, "Base", base, -0.6, 0, -0.9, 0.6, 1.3, 0.6, E.Branco)
	cx(m, "Assento", base, -0.75, 1.3, -1.2, 0.75, 1.45, 0.6, E.Branco)
	cx(m, "Caixa", base, -0.85, 1.3, 0.6, 0.85, 2.9, 1.1, E.Branco)
	return m
end

function M.pia(pai: Instance, base: CFrame, larg: number): Model
	local m = modelo(pai, "Pia")
	cx(m, "Gabinete", base, -larg / 2, 1.0, -0.6, larg / 2, 2.8, 1.0, E.MadeiraClara)
	cx(m, "Tampo", base, -larg / 2, 2.8, -0.7, larg / 2, 3.0, 1.0, E.Porcelanato)
	cx(m, "Cuba", base, -0.8, 3.0, -0.5, 0.8, 3.3, 0.6, E.Branco)
	cx(m, "Torneira", base, -0.05, 3.0, 0.7, 0.05, 3.8, 0.8, E.Inox, { Sombra = false })
	cx(m, "Espelho", base, -larg / 2 + 0.2, 4.2, 0.95, larg / 2 - 0.2, 7.2, 1.0, { Cor = Color3.fromRGB(200, 210, 214), Mat = Enum.Material.Glass, Refl = 0.6 }, { Sombra = false })
	return m
end

function M.box(pai: Instance, base: CFrame, larg: number, prof: number): Model
	local m = modelo(pai, "Box")
	cx(m, "Piso", base, -larg / 2, 0, -prof / 2, larg / 2, 0.15, prof / 2, E.CeramicaEscura)
	cx(m, "Vidro", base, -larg / 2, 0.15, -prof / 2, larg / 2, 7.2, -prof / 2 + 0.08, E.Vidro, { Sombra = false })
	cx(m, "Perfil", base, -larg / 2, 7.2, -prof / 2, larg / 2, 7.3, -prof / 2 + 0.1, E.Inox, { Sombra = false })
	cx(m, "Chuveiro", base, -0.4, 7.5, prof / 2 - 1.2, 0.4, 7.6, prof / 2 - 0.4, E.Inox, { Sombra = false })
	return m
end

function M.maquinaLavar(pai: Instance, base: CFrame): Model
	local m = modelo(pai, "Maquina")
	cx(m, "Corpo", base, -1.2, 0, -1.2, 1.2, 3.2, 1.2, E.Branco)
	local porta = Kit.cilindro(m, "Porta", Vector3.zero, 0.8, 0.12, E.Cinza, { Sombra = false })
	porta.CFrame = base * CFrame.new(0, 1.5, -1.25) * CFrame.Angles(0, math.rad(90), 0)
	cx(m, "Painel", base, -1.1, 2.7, -1.22, 1.1, 3.1, -1.2, E.Cinza, { Sombra = false })
	return m
end

-- Carro em blocos low poly (frente pra -Z local).
function M.carro(pai: Instance, base: CFrame, cor: Color3): Model
	local m = modelo(pai, "Carro")
	local lat: Est = { Cor = cor, Mat = Enum.Material.SmoothPlastic, Bal = "MetalFino", Refl = 0.1 }
	cx(m, "Chassi", base, -2.6, 0.9, -6.2, 2.6, 2.8, 6.2, lat)
	cx(m, "Cabine", base, -2.3, 2.8, -2.4, 2.3, 4.6, 3.2, lat)
	cx(m, "ParaBrisa", base, -2.2, 2.85, -2.6, 2.2, 4.5, -2.35, E.Vidro, { Sombra = false })
	cx(m, "Vigia", base, -2.2, 2.85, 3.15, 2.2, 4.5, 3.4, E.Vidro, { Sombra = false })
	cx(m, "JanelaE", base, -2.35, 3.0, -2.2, -2.25, 4.45, 3.0, E.Vidro, { Sombra = false })
	cx(m, "JanelaD", base, 2.25, 3.0, -2.2, 2.35, 4.45, 3.0, E.Vidro, { Sombra = false })
	cx(m, "ParaChoque", base, -2.65, 0.8, -6.35, 2.65, 1.5, -6.1, E.Preto)
	cx(m, "ParaChoque", base, -2.65, 0.8, 6.1, 2.65, 1.5, 6.35, E.Preto)
	for _, sx in { -1, 1 } do
		cx(m, "Farol", base, sx * 1.9 - 0.5, 2.0, -6.25, sx * 1.9 + 0.5, 2.4, -6.18, { Cor = Color3.fromRGB(240, 240, 220), Mat = Enum.Material.Glass }, { Sombra = false })
		cx(m, "Lanterna", base, sx * 1.9 - 0.5, 2.0, 6.18, sx * 1.9 + 0.5, 2.4, 6.25, { Cor = Color3.fromRGB(170, 30, 30), Mat = Enum.Material.Glass }, { Sombra = false })
		for _, sz in { -4, 4 } do
			local roda = Kit.peca(m, "Roda", base * CFrame.new(sx * 2.4, 1.1, sz), Vector3.new(0.9, 2.2, 2.2), E.Preto, { Forma = Enum.PartType.Cylinder })
			roda.CFrame = base * CFrame.new(sx * 2.4, 1.1, sz)
			Kit.peca(m, "Calota", base * CFrame.new(sx * 2.88, 1.1, sz), Vector3.new(0.06, 1.2, 1.2), E.Inox, { Forma = Enum.PartType.Cylinder, Sombra = false, Colide = false })
		end
	end
	return m
end

function M.bancadaFerramentas(pai: Instance, base: CFrame, larg: number): Model
	local m = modelo(pai, "Ferramentas")
	local h = larg / 2
	cx(m, "Tampo", base, -h, 2.8, -1.2, h, 3.1, 1.2, E.MadeiraClara)
	cx(m, "Pe", base, -h, 0, -1.1, -h + 0.25, 2.8, 1.1, E.Metal)
	cx(m, "Pe", base, h - 0.25, 0, -1.1, h, 2.8, 1.1, E.Metal)
	cx(m, "Prateleira", base, -h, 0.6, -1.1, h, 0.8, 1.1, E.MadeiraClara)
	cx(m, "Painel", base, -h, 3.1, 1.0, h, 7.0, 1.2, { Cor = Color3.fromRGB(150, 120, 80), Mat = Enum.Material.Wood, Bal = "Madeira" })
	for i = 1, 8 do
		local x = -h + 0.6 + (larg - 1.2) * (i - 1) / 7
		cx(m, "Ferramenta", base, x - 0.08, 4.0 + (i % 3) * 0.7, 0.9, x + 0.08, 5.2 + (i % 3) * 0.7, 1.0, if i % 2 == 0 then E.Metal else E.TecidoTerra, { Sombra = false, Colide = false })
	end
	M.caixas(m, base * CFrame.new(-h + 1.2, 0.8, 0), 1)
	return m
end

-- Canteiro interno: mureta de concreto, terra, pedras e plantas.
function M.canteiro(pai: Instance, x1: number, z1: number, x2: number, z2: number, y: number, alt: number): Model
	local m = modelo(pai, "Canteiro")
	Kit.caixa(m, "Mureta", x1, y, z1, x2, y + alt, z1 + 0.4, E.ConcretoLiso)
	Kit.caixa(m, "Mureta", x1, y, z2 - 0.4, x2, y + alt, z2, E.ConcretoLiso)
	Kit.caixa(m, "Mureta", x1, y, z1 + 0.4, x1 + 0.4, y + alt, z2 - 0.4, E.ConcretoLiso)
	Kit.caixa(m, "Mureta", x2 - 0.4, y, z1 + 0.4, x2, y + alt, z2 - 0.4, E.ConcretoLiso)
	Kit.caixa(m, "Terra", x1 + 0.4, y, z1 + 0.4, x2 - 0.4, y + alt - 0.2, z2 - 0.4, E.Terra)
	for i = 1, 5 do
		local px = rng:NextNumber(x1 + 0.9, x2 - 0.9)
		local pz = rng:NextNumber(z1 + 0.9, z2 - 0.9)
		local s = rng:NextNumber(0.6, 1.3)
		Kit.peca(m, "Pedra", CFrame.new(px, y + alt - 0.1, pz) * CFrame.Angles(rng:NextNumber(0, 1), rng:NextNumber(0, 3), rng:NextNumber(0, 1)), Vector3.new(s * 1.3, s * 0.7, s), E.PedraClara, { Sombra = false })
	end
	local n = math.max(2, math.floor((x2 - x1) * (z2 - z1) / 10))
	for i = 1, n do
		local px = x1 + 1 + (x2 - x1 - 2) * ((i - 0.5) / n)
		local pz = (z1 + z2) / 2 + rng:NextNumber(-1, 1) * ((z2 - z1) / 2 - 1.2)
		M.planta(m, Vector3.new(px, y + alt - 0.25 - 0.9, pz), rng:NextNumber(4, 7), E.Terra)
	end
	return m
end

return M
