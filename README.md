# BacenDRM.jl

Writes DRM (monthly market risk report) XML file, as required from Brazilian Central Bank (BACEN)

### Example

```julia
ativo = [
    BacenDRM.ItemCarteira(
        :A20,            # item::Symbol
        nothing,         # id_posicao::SymbolOrNothing
        :JM1,            # fator_risco::Symbol
        :offshore,       # local_registro::SymbolOrNothing
       	:banking,        # carteira_negoc::Symbol
        [BacenDRM.FluxoVertice(
        	Symbol("1"), # cod_vertice::Symbol
        	100_000.0,   # valor_alocado::Float64
        	0_000.0      # valor_mam::Float64
        )]
    )
    BacenDRM.ItemCarteira(
        :A30, nothing, :ME1, :offshore, :banking,
        [
            BacenDRM.FluxoVertice(Symbol("3"), 100_000.0, 0_000.0)
            BacenDRM.FluxoVertice(Symbol("12"), 100_000.0, 10_000.0)
        ]
    )
]

passivo = [
    BacenDRM.ItemCarteira(
        :P30, nothing, :JM1, :onshore_sem_clearing, :trading,
        [BacenDRM.FluxoVertice(Symbol("1"), 100_000.0, 0_000.0)]
    )
]

derivativo = [
    BacenDRM.ItemCarteira(
        :D41, :C, :JM1, :onshore_clearing, :banking,
        [BacenDRM.FluxoVertice(Symbol("1"), 100_000.0, 0_000.0)]
    )
]

ativo_fundo = [
    BacenDRM.ItemCarteira(
        :A90, nothing, :JM1, :offshore, :banking,
        [BacenDRM.FluxoVertice(Symbol("1"), 100_000.0, 0_000.0)]
    )
]

atividade_financeira = [
    BacenDRM.ItemCarteira(
        :AFC, :V, :JM1, nothing, :banking,
        [BacenDRM.FluxoVertice(Symbol("1"), 100_000.0, 0_000.0)]
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


BacenDRM.write_xml("DRM.xml", doc)
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
      <FluxoVertice CodVertice="1" ValorAlocado="100"/>
    </ItemCarteira>
    <ItemCarteira Item="A30" FatorRisco="ME1" LocalRegistro="03" CarteiraNegoc="02">
      <FluxoVertice CodVertice="3" ValorAlocado="100"/>
      <FluxoVertice CodVertice="12" ValorAlocado="100" ValorMaM="10"/>
    </ItemCarteira>
  </Ativo>
  <Passivo>
    <ItemCarteira Item="P30" FatorRisco="JM1" LocalRegistro="02" CarteiraNegoc="01">
      <FluxoVertice CodVertice="1" ValorAlocado="100"/>
    </ItemCarteira>
  </Passivo>
  <Derivativo>
    <ItemCarteira Item="D41" IdPosicao="C" FatorRisco="JM1" LocalRegistro="01" CarteiraNegoc="02">
      <FluxoVertice CodVertice="1" ValorAlocado="100"/>
    </ItemCarteira>
  </Derivativo>
  <AtivoFundo>
    <ItemCarteira Item="A90" FatorRisco="JM1" LocalRegistro="03" CarteiraNegoc="02">
      <FluxoVertice CodVertice="1" ValorAlocado="100"/>
    </ItemCarteira>
  </AtivoFundo>
  <AtividadeFinanceira>
    <ItemCarteira Item="AFC" IdPosicao="V" FatorRisco="JM1" CarteiraNegoc="02">
      <FluxoVertice CodVertice="1" ValorAlocado="100"/>
    </ItemCarteira>
  </AtividadeFinanceira>
</DocDRM>
```
