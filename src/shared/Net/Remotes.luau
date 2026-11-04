--!strict
-- Lista de todos os remotes (plano, seção 1.4) e o validador de formato.
-- O validador só confere tipo e limites dos argumentos (NaN, infinito, faixa, enum).
-- As regras de jogo (está vivo, tem bala, cadência, volta no tempo) ficam nos serviços do servidor.

local Config = script.Parent.Parent.Config
local ArmasCfg = require(Config.Armas)

export type Arg = {
	Nome: string,
	Tipo: "number" | "boolean" | "string" | "Vector3" | "Instance",
	Min: number?,
	Max: number?,
	Inteiro: boolean?,
	Unitario: boolean?, -- Vector3 com tamanho 1
	MaxTamanho: number?, -- Vector3: tamanho máximo; string: comprimento máximo
	Opcoes: { string }?, -- string: só esses valores
	Opcional: boolean?,
}

export type Remote = {
	Tipo: "RemoteEvent" | "UnreliableRemoteEvent",
	Direcao: "ClienteServidor" | "ServidorCliente",
	PorSegundo: number?, -- limite por jogador (só ClienteServidor)
	Args: { Arg },
}

local nomesArmas: { string } = {}
for nome in ArmasCfg.Lista do
	table.insert(nomesArmas, nome)
end
table.sort(nomesArmas)

local POSICAO_MAX = 100000 -- nenhuma posição válida fica longe disso

local Lista: { [string]: Remote } = {
	-- Cliente → servidor
	Atirar = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 20,
		Args = {
			{ Nome = "NumeroTiro", Tipo = "number", Inteiro = true, Min = 1, Max = 1e9 },
			{ Nome = "Arma", Tipo = "string", Opcoes = nomesArmas },
			{ Nome = "Origem", Tipo = "Vector3", MaxTamanho = POSICAO_MAX },
			{ Nome = "Direcao", Tipo = "Vector3", Unitario = true },
			{ Nome = "Instante", Tipo = "number", Min = 0, Max = 1e10 }, -- hora do clique (workspace:GetServerTimeNow)
		},
	},
	Recarregar = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 2,
		Args = { { Nome = "Arma", Tipo = "string", Opcoes = nomesArmas } },
	},
	ChecarPente = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 2,
		Args = { { Nome = "Arma", Tipo = "string", Opcoes = nomesArmas } },
	},
	ModoTiro = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 4,
		Args = { { Nome = "Arma", Tipo = "string", Opcoes = nomesArmas } },
	},
	Equipar = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 5,
		Args = { { Nome = "Espaco", Tipo = "number", Inteiro = true, Min = 1, Max = 7 } },
	},
	-- Só existe se a prova P1 escolher o modelo clássico. Com Server Authority, a postura vem do controle.
	Postura = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 10,
		Args = {
			{ Nome = "Postura", Tipo = "string", Opcoes = { "EmPe", "Agachado", "Deitado" } },
			{ Nome = "Inclinar", Tipo = "number", Inteiro = true, Min = -1, Max = 1 },
		},
	},
	Interagir = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 10,
		Args = {
			{ Nome = "Alvo", Tipo = "Instance" },
			{
				Nome = "Acao",
				Tipo = "string",
				Opcoes = { "Porta", "Maleta", "Chave", "Checar", "Prender", "Devolver", "Pegar", "Lockpick" },
			},
			{ Nome = "Segurando", Tipo = "boolean" }, -- true = começou a segurar, false = soltou
		},
	},
	MoverPorta = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 15,
		Args = {
			{ Nome = "Porta", Tipo = "Instance" },
			{ Nome = "Angulo", Tipo = "number", Min = -110, Max = 110 },
		},
	},
	Empurrar = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 2,
		Args = { { Nome = "Alvo", Tipo = "Instance" } },
	},
	Largar = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 2,
		Args = {},
	},
	Sinal = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 2,
		Args = { { Nome = "Tipo", Tipo = "string", Opcoes = { "Apontar", "Parar", "Vem", "Estalar" } } },
	},
	FingirMorto = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 1,
		Args = { { Nome = "Ligar", Tipo = "boolean" } },
	},
	Desistir = { -- preso: apertar espaço
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 8,
		Args = {},
	},
	BipRadio = {
		Tipo = "RemoteEvent",
		Direcao = "ClienteServidor",
		PorSegundo = 4,
		Args = {},
	},

	-- Servidor → cliente
	EfeitoTiro = { Tipo = "UnreliableRemoteEvent", Direcao = "ServidorCliente", Args = {} }, -- só até 150 studs
	Passos = { Tipo = "UnreliableRemoteEvent", Direcao = "ServidorCliente", Args = {} },
	SomTatico = { Tipo = "RemoteEvent", Direcao = "ServidorCliente", Args = {} },
	Vitais = { Tipo = "RemoteEvent", Direcao = "ServidorCliente", Args = {} },
	Rodada = { Tipo = "RemoteEvent", Direcao = "ServidorCliente", Args = {} },
	Acerto = { Tipo = "RemoteEvent", Direcao = "ServidorCliente", Args = {} }, -- som de acerto pro atirador
	Recusa = { Tipo = "RemoteEvent", Direcao = "ServidorCliente", Args = {} }, -- tiro recusado: cliente desfaz
}

