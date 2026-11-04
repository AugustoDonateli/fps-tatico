--!strict
-- Movimento do jogador local: andar, correr, devagar, agachar, deitar, inclinar, pular e energia.
-- Versão jogável: modelo clássico do Roblox (o cliente move o boneco). A prova P1 decide depois
-- se o movimento passa pro Server Authority. Os números vêm do Config; as contas, de Sim.Movimento.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Mov = require(Shared.Sim.Movimento)

local jogador = Players.LocalPlayer
local Teclas = Config.Teclas
local Vitais = Config.Vitais

export type Postura = "EmPe" | "Agachado" | "Deitado"

local Movimento = {}

-- Estado lido por outros sistemas (arma, HUD, som de passos).
Movimento.Estado = {
	Postura = "EmPe" :: Postura,
	Correndo = false, -- segurando a tecla de correr
	Devagar = false,
	Inclinar = 0, -- -1 esquerda, 0, 1 direita
	Mirando = false,
	Energia = Vitais.Energia.Max,
	Cansado = false,
	Movendo = false,
	CorrendoDeVerdade = false, -- correndo e podendo correr
}

-- Altura da câmera em cada postura, relativa à de pé (studs).
local ALTURA_CAMERA: { [Postura]: number } = {
	EmPe = 0,
	Agachado = -1.8,
	Deitado = -3.6,
}
local ALTURA_PULO = 2.5 -- studs
local SUAVIZAR = 12 -- quanto maior, mais rápido a câmera chega no alvo

local estado = Movimento.Estado
local deslocamentoAtual = Vector3.zero
local rolagemAtual = 0

local function humanoide(): Humanoid?
	local personagem = jogador.Character
	if not personagem then
		return nil
	end
	return personagem:FindFirstChildOfClass("Humanoid")
end

local function modoAtual(): Mov.Modo
	if estado.Postura == "Deitado" then
		return "Deitado"
	elseif estado.Postura == "Agachado" then
		return if estado.Devagar then "AgachadoDevagar" else "Agachado"
	elseif estado.Correndo then
		return "Correr"
	elseif estado.Devagar then
		return "AndarDevagar"
	end
	return "Andar"
end

local function mudarPostura(nova: Postura)
	if nova == estado.Postura then
		return
	end
	-- Levantar do chão custa energia e precisa de um mínimo.
	if estado.Postura == "Deitado" and nova ~= "Deitado" then
		local en = Vitais.Energia
		if estado.Energia < en.LevantarMinimo then
			return
		end
		estado.Energia -= en.LevantarCusto
	end
	estado.Postura = nova
end

local function pular()
	local hum = humanoide()
	if not hum then
		return
	end
	if estado.Postura ~= "EmPe" then
		mudarPostura("EmPe")
		return
	end
	local custo = Vitais.Energia.Pulo
	if estado.Energia < custo or hum.FloorMaterial == Enum.Material.Air then
		return
	end
	estado.Energia -= custo
	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	hum:ChangeState(Enum.HumanoidStateType.Jumping)
	task.delay(0.2, function()
		if hum.Parent then
			hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end
	end)
end

local function prepararPersonagem(personagem: Model)
	local hum = personagem:WaitForChild("Humanoid") :: Humanoid
	hum.UseJumpPower = false
	hum.JumpHeight = ALTURA_PULO
	-- O pulo padrão (espaço do ControlModule) fica desligado; o nosso cobra energia.
	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	estado.Postura = "EmPe"
	estado.Energia = Vitais.Energia.Max
	estado.Cansado = false
	estado.Inclinar = 0
end

local function tecla(nome: string): Enum.KeyCode
	return (Enum.KeyCode :: any)[nome]
end

