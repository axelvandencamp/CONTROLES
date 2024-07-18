SELECT p.id, p.create_date, p.membership_start, p.membership_pay_date, p.free_member, p.active, p.recruiting_organisation_id,
	CASE WHEN COALESCE(sm.pb_partner_id,0) = 0 THEN 0 ELSE 1 END DOMI, sq2.name via,
	--sq2.partner_id,
	--COALESCE(bs.name,bs2.name) RU, 
	bs.name, bs.create_date::date RU_CR, bs.write_date::date RU_WD,
	bsl.id RUL, bs.create_date::date RUL_CR, bsl.write_date::date RUL_WD
FROM res_partner p
	--bank/mandaat info
	LEFT OUTER JOIN (SELECT pb.id pb_id, pb.partner_id pb_partner_id FROM res_partner_bank pb JOIN sdd_mandate sm ON sm.partner_bank_id = pb.id WHERE sm.state = 'valid') sm ON sm.pb_partner_id = p.id
	--RU
	LEFT OUTER JOIN account_bank_statement_line bsl ON bsl.partner_id = p.id
	LEFT OUTER JOIN account_bank_statement bs ON bs.id = bsl.statement_id AND (bs.state = 'confirm' AND (bs.name LIKE '%-221-%' OR bs.name LIKE '%-029-%'))
	--
	LEFT OUTER JOIN (SELECT sq1.ml_partner_id, p.name, i.partner_id 
					FROM (SELECT MAX(id) ml_id, ml.partner ml_partner_id FROM membership_membership_line ml GROUP BY ml.partner) sq1
						--LEFT OUTER JOIN account_invoice_line il ON il.partner_id = sq1.partner_id
						LEFT OUTER JOIN account_invoice i ON i.membership_partner_id = sq1.ml_partner_id
						LEFT OUTER JOIN res_partner p ON p.id = i.partner_id) sq2 ON sq2.ml_partner_id = p.id
	--RU
	--LEFT OUTER JOIN account_bank_statement_line bsl2 ON bsl2.partner_id = sq2.partner_id
	--LEFT OUTER JOIN account_bank_statement bs2 ON bs2.id = bsl2.statement_id AND (bs.state = 'confirm' AND (bs.name LIKE '%-221-%' OR bs.name LIKE '%-029-%'))
--WHERE p.id = 
WHERE p.membership_nbr = '625619'

/*
SELECT sq1.partner_id, p.name, i.* 
FROM (SELECT MAX(id) ml_id, partner partner_id FROM membership_membership_line ml GROUP BY ml.partner) sq1
	--LEFT OUTER JOIN account_invoice_line il ON il.partner_id = sq1.partner_id
	LEFT OUTER JOIN account_invoice i ON i.membership_partner_id = sq1.partner_id
	LEFT OUTER JOIN res_partner p ON p.id = i.partner_id
WHERE sq1.partner_id = 403699	

SELECT * FROM account_invoice WHERE number = 'B-LID24-006817' LIMIT 10
SELECT * FROM account_invoice_line il WHERE il.invoice_id = 1677547
*/

	