local Remotes = {}
Remotes.Lista = Lista
Remotes.NomePasta = "Remotes"

local function numeroValido(x: number): boolean
	return x == x and x ~= math.huge and x ~= -math.huge
end

local function validarArg(arg: Arg, valor: any): (boolean, string?)
	if valor == nil then
		if arg.Opcional then
			return true, nil
		end
		return false, arg.Nome .. ": faltando"
	end
	local tipo = typeof(valor)
	if tipo ~= arg.Tipo then
		return false, arg.Nome .. ": esperava " .. arg.Tipo .. ", veio " .. tipo
	end

	if arg.Tipo == "number" then
		if not numeroValido(valor) then
			return false, arg.Nome .. ": NaN ou infinito"
		end
		if arg.Inteiro and valor % 1 ~= 0 then
			return false, arg.Nome .. ": precisa ser inteiro"
		end
		if arg.Min and valor < arg.Min then
			return false, arg.Nome .. ": abaixo do mínimo"
		end
		if arg.Max and valor > arg.Max then
			return false, arg.Nome .. ": acima do máximo"
		end
	elseif arg.Tipo == "Vector3" then
		local v = valor :: Vector3
		if not (numeroValido(v.X) and numeroValido(v.Y) and numeroValido(v.Z)) then
			return false, arg.Nome .. ": NaN ou infinito"
		end
		local tamanho = v.Magnitude
		if arg.Unitario and math.abs(tamanho - 1) > 0.01 then
			return false, arg.Nome .. ": precisa ter tamanho 1"
		end
		if arg.MaxTamanho and tamanho > arg.MaxTamanho then
			return false, arg.Nome .. ": longe demais"
		end
	elseif arg.Tipo == "string" then
		if arg.MaxTamanho and #valor > arg.MaxTamanho then
			return false, arg.Nome .. ": texto longo demais"
		end
		if arg.Opcoes and not table.find(arg.Opcoes, valor) then
			return false, arg.Nome .. ": valor fora da lista"
		end
	end
	return true, nil
end

-- Confere os argumentos de um remote. Devolve ok e o motivo da recusa.
function Remotes.validar(nome: string, ...: any): (boolean, string?)
	local remote = Lista[nome]
	if remote == nil then
		return false, "remote desconhecido: " .. tostring(nome)
	end
	local n = select("#", ...)
	if n > #remote.Args then
		return false, "argumentos a mais"
	end
	local valores = { ... }
	for i, arg in remote.Args do
		local ok, motivo = validarArg(arg, valores[i])
		if not ok then
			return false, motivo
		end
	end
	return true, nil
end

-- Servidor: cria a pasta com todos os remotes. Chamar uma vez.
function Remotes.criar(pai: Instance): Folder
	local existente = pai:FindFirstChild(Remotes.NomePasta)
	if existente then
		existente:Destroy()
	end
	local pasta = Instance.new("Folder")
	pasta.Name = Remotes.NomePasta
	for nome, remote in Lista do
		local inst = Instance.new(remote.Tipo :: any)
		inst.Name = nome
		inst.Parent = pasta
	end
	pasta.Parent = pai
	return pasta
end

-- Cliente ou servidor: pega um remote pelo nome.
function Remotes.obter(pai: Instance, nome: string): Instance
	assert(Lista[nome] ~= nil, "remote desconhecido: " .. nome)
	local pasta = pai:WaitForChild(Remotes.NomePasta, 10)
	assert(pasta ~= nil, "pasta de remotes não apareceu")
	local inst = pasta:WaitForChild(nome, 10)
	assert(inst ~= nil, "remote não apareceu: " .. nome)
	return inst
end

return Remotes
