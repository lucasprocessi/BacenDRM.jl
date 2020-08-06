
struct Vertice
    valor_alocado::Float64
    valor_mam::Float64
    function Vertice(valor_alocado::Float64, valor_mam::Float64)
        @assert valor_alocado > eps() "valor alocado deve ser maior que zero"
        @assert valor_mam > -eps()  "valor mam deve ser maior ou igual a zero"
        new(valor_alocado, valor_mam)
    end
end

function Base.:+(x::Vertice, y::Vertice)
    return Vertice(x.valor_alocado + y.valor_alocado, x.valor_mam + y.valor_mam)
end

struct Fluxos
    vertices::Dict{Symbol, Vertice}
    function Fluxos(vertices::Dict{Symbol, Vertice})
        for (codigo, vertice) in vertices
            @assert codigo in VERTICES "vertice invalido: $codigo"
            if codigo != get_codigo_vertice(12)
                @assert vertice.valor_mam < eps() "apenas o vertice :12 pode ter valor MaM maior que zero"
            end
        end
        new(vertices)
    end
    Fluxos() = Fluxos(Dict{Symbol, Vertice}())
    function Fluxos(vertices::Dict{Int64, Vertice})
        d = Dict{Symbol, Vertice}()
        for (k,v) in vertices
            d[get_codigo_vertice(k)] = v
        end
        return Fluxos(d)
    end
end

function Base.getindex(X::Fluxos, i::Symbol)::Vertice
    return X.vertices[i]
end
function Base.setindex!(X::Fluxos, v::Vertice, i::Symbol)
    if i != get_codigo_vertice(12)
        @assert v.valor_mam < eps() "apenas o vertice :12 pode ter valor MaM maior que zero"
    end
    X.vertices[i] = v
end

function add_vertice!(fluxos::Fluxos, codigo_vertice::Symbol, vertice::Vertice)
    if haskey(fluxos.vertices, codigo_vertice)
        fluxos.vertices[codigo_vertice] += vertice
    else
        fluxos.vertices[codigo_vertice] = vertice
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
    function ItemCarteira(
        item::Symbol,
        id_posicao::SymbolOrNothing,
        fator_risco::Symbol,
        local_registro::SymbolOrNothing,
        carteira_negoc::Symbol)

        @assert item in CONTAS "item invalido: $item"
        id_posicao != nothing && @assert id_posicao in POSICOES "posicao invalida: $id_posicao"
        @assert fator_risco in FATORES_RISCO "fator de risco invalido: $fator_risco"
        local_registro != nothing && @assert local_registro in LOCAIS_REGISTRO "local_registro invalido: $local_registro"
        @assert carteira_negoc in CARTEIRAS "carteira invalida: $carteira_negoc"

        return new(item, id_posicao, fator_risco, local_registro, carteira_negoc)
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
    ativo::Dict{ItemCarteira, Fluxos}
    passivo::Dict{ItemCarteira, Fluxos}
    derivativo::Dict{ItemCarteira, Fluxos}
    ativo_fundo::Dict{ItemCarteira, Fluxos}
    atividade_financeira::Dict{ItemCarteira, Fluxos}
    function Documento(
        id_docto::String,
        id_docto_versao::String,
        data_base::String,
        id_inst_financ::Int64,
        tipo_arq::Symbol,
        nome_contato::String,
        fone_contato::String,
        ativo::Dict{ItemCarteira, Fluxos},
        passivo::Dict{ItemCarteira, Fluxos},
        derivativo::Dict{ItemCarteira, Fluxos},
        ativo_fundo::Dict{ItemCarteira, Fluxos},
        atividade_financeira::Dict{ItemCarteira, Fluxos}
    )

        @assert id_docto in ["2060"] "id documento invalido: $id_docto"
        @assert occursin(r"^v\d+$", id_docto_versao) "versao documento invalida: $id_docto_versao. exemplo: v1"
        @assert occursin(r"^\d{4}-\d{2}", data_base) "data base invalida: $data_base. exemplo: 2020-06"
        @assert tipo_arq in TIPOS_ARQUIVO "tipo arquivo invalido: $tipo_arq"
        @assert nome_contato != "" "nome contato obrigatorio"
        @assert fone_contato != "" "telefone contato obrigatorio"

        for ic in keys(ativo)
            @assert ic.item in CONTAS_ATIVO "conta de ativo invalida: $(ic.item)"
            @assert ic.id_posicao == nothing "$ic nao pode ter id_posicao"
            @assert ic.local_registro != nothing "$ic deve ter local_registro"
        end
        for ic in keys(passivo)
            @assert ic.item in CONTAS_PASSIVO "conta de passivo invalida: $(ic.item)"
            @assert ic.id_posicao == nothing "$ic nao pode ter id_posicao"
            @assert ic.local_registro != nothing "$ic deve ter local_registro"
        end
        for ic in keys(derivativo)
            @assert ic.item in CONTAS_DERIVATIVO "conta de derivativo invalida: $(ic.item)"
            @assert ic.id_posicao != nothing "$ic deve ter id_posicao"
            @assert ic.local_registro != nothing "$ic deve ter local_registro"
        end
        for ic in keys(ativo_fundo)
            @assert ic.item in CONTAS_ATIVO "conta de ativo de fundo invalida: $(ic.item)"
            @assert ic.id_posicao == nothing "$ic nao pode ter id_posicao"
            @assert ic.local_registro != nothing "$ic deve ter local_registro"
        end
        for ic in keys(atividade_financeira)
            @assert ic.item in CONTAS_ATIVIDADE_FINANCEIRA "conta de atividade financeira invalida: $(ic.item)"
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
    function Documento(
        id_docto::String,
        id_docto_versao::String,
        data_base::String,
        id_inst_financ::Int64,
        tipo_arq::Symbol,
        nome_contato::String,
        fone_contato::String
    )
        return Documento(
            id_docto, id_docto_versao, data_base, id_inst_financ,
            tipo_arq, nome_contato, fone_contato,
            # blank dicts
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}(),
            Dict{ItemCarteira, Fluxos}()
        )
    end
end