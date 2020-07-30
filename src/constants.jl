
const CONTAS_ATIVO   = [:A10, :A20, :A30, :A40, :A50, :A90]
const CONTAS_PASSIVO = [:P10, :P20, :P30, :P40, :P50, :P90]
const FATORES_RISCO = [
	:JJ1
	:JM1
	:JM1
	:JM2
	:JM3
	:JM4
	:JM5
	:JM7
	:JM9
	:JT1
	:JT2
	:JT3
	:JT9
	:JI1
	:JI2
	:JI3
	:JI9
	:JP1
	:JP2
	:ME1
	:ME2
	:ME3
	:ME4
	:ME5
	:ME6
	:ME7
	:ME9
	:AA1
	:AA2
	:AA3
	:AA4
	:AA5
	:AA6
	:AA7
	:AA9
	:MC1
	:FF1
	Symbol("998")
	Symbol("999")
]

const LOCAIS_REGISTRO = [:onshore_clearing, :onshore_no_clearing, :offshore]
const DECODE_LOCAIS_REGISTRO = Dict{Symbol, String}([
	:onshore_clearing    => "01"
	:onshore_no_clearing => "02"
	:offshore            => "03"
])

const CARTEIRAS = [:trading, :banking]
const DECODE_CARTEIRAS = Dict{Symbol, String}([
	:trading => "01"
	:banking => "02"
])

const VERTICES = [Symbol(n) for n in 1:12]

const CONTAS_DERIVATIVOS = [
	:D10
	:D20
	:D30
	:D40
	:D41
	:D42
	:D43
	:D50
	:D51
	:D52
	:D53
	:D60
	:D90
]

const POSICOES = [:C, :V, :NA]
