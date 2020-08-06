using Test
using EzXML
using BacenDRM


@testset "Vertice" begin

    v1 = BacenDRM.Vertice(100_000.0, 0_000.0)
    @test v1.valor_alocado == 100_000.0
    @test v1.valor_mam == 0_000.0

    v12 = BacenDRM.Vertice(200_000.0, 20_000.0)
    @test v12.valor_alocado == 200_000.0
    @test v12.valor_mam == 20_000.0

end

@testset "Item Carteira" begin

    ic = BacenDRM.ItemCarteira(
        :A20,              # item::Symbol
        nothing,           # id_posicao::SymbolOrNothing
        :JM1,              # fator_risco::Symbol
        :onshore_clearing, # local_registro::SymbolOrNothing
        :trading          # carteira_negoc::Symbol
    )

    @test ic.item == :A20

    ic2 = BacenDRM.ItemCarteira(
        :D41,              # item::Symbol
        :C,                # id_posicao::SymbolOrNothing
        :JM1,              # fator_risco::Symbol
        :onshore_clearing, # local_registro::SymbolOrNothing
        :trading          # carteira_negoc::Symbol
    )

    @test ic2.fator_risco == :JM1

end

@testset "Documento" begin

    ativo = Dict([
        BacenDRM.ItemCarteira(:A20, nothing, :JM1, :offshore, :banking) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
        BacenDRM.ItemCarteira(:A30, nothing, :ME1, :offshore, :banking) =>
        BacenDRM.Fluxos(Dict([
            3 => BacenDRM.Vertice(100_000.0, 0_000.0)
            12 => BacenDRM.Vertice(100_000.0, 10_000.0)
        ]))
    ])
    passivo = Dict([
        BacenDRM.ItemCarteira(:P30, nothing, :JM1, :onshore_sem_clearing, :trading) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    ])
    derivativo = Dict([
        BacenDRM.ItemCarteira(:D41, :C, :JM1, :onshore_clearing, :banking) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    ])
    ativo_fundo = Dict([
        BacenDRM.ItemCarteira(:A90, nothing, :JM1, :offshore, :banking) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    ])
    atividade_financeira = Dict([
        BacenDRM.ItemCarteira(:AFC, :V, :JM1, nothing, :banking) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    ])

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

    # create document with basic info
    doc = BacenDRM.Documento(
        "2060",              # id_docto::String,
        "v1",                # id_docto_versao::String,
        "2020-06",           # data_base::String,
        123456,              # id_inst_financ::Int64,
        :I,                  # tipo_arq::Symbol,
        "Fulano",            # nome_contato::String,
        "555-1234",          # fone_contato::String
    )

    # create ItemCarteira
    item_carteira = BacenDRM.ItemCarteira(
        :A20,
        nothing,
        :JM1,
        :offshore,
        :banking
    )
    # create Vertice
    codigo_vertice = 1
    vertice_1 = BacenDRM.Vertice(100_000.0, 0_000.0)
    # Add ItemCarteira to a section
    doc.ativo[item_carteira] = BacenDRM.Fluxos() # no vertices yet
    BacenDRM.add_vertice!(doc.ativo[item_carteira], codigo_vertice, vertice_1) # add Vertice

    # one-command form
    doc.ativo[BacenDRM.ItemCarteira(:A30, nothing, :ME1, :offshore, :banking)] = BacenDRM.Fluxos(Dict([3 => BacenDRM.Vertice(100_000.0, 0_000.0), 12 => BacenDRM.Vertice(100_000.0, 10_000.0)]))

    doc.passivo[BacenDRM.ItemCarteira(:P30, nothing, :JM1, :onshore_sem_clearing, :trading)] = BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    doc.derivativo[BacenDRM.ItemCarteira(:D41, :C, :JM1, :onshore_clearing, :banking)]       = BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    doc.ativo_fundo[BacenDRM.ItemCarteira(:A90, nothing, :JM1, :offshore, :banking)]         = BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    doc.atividade_financeira[BacenDRM.ItemCarteira(:AFC, :V, :JM1, nothing, :banking)]       = BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))

    function _is_equal(doc::BacenDRM.Documento, str_xml::String)
        b = IOBuffer()
        BacenDRM.write_xml(b, doc)
        xml1 = String(take!(b))

        b2 = IOBuffer()
        parsed = parsexml(str_xml)
        prettyprint(b2, parsed)
        xml2 = String(take!(b2))

        #println(xml1) # debug
        #println(xml2) # debug

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
          <FluxoVertice CodVertice="01" ValorAlocado="100"/>
        </ItemCarteira>
        <ItemCarteira Item="A30" FatorRisco="ME1" LocalRegistro="03" CarteiraNegoc="02">
          <FluxoVertice CodVertice="03" ValorAlocado="100"/>
          <FluxoVertice CodVertice="12" ValorAlocado="100" ValorMaM="10"/>
        </ItemCarteira>
      </Ativo>
      <Passivo>
        <ItemCarteira Item="P30" FatorRisco="JM1" LocalRegistro="02" CarteiraNegoc="01">
          <FluxoVertice CodVertice="01" ValorAlocado="100"/>
        </ItemCarteira>
      </Passivo>
      <Derivativo>
        <ItemCarteira Item="D41" IdPosicao="C" FatorRisco="JM1" LocalRegistro="01" CarteiraNegoc="02">
          <FluxoVertice CodVertice="01" ValorAlocado="100"/>
        </ItemCarteira>
      </Derivativo>
      <AtivoFundo>
        <ItemCarteira Item="A90" FatorRisco="JM1" LocalRegistro="03" CarteiraNegoc="02">
          <FluxoVertice CodVertice="01" ValorAlocado="100"/>
        </ItemCarteira>
      </AtivoFundo>
      <AtividadeFinanceira>
        <ItemCarteira Item="AFC" IdPosicao="V" FatorRisco="JM1" CarteiraNegoc="02">
          <FluxoVertice CodVertice="01" ValorAlocado="100"/>
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

