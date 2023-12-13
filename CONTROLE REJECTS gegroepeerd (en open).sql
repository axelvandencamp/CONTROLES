
-- REJECTS per datum, afschrift, journaal
-- QRY Joery voor opsporen onverwerkte REJECTS
------------------------------------------------------------
-- REJECTS per datum, afschrift, journaal
-- - obv gestructureerde mededeling die terugkomt van de bank ik veld [account_coda_sdd_refused].[comm]
----------------------------------------------
/*SELECT
 TRIM(cr.comm) struccomm,
 cr.create_date,
 cr.id,
 cr.name,
 cr.mandate_ref, 
 i.amount_total,
 i.partner_id,
 aj.name*/
SELECT cr.create_date::date date_reject, bs.name rek_afschrift, aj.name journaal, COUNT(i.id) aantal_fact, COUNT(i.partner_id) aantal_parnter_ids, SUM(i.amount_total) totaal_bedrag
FROM account_coda_sdd_refused cr
	JOIN account_bank_statement bs on bs.id = cr.stat_id
	JOIN account_invoice i ON REPLACE(REPLACE(i.reference,'+++',''),'/','') = TRIM(cr.comm)
	JOIN account_move am ON am.id = i.move_id
	JOIN account_journal aj ON aj.id = am.journal_id
WHERE aj.name IN ('LID - Lidmaatschappen','Giften')
	--AND bs.name = '19-288-342'
	AND cr.create_date::date >= '2023-01-01'
GROUP BY cr.create_date::date, bs.name, aj.name	
ORDER BY cr.create_date::date
--------------------------------------
-- QRY Joery voor opsporen onverwerkte REJECTS
--------------------------------------
--SELECT * FROM account_invoice i WHERE REPLACE(REPLACE(i.reference,'+++',''),'/','') = '129531001245'