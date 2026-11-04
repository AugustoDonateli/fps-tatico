--!strict
-- HUD mínimo da versão jogável: só a barra de energia, que aparece quando não está cheia.
-- O Intruder quase não tem HUD; a ideia é manter assim.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Hud = {}

function Hud.iniciar(movimento: any)
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) -- sem TAB padrão
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)

	local tela = Instance.new("ScreenGui")
	tela.Name = "Hud"
	tela.ResetOnSpawn = false
	tela.IgnoreGuiInset = true

	local fundo = Instance.new("Frame")
	fundo.Name = "Energia"
	fundo.AnchorPoint = Vector2.new(0.5, 1)
	fundo.Position = UDim2.new(0.5, 0, 1, -24)
	fundo.Size = UDim2.new(0, 160, 0, 4)
	fundo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	fundo.BackgroundTransparency = 0.5
	fundo.BorderSizePixel = 0
	fundo.Parent = tela

	local barra = Instance.new("Frame")
	barra.Name = "Barra"
	barra.Size = UDim2.fromScale(1, 1)
	barra.BackgroundColor3 = Color3.fromRGB(235, 235, 225)
	barra.BorderSizePixel = 0
	barra.Parent = fundo

	tela.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	RunService.RenderStepped:Connect(function()
		local energia = movimento.Estado.Energia :: number
		barra.Size = UDim2.fromScale(energia / 100, 1)
		fundo.Visible = energia < 99.5
		barra.BackgroundColor3 = if energia < 25 then Color3.fromRGB(200, 80, 60) else Color3.fromRGB(235, 235, 225)
	end)
end

return Hud