@testset "Write CSV" begin
    ativo = Dict([
        BacenDRM.ItemCarteira(:A20, nothing, :JM1, :offshore, :banking) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
        BacenDRM.ItemCarteira(:A30, nothing, :ME1, :offshore, :banking) => BacenDRM.Fluxos(Dict([3 => BacenDRM.Vertice(100_000.0, 0_000.0), 12 => BacenDRM.Vertice(100_000.0, 10_000.0)]))
    ])
    passivo = Dict([
        BacenDRM.ItemCarteira(:P30, nothing, :JM1, :onshore_sem_clearing, :trading) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    ])
    derivativo = Dict([
        BacenDRM.ItemCarteira(:D41, :C, :JM1, :onshore_clearing, :banking) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    ])
    ativo_fundo = Dict([
        BacenDRM.ItemCarteira(:A90, nothing, :JM1, :offshore, :banking) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    ])
    atividade_financeira = Dict([
        BacenDRM.ItemCarteira(:AFC, :V, :JM1, nothing, :banking) => BacenDRM.Fluxos(Dict([1 => BacenDRM.Vertice(100_000.0, 0_000.0)]))
    ])

    doc = BacenDRM.Documento(
        "2060",              # id_docto::String,
        "v1",                # id_docto_versao::String,
        "2020-06",           # data_base::String,
        123456,              # id_inst_financ::Int64,
        :I,                  # tipo_arq::Symbol,
        "Fulano",            # nome_contato::String,
        "555-1234",          # fone_contato::String,
        ativo,               # ativo::Dict{ItemCarteira, Fluxos},
        passivo,             # passivo::Dict{ItemCarteira, Fluxos},
        derivativo,          # derivativo::Dict{ItemCarteira, Fluxos},
        ativo_fundo,         # ativo_fundo::Dict{ItemCarteira, Fluxos},
        atividade_financeira # atividade_financeira::Dict{ItemCarteira, Fluxos}
    )

    #BacenDRM.write_csv(Base.stdout, doc) # debug
    #BacenDRM.write_csv("drm.csv", doc)   # debug

    file = tempname()
    BacenDRM.write_csv(file, doc)
    @test isfile(file)
    rm(file)

end

@testset "ItemCarteira Helpers" begin

    # item::Symbol
    # id_posicao::SymbolOrNothing
    # fator_risco::Symbol
    # local_registro::SymbolOrNothing
    # carteira_negoc::Symbol
    # BacenDRM.Fluxos::Vector{FluxoVertice}

    # equal
    @test BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :trading) ==
          BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :trading)

    @test BacenDRM.ItemCarteira(:A10, nothing, :JJ1, nothing, :trading) ==
          BacenDRM.ItemCarteira(:A10, nothing, :JJ1, nothing, :trading)

    # different
    @test BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :trading) !=
          BacenDRM.ItemCarteira(:P10, nothing, :JJ1, :offshore, :trading)

    @test BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :trading) !=
          BacenDRM.ItemCarteira(:A10, :C, :JJ1, :offshore, :trading)

    @test BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :trading) !=
          BacenDRM.ItemCarteira(:A10, nothing, :JP1, :offshore, :trading)

    @test BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :trading) !=
          BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :onshore_clearing, :trading)

    @test BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :trading) !=
          BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :banking)

    @test BacenDRM.ItemCarteira(:A10, nothing, :JJ1, :offshore, :trading) !=
          BacenDRM.ItemCarteira(:A10, nothing, :JJ1, nothing, :trading)

    @test BacenDRM.ItemCarteira(:A10, :C, :JJ1, :offshore, :trading) !=
          BacenDRM.ItemCarteira(:A10, :V, :JJ1, :offshore, :trading)

end
