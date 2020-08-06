# BacenDRM.jl

Writes DRM (monthly market risk report) XML file, as required by Brazilian Central Bank (BACEN)

### Example

```julia
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
```

#### Content of "DRM.csv"

secao                | item | id_posicao | fator_risco | local_registro       | carteira_negoc | v01      | v02 | v03      | v04 | v05 | v06 | v07 | v08 | v09 | v10 | v11 | v12      | v12_MaM |
---------------------|------|------------|-------------|----------------------|----------------|----------|-----|----------|-----|-----|-----|-----|-----|-----|-----|-----|----------|---------|
ativo                | A20  |            | JM1         | offshore             | banking        | 100000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
ativo                | A30  |            | ME1         | offshore             | banking        | 0.0      | 0.0 | 100000.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 100000.0 | 10000.0 |
passivo              | P30  |            | JM1         | onshore_sem_clearing | trading        | 100000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
derivativo           | D41  | C          | JM1         | onshore_clearing     | banking        | 100000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
ativo_fundo          | A90  |            | JM1         | offshore             | banking        | 100000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
atividade_financeira | AFC  | V          | JM1         |                      | banking        | 100000.0 | 0.0 | 0.0      | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0      | 0.0     |
