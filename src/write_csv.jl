
const CSV_FIELDS = [
        :secao
        :item
        :id_posicao
        :fator_risco
        :local_registro
        :carteira_negoc
        :v01
        :v02
        :v03
        :v04
        :v05
        :v06
        :v07
        :v08
        :v09
        :v10
        :v11
        :v12
        :v12_MaM
]

const CSV_DELIMITER = ";"
const NA_STRING = ""
const DECIMAL_DEMILITER = ","

function write_csv(io::IO, doc::Documento)

    # struct Documento
    #     id_docto::String
    #     id_docto_versao::String
    #     data_base::String
    #     id_inst_financ::Int64
    #     tipo_arq::Symbol
    #     nome_contato::String
    #     fone_contato::String
    #     ativo::Vector{ItemCarteira}
    #     passivo::Vector{ItemCarteira}
    #     derivativo::Vector{ItemCarteira}
    #     ativo_fundo::Vector{ItemCarteira}
    #     atividade_financeira::Vector{ItemCarteira}

    _write_csv_header(io)

    for item_carteira in sorted_keys(doc.ativo)
        _write_csv_item_carteira(io, item_carteira, doc.ativo[item_carteira], "ativo")
    end
    for item_carteira in sorted_keys(doc.passivo)
        _write_csv_item_carteira(io, item_carteira, doc.passivo[item_carteira], "passivo")
    end
    for item_carteira in sorted_keys(doc.derivativo)
        _write_csv_item_carteira(io, item_carteira, doc.derivativo[item_carteira], "derivativo")
    end
    for item_carteira in sorted_keys(doc.ativo_fundo)
        _write_csv_item_carteira(io, item_carteira, doc.ativo_fundo[item_carteira], "ativo_fundo")
    end
    for item_carteira in sorted_keys(doc.atividade_financeira)
        _write_csv_item_carteira(io, item_carteira, doc.atividade_financeira[item_carteira], "atividade_financeira")
    end

end

function _write_csv_header(io::IO)
    println(io, join(CSV_FIELDS, CSV_DELIMITER))
end

function _write_csv_item_carteira(io::IO, item::ItemCarteira, fluxos::Fluxos, secao::String)
    csv_values = Vector{String}([
        secao                                  # :secao
        to_string(item.item)                   # :item
        to_string(item.id_posicao)             # :id_posicao
        to_string(item.fator_risco)            # :fator_risco
        to_string(item.local_registro)         # :local_registro
        to_string(item.carteira_negoc)         # :carteira_negoc
        to_string(get_valor_alocado(fluxos,  1)) # :v01
        to_string(get_valor_alocado(fluxos,  2)) # :v02
        to_string(get_valor_alocado(fluxos,  3)) # :v03
        to_string(get_valor_alocado(fluxos,  4)) # :v04
        to_string(get_valor_alocado(fluxos,  5)) # :v05
        to_string(get_valor_alocado(fluxos,  6)) # :v06
        to_string(get_valor_alocado(fluxos,  7)) # :v07
        to_string(get_valor_alocado(fluxos,  8)) # :v08
        to_string(get_valor_alocado(fluxos,  9)) # :v09
        to_string(get_valor_alocado(fluxos, 10)) # :v10
        to_string(get_valor_alocado(fluxos, 11)) # :v11
        to_string(get_valor_alocado(fluxos, 12)) # :v12
        to_string(get_valor_mam(fluxos, 12))     # :v12_MaM
    ])
    println(io, join(csv_values, CSV_DELIMITER))
end

to_string(x::Symbol) = "$x"
to_string(x::Nothing) = NA_STRING
function to_string(x::Float64)
    out = "$x"
    if DECIMAL_DEMILITER != "."
        out = replace(out, "." => DECIMAL_DEMILITER)
    end
    return out
end

"Retorna o valor alocado no vertice de um ItemCarteira. Retorna 0.0 caso não haja valor alocado."
function get_valor_alocado(fluxos::Fluxos, codigo_vertice::Symbol)
    if haskey(fluxos.vertices, codigo_vertice)
        return fluxos.vertices[codigo_vertice].valor_alocado
    else
        return 0.0
    end
end
get_valor_alocado(fluxos::Fluxos, i::Int64) = get_valor_alocado(fluxos, get_codigo_vertice(i))

"Retorna o valor MaM no vertice de um ItemCarteira. Retorna 0.0 caso não haja valor MaM."
function get_valor_mam(fluxos::Fluxos, codigo_vertice::Symbol)
    if haskey(fluxos.vertices, codigo_vertice)
        return fluxos.vertices[codigo_vertice].valor_mam
    else
        return 0.0
    end
end
get_valor_mam(fluxos::Fluxos, i::Int64) = get_valor_mam(fluxos, get_codigo_vertice(i))

write_csv(path::String, doc::Documento) = open(path, "w+") do io write_csv(io, doc) end
