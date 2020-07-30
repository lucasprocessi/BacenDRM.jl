# BacenDRM.jl

Writes DRM (monthly market risk report) XML file, as required from Brazilian Central Bank (BACEN)

### Example

```julia
ativo = [
    BacenDRM.ItemCarteira(
        :A20,      # item::Symbol
        nothing,   # id_posicao::SymbolOrNothing
        :JM1,      # fator_risco::Symbol
        :offshore, # local_registro::SymbolOrNothing
        :banking,  # carteira_negoc::Symbol
        # BacenDRM.FluxoVertice(cod_vertice::Symbol, valor_alocado::Float64, valor_mam::Float64)
        [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
    )
    BacenDRM.ItemCarteira(
        :A30,      # item::Symbol
        nothing,   # id_posicao::SymbolOrNothing
        :ME1,      # fator_risco::Symbol
        :offshore, # local_registro::SymbolOrNothing
        :banking,  # carteira_negoc::Symbol
        [
            BacenDRM.FluxoVertice(Symbol("3"), 100.0, 0.0)
            BacenDRM.FluxoVertice(Symbol("12"), 100.0, 10.0)
        ]
    )
]

passivo = [
    BacenDRM.ItemCarteira(
        :P30,                  # item::Symbol
        nothing,               # id_posicao::SymbolOrNothing
        :JM1,                  # fator_risco::Symbol
        :onshore_sem_clearing, # local_registro::SymbolOrNothing
        :trading,              # carteira_negoc::Symbol
        [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
    )
]

derivativo = [
    BacenDRM.ItemCarteira(
        :     D41,         # item::Symbol
        :C,                # id_posicao::SymbolOrNothing
        :JM1,              # fator_risco::Symbol
        :onshore_clearing, # local_registro::SymbolOrNothing
        :banking,          # carteira_negoc::Symbol
        [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
    )
]

ativo_fundo = [
    BacenDRM.ItemCarteira(
        :A90,      # item::Symbol
        nothing,   # id_posicao::SymbolOrNothing
        :JM1,      # fator_risco::Symbol
        :offshore, # local_registro::SymbolOrNothing
        :banking,  # carteira_negoc::Symbol
        [BacenDRM.FluxoVertice(Symbol("1"), 100.0, 0.0)]
    )
]

atividade_financeira = [
    BacenDRM.ItemCarteira(
        :     AFC, # item::Symbol
        :V,        # id_posicao::SymbolOrNothing
        :JM1,      # fator_risco::Symbol
        nothing,   # local_registro::SymbolOrNothing
        :banking,  # carteira_negoc::Symbol
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

BacenDRM.write_xml("DRM.xml", doc)
```

#### Content of "DRM.xml"

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
```
