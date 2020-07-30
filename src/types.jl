struct FluxoVertice
	cod_vertice::Symbol
	valor_alocado::Float64
	valor_mam::Float64
	function FluxoVertice(cod_vertice::Symbol, valor_alocado::Float64, valor_mam::Float64)
		@assert cod_vertice in VERTICES "vertice invalido: $cod_vertice"
		@assert valor_alocado > eps() "valor alocado deve ser maior que zero"
		@assert valor_mam > -eps()  "valor mam deve ser maior ou igual a zero"
		valor_mam > eps() && @assert cod_vertice == Symbol("12") "apenas o vertice :12 pode ter valor MaM maior que zero"
		new(cod_vertice, valor_alocado, valor_mam)
	end
end

SymbolOrNothing = Union{Symbol, Nothing}

struct ItemCarteira
	item::Symbol
	id_posicao::SymbolOrNothing
	fator_risco::Symbol
	local_registro::SymbolOrNothing
	carteira_negoc::Symbol
	fluxos::Vector{FluxoVertice}
	function ItemCarteira(
		item::Symbol,
		id_posicao::SymbolOrNothing,
		fator_risco::Symbol,
		local_registro::SymbolOrNothing,
		carteira_negoc::Symbol,
		fluxos::Vector{FluxoVertice})

		@assert item in [CONTAS_ATIVO; CONTAS_PASSIVO; CONTAS_DERIVATIVOS] "item invalido: $item"
		id_posicao != nothing && @assert id_posicao in POSICOES "posicao invalida: $id_posicao"
		@assert fator_risco in FATORES_RISCO "fator de risco invalido: $fator_risco"
		local_registro != nothing && @assert local_registro in LOCAIS_REGISTRO "local_registro invalido: $local_registro"
		@assert carteira_negoc in CARTEIRAS "carteira invalida: $carteira_negoc"

		return new(item, id_posicao, fator_risco, local_registro, carteira_negoc, fluxos)
	end
end
