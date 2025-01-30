SELECT p.id partner_id, bs.name, p.active, csf.* 
FROM res_partner p 
	JOIN account_coda_sdd_refused csf ON p.id = csf.partner_id  
	JOIN account_bank_statement bs ON bs.id = csf.stat_id 

--WHERE p.id IN (280783,394144,358865)

WHERE bs.name = '23-288-335' 
	AND p.active = 'false'


--SELECT * FROM res_users WHERE id = 623	