local function ligarTeclas()
	-- Segurar
	local function segurar(campo: string)
		return function(_: string, s: Enum.UserInputState)
			(estado :: any)[campo] = s == Enum.UserInputState.Begin
			return Enum.ContextActionResult.Pass
		end
	end
	ContextActionService:BindAction("Correr", segurar("Correndo"), false, tecla(Teclas.Correr))
	ContextActionService:BindAction("AndarDevagar", segurar("Devagar"), false, tecla(Teclas.AndarDevagar))
	ContextActionService:BindAction("Mirar", segurar("Mirando"), false, Enum.UserInputType.MouseButton2)

	-- Alternar
	ContextActionService:BindAction("Agachar", function(_, s)
		if s == Enum.UserInputState.Begin then
			mudarPostura(if estado.Postura == "Agachado" then "EmPe" else "Agachado")
		end
		return Enum.ContextActionResult.Sink
	end, false, tecla(Teclas.Agachar))
	ContextActionService:BindAction("Deitar", function(_, s)
		if s == Enum.UserInputState.Begin then
			mudarPostura(if estado.Postura == "Deitado" then "Agachado" else "Deitado")
		end
		return Enum.ContextActionResult.Sink
	end, false, tecla(Teclas.Deitar))

	-- Pular (também levanta)
	ContextActionService:BindAction("Pular", function(_, s)
		if s == Enum.UserInputState.Begin then
			pular()
		end
		return Enum.ContextActionResult.Pass
	end, false, tecla(Teclas.Pular))

	-- Inclinar (segurar)
	local esquerda, direita = false, false
	local function atualizarInclinar()
		estado.Inclinar = (if direita then 1 else 0) - (if esquerda then 1 else 0)
	end
	ContextActionService:BindAction("InclinarEsquerda", function(_, s)
		esquerda = s == Enum.UserInputState.Begin
		atualizarInclinar()
		return Enum.ContextActionResult.Sink
	end, false, tecla(Teclas.InclinarEsquerda))
	ContextActionService:BindAction("InclinarDireita", function(_, s)
		direita = s == Enum.UserInputState.Begin
		atualizarInclinar()
		return Enum.ContextActionResult.Sink
	end, false, tecla(Teclas.InclinarDireita))
end

local function passo(dt: number)
	local hum = humanoide()
	if not hum or hum.Health <= 0 then
		return
	end

	estado.Movendo = hum.MoveDirection.Magnitude > 0.1
	local e: Mov.Estado = {
		Modo = modoAtual(),
		Parado = not estado.Movendo,
		Mirando = estado.Mirando,
		Cansado = estado.Cansado,
	}
	estado.CorrendoDeVerdade = estado.Movendo and Mov.modoEfetivo(e) == "Correr"

	-- Velocidade de quando anda (o Humanoid cuida de parar).
	local andando = table.clone(e)
	andando.Parado = false
	hum.WalkSpeed = Mov.velocidade(andando)

	estado.Energia = Mov.passoEnergia(estado.Energia, e, dt)
	estado.Cansado = Mov.atualizarCansado(estado.Cansado, estado.Energia)

	-- Atributos pra depurar e pra testes lerem de fora.
	jogador:SetAttribute("Energia", math.floor(estado.Energia))
	jogador:SetAttribute("Postura", estado.Postura)
	jogador:SetAttribute("Cansado", estado.Cansado)

	-- Câmera: altura da postura + inclinar pro lado. Deitado não inclina.
	local inclinar = if estado.Postura == "Deitado" then 0 else estado.Inclinar
	local alvo = Vector3.new(inclinar * Config.Movimento.Inclinar.Deslocamento, ALTURA_CAMERA[estado.Postura], 0)
	local k = 1 - math.exp(-SUAVIZAR * dt)
	deslocamentoAtual = deslocamentoAtual:Lerp(alvo, k)
	hum.CameraOffset = deslocamentoAtual
	rolagemAtual += (-inclinar * Config.Movimento.Inclinar.Angulo - rolagemAtual) * k
end

function Movimento.iniciar()
	jogador.CameraMode = Enum.CameraMode.LockFirstPerson
	UserInputService.MouseIconEnabled = false

	if jogador.Character then
		task.spawn(prepararPersonagem, jogador.Character)
	end
	jogador.CharacterAdded:Connect(prepararPersonagem)

	ligarTeclas()
	RunService.Heartbeat:Connect(passo)

	-- A rolagem do inclinar vai depois da câmera do Roblox, todo quadro.
	RunService:BindToRenderStep("InclinarCamera", Enum.RenderPriority.Camera.Value + 1, function()
		if math.abs(rolagemAtual) > 0.01 then
			local camera = workspace.CurrentCamera
			camera.CFrame *= CFrame.Angles(0, 0, math.rad(rolagemAtual))
		end
	end)
end

return Movimento
