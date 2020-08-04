
# helpers for ItemCarteira

"Returns true if two `ItemCarteira` refer to the same item in a document"
function same_item(ic1::ItemCarteira, ic2::ItemCarteira)::Bool
	return(
		ic1.item == ic2.item &&
		ic1.id_posicao == ic2.id_posicao &&
		ic1.fator_risco == ic2.fator_risco &&
		ic1.local_registro == ic2.local_registro &&
		ic1.carteira_negoc == ic2.carteira_negoc
	)
end
