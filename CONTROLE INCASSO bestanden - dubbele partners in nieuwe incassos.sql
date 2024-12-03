---------------------------------------------------
-- controle queries:
-- -----------------
-- DUBBELE ID's in incasso('s)
-- specifiek partner_id opzoeken in incasso bestand
-- status ophalen ahv ID's uit incasso opdrachten met factuur info
-- TOTALEN: aantal betalingen en som bedrag in incasso bestand
-- TELLER betaalde facturen (bij bevestigen 
---------------------------------------------------
-- DUBBELE ID's in incasso('s)
---------------------------------------------------
--SELECT * FROM (
SELECT pl.id pl_id, p.membership_state status, y.partner_id, pl.amount_currency, pl.communication, pl.sdd_mandate_id, po.reference, po.date_created, sm.unique_mandate_reference, ai.internal_number, ai.state factuur_status, ROW_NUMBER() OVER(PARTITION BY y.partner_id ORDER BY y.partner_id asc) AS Aantal 
FROM
	(SELECT DISTINCT x.partner_id 
	FROM
		(
		SELECT pl.id pl_id, *, ROW_NUMBER() OVER(PARTITION BY pl.partner_id ORDER BY pl.partner_id asc) AS Aantal
		FROM payment_line pl JOIN payment_order po ON pl.order_id = po.id
		WHERE po.reference IN ('2024/06130','2024/06132','2024/06133')
		) x
	WHERE x.aantal > 1
	) y
	JOIN payment_line pl ON y.partner_id = pl.partner_id
	JOIN payment_order po ON pl.order_id = po.id
	JOIN sdd_mandate sm ON sm.id = pl.sdd_mandate_id
	JOIN account_move_line aml ON aml.id = pl.move_line_id
	JOIN account_invoice_line ail ON ail.id = aml.invoice_line_id
	JOIN account_invoice ai ON ai.id = ail.invoice_id
	JOIN res_partner p ON y.partner_id = p.id
WHERE po.reference IN ('2024/06130','2024/06132','2024/06133')
	AND y.partner_id IN (20869,16653,16901)
ORDER BY y.partner_id
--) z WHERE z.Aantal > 1
--------------------------------------------------------
-- status ophalen ahv ID's uit incasso opdrachten met factuur info
--------------------------------------------------------
--/*
SELECT pl.partner_id, p.membership_state, i.number, aml.invoice_line_id, il.id, po.reference, i.amount_total, p.membership_end recentste_einddatum_lidmaatschap
FROM 	res_partner p
	JOIN payment_line pl ON p.id = pl.partner_id
	JOIN payment_order po ON pl.order_id = po.id
	JOIN account_move_line aml ON aml.id = pl.move_line_id
	JOIN account_invoice_line il ON il.id = aml.invoice_line_id
	JOIN account_invoice i ON i.id = il.invoice_id

	JOIN (SELECT partner FROM membership_membership_line ml WHERE ml.state = 'paid' AND ml.date_to >= '2023-12-31') SQ1 ON SQ1.partner = p.id --voor controle december voor volgend jaar
	
WHERE po.reference IN ('2024/06130','2024/06132','2024/06133')
	--AND p.membership_state = 'paid'  --voor controle tijdens het jaar
	AND p.membership_end = '2025-12-31'
	--AND NOT(amount_total IN (44,15,27, 10,11,37,38))
--ORDER BY amount_total ASC	
ORDER BY po.reference, i.number

--*/
--------------------------------------------------------
-- specifiek partner_id opzoeken
--------------------------------------------------------
SELECT * FROM res_partner_bank LIMIT 10
--/*
SELECT pl.partner_id, pl.amount_currency, pl.communication, pl.sdd_mandate_id, pb.acc_number, pb.bank_bic, po.reference, po.date_created, sm.unique_mandate_reference, sm.state
	--, ai.internal_number
FROM res_partner p
	JOIN payment_line pl ON pl.partner_id = p.id
	JOIN payment_order po ON pl.order_id = po.id
	JOIN sdd_mandate sm ON sm.id = pl.sdd_mandate_id
	JOIN res_partner_bank pb ON pb.id = pl.bank_id
	
	/*JOIN account_move_line aml ON aml.id = pl.move_line_id
	JOIN account_invoice_line ail ON ail.id = aml.invoice_line_id
	JOIN account_invoice ai ON ai.id = ail.invoice_id*/
WHERE po.reference IN ('2024/05901','2024/05902','2024/05903','2024/05904','2024/05905','2024/05906','2024/05907')
	--AND COALESCE(pb.bank_bic,'leeg') = 'leeg' -- = 'DUMMY'
	--AND p.active = 't'
	AND pl.partner_id IN (79711,146270,215431)
	--AND pb.acc_number = 'BE48001107102527'
	--AND NOT(sm.state = 'valid')
ORDER BY po.reference	
--*/

--------------------------------------------------------
-- TOTALEN: aantal betalingen en som bedrag in incasso bestand
--------------------------------------------------------
SELECT SUM(pl.amount_currency) totaal, COUNT(pl.id) aantal
FROM payment_line pl JOIN payment_order po ON pl.order_id = po.id
WHERE po.reference IN ('2020/04517','2020/04518','2020/04519','2020/04520','2020/04521','2020/04522','2020/04523','2020/04525')	
--------------------------------------------------------
-- TELLER betaalde facturen (bij bevestigen 
--------------------------------------------------------
SELECT COUNT(p.id) aantal, ((6911-COUNT(p.id))*2)/815::numeric time_remaining --pl.partner_id, p.membership_state, i.number, i.state, aml.invoice_line_id, il.id, po.reference, i.amount_total, p.membership_end recentste_einddatum_lidmaatschap
FROM 	res_partner p
	JOIN payment_line pl ON p.id = pl.partner_id
	JOIN payment_order po ON pl.order_id = po.id
	JOIN account_move_line aml ON aml.id = pl.move_line_id
	JOIN account_invoice_line il ON il.id = aml.invoice_line_id
	JOIN account_invoice i ON i.id = il.invoice_id
WHERE po.reference IN ('2020/04523')
	AND i.state = 'paid'	
--------------------------------------------------------
-- gegevens betaallijn opzoeken op basis van referentie uit incasso opdracht
--------------------------------------------------------
--/*
SELECT *
FROM payment_line pl 
	JOIN payment_order po ON pl.order_id = po.id
WHERE pl.communication = '+++126/0450/01808+++'
WHERE po.reference IN ('2021/04942')
	AND*/ pl.name = 'DOMG/2022/19779'
--*/