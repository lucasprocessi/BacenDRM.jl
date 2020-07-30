using Test
using EzXML
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

    ativo = [
        BacenDRM.ItemCarteira(
            :A20, nothing, :JM1, :offshore, :banking,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
        BacenDRM.ItemCarteira(
            :A30, nothing, :ME1, :offshore, :banking,
            [
                BacenDRM.FluxoVertice(Symbol("3"), 100.0, 0.0)
                BacenDRM.FluxoVertice(Symbol("12"), 100.0, 10.0)
            ]
        )
    ]
    passivo = [
        BacenDRM.ItemCarteira(
            :P30, nothing, :JM1, :onshore_sem_clearing, :trading,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
    ]
    derivativo = [
        BacenDRM.ItemCarteira(
            :D41, :C, :JM1, :onshore_clearing, :banking,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
    ]
    ativo_fundo = [
        BacenDRM.ItemCarteira(
            :A90, nothing, :JM1, :offshore, :banking,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
    ]
    atividade_financeira = [
        BacenDRM.ItemCarteira(
            :AFC, :V, :JM1, nothing, :banking,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
    ]

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
    @test length(doc.ativo) == 2

end

@testset "Write XML" begin
    ativo = [
        BacenDRM.ItemCarteira(
            :A20, nothing, :JM1, :offshore, :banking,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
        BacenDRM.ItemCarteira(
            :A30, nothing, :ME1, :offshore, :banking,
            [
                BacenDRM.FluxoVertice(Symbol("3"), 100.0, 0.0)
                BacenDRM.FluxoVertice(Symbol("12"), 100.0, 10.0)
            ]
        )
    ]
    passivo = [
        BacenDRM.ItemCarteira(
            :P30, nothing, :JM1, :onshore_sem_clearing, :trading,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
    ]
    derivativo = [
        BacenDRM.ItemCarteira(
            :D41, :C, :JM1, :onshore_clearing, :banking,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
    ]
    ativo_fundo = [
        BacenDRM.ItemCarteira(
            :A90, nothing, :JM1, :offshore, :banking,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
    ]
    atividade_financeira = [
        BacenDRM.ItemCarteira(
            :AFC, :V, :JM1, nothing, :banking,
            [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
        )
    ]

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

    function _is_equal(doc::BacenDRM.Documento, str_xml::String)
        b = IOBuffer()
        BacenDRM.write_xml(b, doc)
        xml1 = String(take!(b))

        b2 = IOBuffer()
        parsed = parsexml(str_xml)
        prettyprint(b2, parsed)
        xml2 = String(take!(b2))

        return xml1 == xml2

    end

    str_xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <DocDRM>
      <IdDocto>2060</IdDocto>
      <IdDoctoVersao>v1</IdDoctoVersao>
      <DataBase>2020-06</DataBase>
      <IdInstFinanc>123456</IdInstFinanc>
      <TipoArq>I</TipoArq>
      <NomeContato>Fulano</NomeContato>
      <FoneContato>555-1234</FoneContato>
      <Ativo>
        <ItemCarteira Item="A20" FatorRisco="JM1" LocalRegistro="03" CarteiraNegoc="02">
          <FluxoVertice CodVertice="1" ValorAlocado="100.0"/>
        </ItemCarteira>
        <ItemCarteira Item="A30" FatorRisco="ME1" LocalRegistro="03" CarteiraNegoc="02">
          <FluxoVertice CodVertice="3" ValorAlocado="100.0"/>
          <FluxoVertice CodVertice="12" ValorAlocado="100.0" ValorMaM="10.0"/>
        </ItemCarteira>
      </Ativo>
      <Passivo>
        <ItemCarteira Item="P30" FatorRisco="JM1" LocalRegistro="02" CarteiraNegoc="01">
          <FluxoVertice CodVertice="1" ValorAlocado="100.0"/>
        </ItemCarteira>
      </Passivo>
      <Derivativo>
        <ItemCarteira Item="D41" IdPosicao="C" FatorRisco="JM1" LocalRegistro="01" CarteiraNegoc="02">
          <FluxoVertice CodVertice="1" ValorAlocado="100.0"/>
        </ItemCarteira>
      </Derivativo>
      <AtivoFundo>
        <ItemCarteira Item="A90" FatorRisco="JM1" LocalRegistro="03" CarteiraNegoc="02">
          <FluxoVertice CodVertice="1" ValorAlocado="100.0"/>
        </ItemCarteira>
      </AtivoFundo>
      <AtividadeFinanceira>
        <ItemCarteira Item="AFC" IdPosicao="V" FatorRisco="JM1" CarteiraNegoc="02">
          <FluxoVertice CodVertice="1" ValorAlocado="100.0"/>
        </ItemCarteira>
      </AtividadeFinanceira>
    </DocDRM>
    """

    @test _is_equal(doc, str_xml)

    #BacenDRM.write_xml(Base.stdout, doc) # debug

    file = tempname()
    BacenDRM.write_xml(file, doc)
    rm(file)

end
