using Test
using EzXML
using BacenDRM

function document_example()
    # create document with basic information
    doc = BacenDRM.Documento(
        "2060",              # id_docto::String,
        "v1",                # id_docto_versao::String,
        "2020-06",           # data_base::String,
        123456,              # id_inst_financ::Int64,
        :I,                  # tipo_arq::Symbol,
        "Fulano",            # nome_contato::String,
        "555-1234",          # fone_contato::String
    )

    # create ItemCarteira, which is an index to document data
    item_carteira = BacenDRM.ItemCarteira(
        :A20,
        nothing,
        :JM1,
        :offshore,
        :banking
    )

    # repeat for each vertice
    codigo_vertice = 1
    vertice_1 = BacenDRM.Vertice(
        100_000.0, # valor_alocado::Float64
          0.0      # valor_mam::Float64
    )
    push!(doc, item_carteira, codigo_vertice, vertice_1) # add Vertice
    # end repeat

    # two vertices
    ic = BacenDRM.ItemCarteira(:A30, nothing, :ME1, :offshore, :banking)
    push!(doc, ic,  3, BacenDRM.Vertice(100_000.0,  0.0))
    push!(doc, ic, 12, BacenDRM.Vertice(200_000.0, 10_000.0))

    # you can also build a vertice adding incrementally its values
    ic = BacenDRM.ItemCarteira(:P30, nothing, :JM1, :onshore_sem_clearing, :trading)
    push!(doc, ic, 1, BacenDRM.Vertice(70_000.0, 0.0))
    push!(doc, ic, 1, BacenDRM.Vertice(230_000.0, 0.0))
    # will result in: Vertice(300_000.0, 0.0)

    # one-liner
    push!(doc, BacenDRM.ItemCarteira(:D41, :C, :JM1, :onshore_clearing, :banking), 1, BacenDRM.Vertice(400_000.0, 0.0))

    # hedge fund assets: data goes into ativo_fundo section
    ic = BacenDRM.ItemCarteira(
        :A90,
        nothing,
        :JM1,
        :offshore,
        :banking,
        true      # is_ativo_fundo::Bool=false
    )
    push!(doc, ic, 1, BacenDRM.Vertice(500_000.0, 0.0))

    # atividade_financeira
    push!(doc, BacenDRM.ItemCarteira(:AFC, :V, :JM1, nothing, :banking), 1, BacenDRM.Vertice(600_000.0, 0.0))

    return doc
end

@testset "Vertice" begin

    v1 = BacenDRM.Vertice(100_000.0, 0.0)
    @test v1.valor_alocado == 100_000.0
    @test v1.valor_mam == 0.0

    v12 = BacenDRM.Vertice(200_000.0, 20_000.0)
    @test v12.valor_alocado == 200_000.0
    @test v12.valor_mam == 20_000.0

end

@testset "Fluxo" begin

    fluxo = BacenDRM.Fluxos()
    fluxo[1] = BacenDRM.Vertice(10_000.0, 0.0)

    @test fluxo[1].valor_alocado == 10_000.0
    @test fluxo[Symbol("01")].valor_mam == 0.0

    fluxo[Symbol("12")] = BacenDRM.Vertice(10.0, 20.0)


    @test_throws AssertionError fluxo[2]  = BacenDRM.Vertice(0.0, 1_000.0) # invalid valor_mam
    @test_throws AssertionError fluxo[Symbol("3")]  = BacenDRM.Vertice(0.0, 1_000.0) # invalid valor_mam
    @test_throws AssertionError fluxo[13] = BacenDRM.Vertice(0.0, 1_000.0) # invalid codigo_vertice
    @test_throws AssertionError fluxo[Symbol("14")] = BacenDRM.Vertice(0.0, 1_000.0) # invalid codigo_vertice

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
    @test BacenDRM.is_ativo(ic)
    @test !BacenDRM.is_passivo(ic)
    @test !BacenDRM.is_derivativo(ic)
    @test !BacenDRM.is_ativo_fundo(ic)
    @test !BacenDRM.is_atividade_financeira(ic)

    ic2 = BacenDRM.ItemCarteira(
        :D41,              # item::Symbol
        :C,                # id_posicao::SymbolOrNothing
        :JM1,              # fator_risco::Symbol
        :onshore_clearing, # local_registro::SymbolOrNothing
        :trading,          # carteira_negoc::Symbol
        true               # is_ativo_fundo::Bool=false
    )

    @test ic2.fator_risco == :JM1
    @test BacenDRM.is_ativo_fundo(ic2)
    @test !BacenDRM.is_ativo(ic2)
    @test !BacenDRM.is_passivo(ic2)
    @test !BacenDRM.is_derivativo(ic2)
    @test !BacenDRM.is_atividade_financeira(ic2)

