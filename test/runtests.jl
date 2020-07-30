using Test
using BacenDRM


@testset "Fluxo Vertice" begin

	v1 = BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)
	@test v1.cod_vertice == Symbol("1")
	@test v1.valor_alocado == 100.0
	@test v1.valor_mam == 0.0

	v12 = BacenDRM.FluxoVertice(Symbol("12"), 200.0, 20.0)
	@test v12.cod_vertice == Symbol("12")
	@test v12.valor_alocado == 200.0
	@test v12.valor_mam == 20.0

	invalid_code = Symbol("13")
	# codigo invalido
	@test_throws AssertionError BacenDRM.FluxoVertice(invalid_code, 200.0, 20.0)
	# valor mam invalido
	@test_throws AssertionError BacenDRM.FluxoVertice(Symbol("2"), 200.0, 20.0)

end

@testset "Item Carteira" begin

	v1 = BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)
	v12 = BacenDRM.FluxoVertice(Symbol("12"), 200.0, 20.0)

	ic = BacenDRM.ItemCarteira(
		:A20,              # item::Symbol
		nothing,           # id_posicao::SymbolOrNothing
		:JM1,              # fator_risco::Symbol
		:onshore_clearing, # local_registro::SymbolOrNothing
		:trading,          # carteira_negoc::Symbol
		[v1; v12]           # fluxos::Vector{FluxoVertice}
	)

	@test ic.item == :A20

	ic2 = BacenDRM.ItemCarteira(
		:D41,              # item::Symbol
		:C,                # id_posicao::SymbolOrNothing
		:JM1,              # fator_risco::Symbol
		:onshore_clearing, # local_registro::SymbolOrNothing
		:trading,          # carteira_negoc::Symbol
		[v1; v12]           # fluxos::Vector{FluxoVertice}
	)

	@test ic2.fluxos[1].valor_alocado == 100.0

end
