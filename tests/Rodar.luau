--!strict
-- Roda todos os testes (*.spec) no Studio.
-- Pelo MCP do Studio (execute_luau), sem dar Play:
--   return require(game.ServerStorage.Tests.Rodar:Clone())()
-- O :Clone() e a cópia do Shared evitam o cache do require: cada rodada usa o código atual.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

type T = {
	igual: (a: any, b: any, msg: string?) -> (),
	perto: (a: number, b: number, tolerancia: number?, msg: string?) -> (),
	verdade: (v: any, msg: string?) -> (),
	falso: (v: any, msg: string?) -> (),
}

local function criarT(falhas: { string }, nomeTeste: string): T
	local function falhar(msg: string)
		table.insert(falhas, nomeTeste .. ": " .. msg)
	end
	return {
		igual = function(a, b, msg)
			if a ~= b then
				falhar(("%s esperava %s, veio %s"):format(msg or "", tostring(b), tostring(a)))
			end
		end,
		perto = function(a, b, tolerancia, msg)
			local tol = tolerancia or 1e-6
			if typeof(a) ~= "number" or math.abs(a - b) > tol then
				falhar(("%s esperava ~%s, veio %s"):format(msg or "", tostring(b), tostring(a)))
			end
		end,
		verdade = function(v, msg)
			if not v then
				falhar((msg or "") .. " esperava verdadeiro")
			end
		end,
		falso = function(v, msg)
			if v then
				falhar((msg or "") .. " esperava falso")
			end
		end,
	}
end

return function(): string
	local pastaTestes = ServerStorage:FindFirstChild("Tests")
	assert(pastaTestes, "ServerStorage.Tests não existe (o Rojo está ligado?)")

	-- Cópia fresca do Shared, num lugar temporário.
	local temp = Instance.new("Folder")
	temp.Name = "_TesteTemp"
	local shared = ReplicatedStorage:WaitForChild("Shared"):Clone()
	shared.Parent = temp
	temp.Parent = ServerStorage

	local linhas = {}
	local totalTestes, totalFalhas = 0, 0

	local specs = {}
	for _, filho in pastaTestes:GetChildren() do
		if filho:IsA("ModuleScript") and filho.Name:match("%.spec$") then
			table.insert(specs, filho)
		end
	end
	table.sort(specs, function(a, b)
		return a.Name < b.Name
	end)

	for _, spec in specs do
		local ok, casos = pcall(require, spec:Clone())
		if not ok then
			totalFalhas += 1
			table.insert(linhas, ("ERRO ao carregar %s: %s"):format(spec.Name, tostring(casos)))
			continue
		end
		local nomes = {}
		for nome in casos :: any do
			table.insert(nomes, nome)
		end
		table.sort(nomes)
		for _, nome in nomes do
			totalTestes += 1
			local falhas: { string } = {}
			local t = criarT(falhas, spec.Name .. " > " .. nome)
			local okCaso, erro = pcall((casos :: any)[nome], t, shared)
			if not okCaso then
				table.insert(falhas, spec.Name .. " > " .. nome .. ": ERRO " .. tostring(erro))
			end
			if #falhas > 0 then
				totalFalhas += 1
				for _, f in falhas do
					table.insert(linhas, "FALHOU " .. f)
				end
			end
		end
	end

	temp:Destroy()

	table.insert(
		linhas,
		1,
		("%d testes, %d passaram, %d falharam"):format(totalTestes, totalTestes - totalFalhas, totalFalhas)
	)
	local texto = table.concat(linhas, "\n")
	print(texto)
	return texto
end
