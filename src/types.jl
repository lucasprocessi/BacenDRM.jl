
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

struct Documento
    id_docto::String
    id_docto_versao::String
    data_base::String
    id_inst_financ::Int64
    tipo_arq::Symbol
    nome_contato::String
    fone_contato::String
    ativo::Vector{ItemCarteira}
    passivo::Vector{ItemCarteira}
    derivativo::Vector{ItemCarteira}
    ativo_fundo::Vector{ItemCarteira}
    atividade_financeira::Vector{ItemCarteira}
    function Documento(
        id_docto::String,
        id_docto_versao::String,
        data_base::String,
        id_inst_financ::Int64,
        tipo_arq::Symbol,
        nome_contato::String,
        fone_contato::String,
        ativo::Vector{ItemCarteira},
        passivo::Vector{ItemCarteira},
        derivativo::Vector{ItemCarteira},
        ativo_fundo::Vector{ItemCarteira},
        atividade_financeira::Vector{ItemCarteira}
    )

        @assert id_docto in ["2060"] "id documento invalido: $id_docto"
        @assert occursin(r"^v\d+$", id_docto_versao) "versao documento invalida: $id_docto_versao. exemplo: v1"
        @assert occursin(r"^\d{4}-\d{2}", data_base) "data base invalida: $data_base. exemplo: 2020-06"
        @assert tipo_arq in [:I] "tipo arquivo invalido: $tipo_arq"
        @assert nome_contato != "" "nome contato obrigatorio"
        @assert fone_contato != "" "telefone contato obrigatorio"

        for ic in ativo
            @assert ic.id_posicao == nothing "$ic nao pode ter id_posicao"
            @assert ic.local_registro != nothing "$ic deve ter local_registro"
        end
        for ic in passivo
            @assert ic.id_posicao == nothing "$ic nao pode ter id_posicao"
            @assert ic.local_registro != nothing "$ic deve ter local_registro"
        end
        for ic in derivativo
            @assert ic.id_posicao != nothing "$ic deve ter id_posicao"
            @assert ic.local_registro != nothing "$ic deve ter local_registro"
        end
        for ic in ativo_fundo
            @assert ic.id_posicao == nothing "$ic nao pode ter id_posicao"
            @assert ic.local_registro != nothing "$ic deve ter local_registro"
        end
        for ic in atividade_financeira
            @assert ic.id_posicao != nothing "$ic deve ter id_posicao"
            @assert ic.local_registro == nothing "$ic nao pode ter local_registro"
        end

        return new(
            id_docto, id_docto_versao, data_base,
            id_inst_financ, tipo_arq, nome_contato,
            fone_contato, ativo, passivo, derivativo,
            ativo_fundo, atividade_financeira
        )

    end
end