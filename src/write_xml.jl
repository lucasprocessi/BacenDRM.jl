
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

    ativo = addelement!(drm, "Ativo")
    for item in doc.ativo
        _add_item_carteira!(ativo, item)
    end

    passivo = addelement!(drm, "Passivo")
    for item in doc.passivo
        _add_item_carteira!(passivo, item)
    end

    derivativo = addelement!(drm, "Derivativo")
    for item in doc.derivativo
        _add_item_carteira!(derivativo, item)
    end

    ativo_fundo = addelement!(drm, "AtivoFundo")
    for item in doc.ativo_fundo
        _add_item_carteira!(ativo_fundo, item)
    end

    atividade_financeira = addelement!(drm, "AtividadeFinanceira")
    for item in doc.atividade_financeira
        _add_item_carteira!(atividade_financeira, item)
    end

    return xml
end

function _add_item_carteira!(node::EzXML.Node, item::ItemCarteira)
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
    for fv in item.fluxos
        _add_fluxo_vertice!(node_item, fv)
    end
    return node
end

function _add_fluxo_vertice!(node::EzXML.Node, fv::FluxoVertice)
    node_fv = addelement!(node, "FluxoVertice")
    link!(node_fv, AttributeNode("CodVertice", "$(fv.cod_vertice)"))
    link!(node_fv, AttributeNode("ValorAlocado", "$(_trunc_to_thousands(fv.valor_alocado))"))
    fv.valor_mam > eps() && link!(node_fv, AttributeNode("ValorMaM", "$(_trunc_to_thousands(fv.valor_mam))"))
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