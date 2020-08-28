
struct Vertice
    valor_alocado::Float64
    valor_mam::Float64
    function Vertice(valor_alocado::Float64, valor_mam::Float64)
        @assert valor_alocado > -eps() "valor alocado deve ser maior ou igual a zero"
        @assert valor_mam > -eps()  "valor mam deve ser maior ou igual a zero"
        new(valor_alocado, valor_mam)
    end
end

function Base.:+(x::Vertice, y::Vertice)
    return Vertice(x.valor_alocado + y.valor_alocado, x.valor_mam + y.valor_mam)
end

struct Fluxos
    vertices::Dict{Symbol, Vertice}
    Fluxos() = new(Dict{Symbol, Vertice}())
end

function Base.getindex(X::Fluxos, i::Symbol)::Vertice
    return X.vertices[i]
end
Base.getindex(X::Fluxos, i::Int64)::Vertice = X[get_codigo_vertice(i)]

function Base.setindex!(X::Fluxos, v::Vertice, i::Symbol)
    if i != get_codigo_vertice(12)
        @assert v.valor_mam < eps() "apenas o vertice :12 pode ter valor MaM maior que zero"
    end
    X.vertices[i] = v
end
Base.setindex!(X::Fluxos, v::Vertice, i::Int64) = X[get_codigo_vertice(i)] = v

function add_vertice!(fluxos::Fluxos, codigo_vertice::Symbol, vertice::Vertice)
    if haskey(fluxos.vertices, codigo_vertice)
        fluxos[codigo_vertice] += vertice
    else
        fluxos[codigo_vertice] = vertice
    end
end
add_vertice!(fluxos::Fluxos, i::Int64, vertice::Vertice) = add_vertice!(fluxos, get_codigo_vertice(i), vertice)

sorted_keys(fluxos::Fluxos) = sort(collect(keys(fluxos.vertices)))

function get_codigo_vertice(v::Int64)::Symbol
    @assert v >= 1
    @assert v <= 12
    if v < 10
        # add leading zero
        return Symbol("0$v")
    else
        return Symbol("$v")
    end
end

SymbolOrNothing = Union{Symbol, Nothing}

struct ItemCarteira
    item::Symbol
    id_posicao::SymbolOrNothing
    fator_risco::Symbol
    local_registro::SymbolOrNothing
    carteira_negoc::Symbol
    is_abertura_fundo::Bool
    function ItemCarteira(
        item::Symbol,
        id_posicao::SymbolOrNothing,
        fator_risco::Symbol,
        local_registro::SymbolOrNothing,
        carteira_negoc::Symbol,
        is_abertura_fundo::Bool=false)

        @assert item in CONTAS "item invalido: $item"
        id_posicao != nothing && @assert id_posicao in POSICOES "posicao invalida: $id_posicao"
        @assert fator_risco in FATORES_RISCO "fator de risco invalido: $fator_risco"
        local_registro != nothing && @assert local_registro in LOCAIS_REGISTRO "local_registro invalido: $local_registro"
        @assert carteira_negoc in CARTEIRAS "carteira invalida: $carteira_negoc"
        is_abertura_fundo && @assert item in CONTAS "item fundo invalido: $item"

        return new(item, id_posicao, fator_risco, local_registro, carteira_negoc, is_abertura_fundo)
    end
end

is_ativo(item::ItemCarteira)::Bool                = !item.is_abertura_fundo && (item.item in CONTAS_ATIVO)
is_ativo_fundo(item::ItemCarteira)::Bool          = item.is_abertura_fundo && (item.item in CONTAS_ATIVO)

is_passivo(item::ItemCarteira)::Bool              = !item.is_abertura_fundo && (item.item in CONTAS_PASSIVO)
is_passivo_fundo(item::ItemCarteira)::Bool        = item.is_abertura_fundo && (item.item in CONTAS_PASSIVO)

is_derivativo(item::ItemCarteira)::Bool           = !item.is_abertura_fundo && (item.item in CONTAS_DERIVATIVO)
is_derivativo_fundo(item::ItemCarteira)::Bool     = item.is_abertura_fundo && (item.item in CONTAS_DERIVATIVO)

is_atividade_financeira(item::ItemCarteira)::Bool = item.item in CONTAS_ATIVIDADE_FINANCEIRA

struct Documento
    id_docto::String
    id_docto_versao::String
    data_base::String
    id_inst_financ::Int64
    tipo_arq::Symbol
    nome_contato::String
    fone_contato::String
    ativo::Dict{ItemCarteira, Fluxos}                   # internal
    passivo::Dict{ItemCarteira, Fluxos}                 # internal
    derivativo::Dict{ItemCarteira, Fluxos}              # internal
    ativo_fundo::Dict{ItemCarteira, Fluxos}             # internal
    passivo_fundo::Dict{ItemCarteira, Fluxos}           # internal
    derivativo_fundo::Dict{ItemCarteira, Fluxos}        # internal
    atividade_financeira::Dict{ItemCarteira, Fluxos}    # internal

    function Documento(
        id_docto::String,
        id_docto_versao::String,
        data_base::String,
        id_inst_financ::Int64,
        tipo_arq::Symbol,
        nome_contato::String,
        fone_contato::String
    )
        @assert id_docto in ["2060"] "id documento invalido: $id_docto"
        @assert occursin(r"^v\d+$", id_docto_versao) "versao documento invalida: $id_docto_versao. exemplo: v1"
        @assert occursin(r"^\d{4}-\d{2}", data_base) "data base invalida: $data_base. exemplo: 2020-06"
        @assert tipo_arq in TIPOS_ARQUIVO "tipo arquivo invalido: $tipo_arq"
        @assert nome_contato != "" "nome contato obrigatorio"
        @assert fone_contato != "" "telefone contato obrigatorio"
        return new(
            id_docto, id_docto_versao, data_base, id_inst_financ,
            tipo_arq, nome_contato, fone_contato,
            # blank dicts
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}()
        )
    end
end

"""
Adds a vertice data into a document.
Document section is infered. Please check `_infer_document_section()`
"""
function Base.push!(doc::Documento, item::ItemCarteira, codigo_vertice::Union{Symbol, Int64}, vertice::Vertice)
    section = _infer_document_section(doc, item)
    if !haskey(section, item)
        section[item] = Fluxos() # init with blank
    end
    add_vertice!(section[item], codigo_vertice, vertice)
end

"Returns the `Document` section where `ItemCarteira` should be included. Depends on `ItemCarteira.item` code."
function _infer_document_section(doc::Documento, item_carteira::ItemCarteira)
    if is_ativo(item_carteira)
        return doc.ativo
    elseif is_ativo_fundo(item_carteira)
        return doc.ativo_fundo
    elseif is_passivo(item_carteira)
        return doc.passivo
    elseif is_passivo_fundo(item_carteira)
        return doc.passivo_fundo
    elseif is_derivativo(item_carteira)
        return doc.derivativo
    elseif is_derivativo_fundo(item_carteira)
        return doc.derivativo_fundo
    elseif is_atividade_financeira(item_carteira)
        return doc.atividade_financeira
    else
        error("unicorn!")
    end
end
