# BacenDRM.jl

[![License][license-img]](LICENSE)
[![travis][travis-img]][travis-url]
[![codecov][codecov-img]][codecov-url]

[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square
[travis-img]: https://img.shields.io/travis/lucasprocessi/BacenDRM.jl/master.svg?logo=travis&label=Linux&style=flat-square
[travis-url]: https://travis-ci.org/lucasprocessi/BacenDRM.jl
[codecov-img]: https://img.shields.io/codecov/c/github/lucasprocessi/BacenDRM.jl/master.svg?label=codecov&style=flat-square
[codecov-url]: http://codecov.io/github/lucasprocessi/BacenDRM.jl?branch=master

Writes DRM (monthly market risk report) XML file, as required by Brazilian Central Bank (BACEN)

### Example

```julia
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

# write a xml file ready to be sent to BACEN...
BacenDRM.write_xml("DRM.xml", doc)

# ... or a csv file to debug results
BacenDRM.write_csv("DRM.csv", doc)


```

#### Content of "DRM.xml"

Numbers are truncated to thousands when writing in xml.

```xml
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
```

#### Content of "DRM.csv"

secao                | item | id_posicao | fator_risco | local_registro       | carteira_negoc | v01      | v02 | v03      | v04 | v05 | v06 | v07 | v08 | v09 | v10 | v11 | v12      | v12_MaM |
---------------------|------|------------|-------------|----------------------|----------------|----------|-----|----------|-----|-----|-----|-----|-----|-----|-----|-----|----------|---------|
ativo                | A20  |            | JM1         | offshore             | banking        | 100000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
ativo                | A30  |            | ME1         | offshore             | banking        | 0.0      | 0.0 | 100000.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 200000.0 | 10000.0 |
passivo              | P30  |            | JM1         | onshore_sem_clearing | trading        | 300000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
derivativo           | D41  | C          | JM1         | onshore_clearing     | banking        | 400000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
ativo_fundo          | A90  |            | JM1         | offshore             | banking        | 500000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
atividade_financeira | AFC  | V          | JM1         |                      | banking        | 600000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
