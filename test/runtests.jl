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

@testset "Documento" begin

    ativo = Vector{BacenDRM.ItemCarteira}()
    passivo = Vector{BacenDRM.ItemCarteira}()
    derivativo = Vector{BacenDRM.ItemCarteira}()
    ativo_fundo = Vector{BacenDRM.ItemCarteira}()
    atividade_financeira = Vector{BacenDRM.ItemCarteira}()

    doc = BacenDRM.Documento(
        "2060",              # id_docto::String,
        "v1",                # id_docto_versao::String,
        "2020-06",           # data_base::String,
        123456,              # id_inst_financ::Int64,
        :I,                  # tipo_arq::Symbol,
        "Fulano",            # nome_contato::String,
        "555-1234",          # fone_contato::String,
        ativo,               # ativo::Vector{ItemCarteira},
        passivo,             # passivo::Vector{ItemCarteira},
        derivativo,          # derivativo::Vector{ItemCarteira},
        ativo_fundo,         # ativo_fundo::Vector{ItemCarteira},
        atividade_financeira # atividade_financeira::Vector{ItemCarteira}
    )

    @test doc.id_docto == "2060"
    @test length(doc.ativo) == 0
end
