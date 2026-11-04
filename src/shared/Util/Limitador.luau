--!strict
-- Limite de chamadas por segundo, por chave (ex.: por jogador).
-- Balde de fichas: enche "porSegundo" fichas por segundo, guarda no máximo "rajada".
-- O relógio é injetado pra dar pra testar sem esperar.

export type Limitador = {
	permitir: (self: Limitador, chave: any) -> boolean,
	esquecer: (self: Limitador, chave: any) -> (),
}

type Balde = { Fichas: number, Ultima: number }

local Limitador = {}

function Limitador.novo(porSegundo: number, rajada: number?, relogio: (() -> number)?): Limitador
	assert(porSegundo > 0, "porSegundo precisa ser maior que 0")
	local capacidade = rajada or porSegundo
	local agora = relogio or os.clock
	local baldes: { [any]: Balde } = {}

	local self = {}

	function self.permitir(_: any, chave: any): boolean
		local t = agora()
		local b = baldes[chave]
		if b == nil then
			b = { Fichas = capacidade, Ultima = t }
			baldes[chave] = b
		end
		b.Fichas = math.min(capacidade, b.Fichas + (t - b.Ultima) * porSegundo)
		b.Ultima = t
		if b.Fichas >= 1 then
			b.Fichas -= 1
			return true
		end
		return false
	end

	function self.esquecer(_: any, chave: any)
		baldes[chave] = nil
	end

	return (self :: any) :: Limitador
end

return Limitador
