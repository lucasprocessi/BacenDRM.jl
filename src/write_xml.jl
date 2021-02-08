
function to_xml(doc::Documento)
    xml = XMLDocumentNode("1.0")
    drm = addelement!(xml, "DocDRM")

    addelement!(drm, "IdDocto"      , doc.id_docto)
    addelement!(drm, "IdDoctoVersao", doc.id_docto_versao)
    addelement!(drm, "DataBase"     , doc.data_base)
    addelement!(drm, "IdInstFinanc" , "$(doc.id_inst_financ)")
    addelement!(drm, "TipoArq"      , "$(doc.tipo_arq)")
    addelement!(drm, "NomeContato"  , doc.nome_contato)
    addelement!(drm, "FoneContato"  , doc.fone_contato)

    if length(doc.ativo) > 0
        ativo = addelement!(drm, "Ativo")
        for item in sorted_keys(doc.ativo)
            _add_item_carteira!(ativo, item, doc.ativo[item])
        end
    end

    if length(doc.passivo) > 0
        passivo = addelement!(drm, "Passivo")
        for item in sorted_keys(doc.passivo)
            _add_item_carteira!(passivo, item, doc.passivo[item])
        end
    end

    if length(doc.derivativo) > 0
        derivativo = addelement!(drm, "Derivativo")
        for item in sorted_keys(doc.derivativo)
            _add_item_carteira!(derivativo, item, doc.derivativo[item])
        end
    end

    if length(doc.ativo_fundo) > 0
        ativo_fundo = addelement!(drm, "AtivoFundo")
        for item in sorted_keys(doc.ativo_fundo)
            _add_item_carteira!(ativo_fundo, item, doc.ativo_fundo[item])
        end
    end

    if length(doc.passivo_fundo) > 0
        passivo_fundo = addelement!(drm, "PassivoFundo")
        for item in sorted_keys(doc.passivo_fundo)
            _add_item_carteira!(passivo_fundo, item, doc.passivo_fundo[item])
        end
    end

    if length(doc.derivativo_fundo) > 0
        derivativo_fundo = addelement!(drm, "DerivativoFundo")
        for item in sorted_keys(doc.derivativo_fundo)
            _add_item_carteira!(derivativo_fundo, item, doc.derivativo_fundo[item])
        end
    end

    if length(doc.atividade_financeira) > 0
        atividade_financeira = addelement!(drm, "AtividadeFinanceira")
        for item in sorted_keys(doc.atividade_financeira)
            _add_item_carteira!(atividade_financeira, item, doc.atividade_financeira[item])
        end
    end

    return xml
end

function sorted_keys(d::Dict{ItemCarteira, Fluxos})
    v_keys = sort(collect(keys(d)), by = x -> x.item)
    return v_keys
end

function must_be_written(fluxos::Fluxos)
    # write if any vertice must be written
    must = false
    for codigo in sorted_keys(fluxos)
        vertice = fluxos[codigo]
        must = must || must_be_written(vertice)
    end
    return must
end

function _add_item_carteira!(node::EzXML.Node, item::ItemCarteira, fluxos::Fluxos)
    if !must_be_written(fluxos)
        return nothing
    end
    node_item = addelement!(node, "ItemCarteira")
    # item::Symbol
    # id_posicao::SymbolOrNothing
    # fator_risco::Symbol
    # local_registro::SymbolOrNothing
    # carteira_negoc::Symbol
    # fluxos::Vector{FluxoVertice}
    link!(node_item, AttributeNode("Item", _encode_item(item.item)))
    if item.id_posicao != nothing
        link!(node_item, AttributeNode("IdPosicao", _encode_id_posicao(item.id_posicao)))
    end
    link!(node_item, AttributeNode("FatorRisco", _encode_fator_risco(item.fator_risco)))
    if item.local_registro != nothing
        link!(node_item, AttributeNode("LocalRegistro", _encode_local_registro(item.local_registro)))
    end
    link!(node_item, AttributeNode("CarteiraNegoc", _encode_carteira_negoc(item.carteira_negoc)))
    for codigo in sorted_keys(fluxos)
        _add_fluxo_vertice!(node_item, codigo, fluxos[codigo])
    end
    return node
end

function must_be_written(vertice::Vertice)
    valor = _trunc_to_thousands(vertice.valor_alocado)
    return (valor > 0)
end
function _add_fluxo_vertice!(node::EzXML.Node, codigo_vertice::Symbol, vertice::Vertice)
    # Validate if must be written
    if !must_be_written(vertice)
        return nothing
    end
    valor = _trunc_to_thousands(vertice.valor_alocado)
    valor_mam = _trunc_to_thousands(vertice.valor_mam)
    node_fv = addelement!(node, "FluxoVertice")
    link!(node_fv, AttributeNode("CodVertice", "$codigo_vertice"))
    link!(node_fv, AttributeNode("ValorAlocado", "$valor"))
    valor_mam > 0 && link!(node_fv, AttributeNode("ValorMaM", "$valor_mam"))
    return node
end

_encode_item(x::Symbol)::String = "$x"
_encode_id_posicao(x::Symbol)::String = "$x"
_encode_fator_risco(x::Symbol)::String = "$x"
function _encode_local_registro(x::Symbol)::String
    @assert haskey(DECODE_LOCAIS_REGISTRO, x) "local registro invalido: $x"
    return DECODE_LOCAIS_REGISTRO[x]
end
function _encode_carteira_negoc(x::Symbol)::String
    @assert haskey(DECODE_CARTEIRAS, x) "carteira negoc invalida: $x"
    return DECODE_CARTEIRAS[x]
end

_trunc_to_thousands(x::Float64)::Int64 = Int64(trunc(x/1000))

write_xml(io::IO, doc::Documento) = prettyprint(io, to_xml(doc))
write_xml(path::String, doc::Documento) = open(path, "w+") do io write_xml(io, doc) end
