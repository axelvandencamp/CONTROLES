--SELECT pl.id pl_id, p.membership_state status, pl.partner_id, pl.amount_currency, pl.communication, pl.sdd_mandate_id, po.reference, po.date_created, sm.unique_mandate_reference, i.internal_number, i.state factuur_status
SELECT count(pl.id) aantal, MIN(i.write_date) min, MAX(i.write_date) max, age(max(i.write_date),min(i.write_date))
FROM res_partner p 
	JOIN payment_line pl ON pl.partner_id = p.id
	JOIN payment_order po ON pl.order_id = po.id
	JOIN sdd_mandate sm ON sm.id = pl.sdd_mandate_id
	JOIN account_move_line aml ON aml.id = pl.move_line_id
	JOIN account_invoice_line il ON il.id = aml.invoice_line_id
	JOIN account_invoice i ON i.id = il.invoice_id
	--JOIN res_partner p ON y.partner_id = p.id
WHERE po.reference IN ('2024/06337')
	AND i.state = 'paid'

/*
,'2017/02666','2017/02667','2017/02668','2017/02669','2017/02670','2017/02672','2017/02676','2017/02677')
*/