end

@testset "Documento" begin

    doc = BacenDRM.Documento(
        "2060",              # id_docto::String,
        "v1",                # id_docto_versao::String,
        "2020-06",           # data_base::String,
        123456,              # id_inst_financ::Int64,
        :I,                  # tipo_arq::Symbol,
        "Fulano",            # nome_contato::String,
        "555-1234"           # fone_contato::String,
    )


    # ativo :A20
    ic = BacenDRM.ItemCarteira(:A20, nothing, :JM1, :offshore, :banking)
    push!(doc, ic, 1, BacenDRM.Vertice(100_000.0, 0.0))
    # ativo :A30
    ic = BacenDRM.ItemCarteira(:A30, nothing, :ME1, :offshore, :banking)
    push!(doc, ic,            3, BacenDRM.Vertice(100_000.0, 0.0))  # integer
    push!(doc, ic, Symbol("12"), BacenDRM.Vertice(100_000.0, 10_000.0)) # or symbol

    # passivo
    push!(doc, BacenDRM.ItemCarteira(:P30, nothing, :JM1, :onshore_sem_clearing, :trading), 1, BacenDRM.Vertice(100_000.0, 0.0))
    # derivativo
    push!(doc, BacenDRM.ItemCarteira(:D41, :C, :JM1, :onshore_clearing, :banking), 1, BacenDRM.Vertice(100_000.0, 0.0))
    # ativo_fundo
    ic = BacenDRM.ItemCarteira(:A90, nothing, :JM1, :offshore, :banking, true) # is_ativo_fundo=true
    push!(doc, ic, 1, BacenDRM.Vertice(100_000.0, 0.0))
    # atividade_financeira
    push!(doc, BacenDRM.ItemCarteira(:AFC, :V, :JM1, nothing, :banking), 1, BacenDRM.Vertice(100_000.0, 0.0))

    @test doc.id_docto == "2060"
    @test length(doc.ativo) == 2

end


@testset "Write XML" begin

    doc = document_example()

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
          <FluxoVertice CodVertice="12" ValorAlocado="200" ValorMaM="10"/>
        </ItemCarteira>
      </Ativo>
      <Passivo>
        <ItemCarteira Item="P30" FatorRisco="JM1" LocalRegistro="02" CarteiraNegoc="01">
          <FluxoVertice CodVertice="01" ValorAlocado="300"/>
        </ItemCarteira>
      </Passivo>
      <Derivativo>
        <ItemCarteira Item="D41" IdPosicao="C" FatorRisco="JM1" LocalRegistro="01" CarteiraNegoc="02">
          <FluxoVertice CodVertice="01" ValorAlocado="400"/>
        </ItemCarteira>
      </Derivativo>
      <AtivoFundo>
        <ItemCarteira Item="A90" FatorRisco="JM1" LocalRegistro="03" CarteiraNegoc="02">
          <FluxoVertice CodVertice="01" ValorAlocado="500"/>
        </ItemCarteira>
      </AtivoFundo>
      <AtividadeFinanceira>
        <ItemCarteira Item="AFC" IdPosicao="V" FatorRisco="JM1" CarteiraNegoc="02">
          <FluxoVertice CodVertice="01" ValorAlocado="600"/>
        </ItemCarteira>
      </AtividadeFinanceira>
    </DocDRM>
    """

    @test _is_equal(doc, str_xml)

    ic = BacenDRM.ItemCarteira(:P30, nothing, :JM1, :onshore_sem_clearing, :trading)
    @test doc.passivo[ic][Symbol("01")].valor_alocado == 300_000.0

    #BacenDRM.write_xml(Base.stdout, doc) # debug

    file = tempname()
    BacenDRM.write_xml(file, doc)
    rm(file)

end

@testset "Write CSV" begin

    doc = document_example()

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
