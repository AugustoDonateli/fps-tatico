--!strict
-- Dispersão do tiro (cone em graus) e desvio de cada tiro.
-- O desvio vem de uma semente que o servidor manda no começo da rodada + número do tiro,
-- então cliente e servidor chegam no mesmo desvio sem mandar nada a mais.

local Config = script.Parent.Parent.Config
local ArmasCfg = require(Config.Armas)
local Combate = require(Config.Combate)

export type Situacao = {
	Mirando: boolean?,
	Movendo: boolean?,
	Postura: ("EmPe" | "Agachado" | "Deitado")?,
	Cansado: boolean?,
	BracoFerido: boolean?,
	Correndo: boolean?,
}

local Dispersao = {}

-- Cone em graus. nil = não pode atirar (correndo, arma abaixada).
function Dispersao.cone(nomeArma: string, s: Situacao): number?
	if s.Correndo then
		return nil
	end
	local arma = ArmasCfg.Lista[nomeArma]
	assert(arma ~= nil, "arma desconhecida: " .. tostring(nomeArma))
	local p = ArmasCfg.Precisao

	local cone: number
	if s.Mirando then
		cone = if arma.Pistola then p.MirandoParadoPistola else p.MirandoParado
	else
		cone = p.SemMirarParado
	end
	if s.Movendo then
		cone += p.AndandoSoma
	end
	if s.Postura == "Agachado" then
		cone *= p.MultAgachado
	elseif s.Postura == "Deitado" then
		cone *= p.MultDeitado
	end
	if s.Cansado then
		cone *= p.MultCansado
	end
	if s.BracoFerido then
		cone *= Combate.EfeitosParte.Braco.DispersaoMult
	end
	return cone
end

-- Desvio do tiro número n, em graus (lado, cima). Uniforme dentro do disco do cone.
function Dispersao.desvio(semente: number, numeroTiro: number, cone: number): (number, number)
	local rng = Random.new(semente + numeroTiro)
	local raio = cone * math.sqrt(rng:NextNumber())
	local angulo = rng:NextNumber() * 2 * math.pi
	return raio * math.cos(angulo), raio * math.sin(angulo)
end

-- Aplica o desvio numa direção (unitária).
function Dispersao.aplicar(direcao: Vector3, lado: number, cima: number): Vector3
	local base = CFrame.lookAt(Vector3.zero, direcao)
	return (base * CFrame.Angles(math.rad(cima), math.rad(-lado), 0)).LookVector
end

return Dispersao
