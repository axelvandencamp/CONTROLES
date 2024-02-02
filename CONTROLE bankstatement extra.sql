﻿-----------------------------------------------------------
-- Bank Statement Line: betaling op basis van naam of mededeling
-----------------------------------------------------------
DROP TABLE IF EXISTS _AV_myvar;
CREATE TEMP TABLE _AV_myvar (zoekterm TEXT, start_datum DATE);

INSERT INTO _AV_myvar VALUES ('%C3221040-231333%',
							  '2021-10-01'); --*/('R:6-%');
--INSERT INTO _AV_myvar VALUES ('R:2-82251007/012%');
SELECT * FROM _AV_myvar;
-----------------------------------------------------------
SELECT abs.name, replace(absl.name, chr(10), ' ') Mededeling, absl.create_date, absl.write_date, absl.ref, absl.journal_id, absl.amount, absl.date, absl.partner_id, p.name
FROM _AV_myvar v, account_bank_statement abs LEFT OUTER JOIN account_bank_statement_line absl ON abs.id = absl.statement_id 
	LEFT OUTER JOIN res_partner p ON p.id = absl.partner_id
--WHERE partner_id = 361694	
WHERE (LOWER(absl.name) LIKE LOWER(v.zoekterm) OR LOWER(p.name) LIKE LOWER(v.zoekterm)) AND absl.create_date::date >= v.start_datum /*AND abs.name LIKE '20-288-%'*/
	 -- AND NOT(LOWER(absl.name) LIKE '%koalect%') AND abs.name LIKE '21-%'  -- voor "MANGOPAY" zonder toewijzing; met  v.zoekterm = '%mangopay%'
--WHERE (LOWER(absl.name) LIKE '%expeditie%' OR LOWER(absl.name) LIKE '%exp.%' OR (LOWER(absl.name) LIKE '%exp%' AND NOT(LOWER(absl.name) LIKE '%koalect%'))) AND abs.name LIKE '%288%'
--AND absl.amount = 30 AND absl.date BETWEEN '2020-12-21' AND '2020-12-23' --
--WHERE absl.amount = 52000
ORDER BY abs.create_date DESC




--SELECT * FROM account_bank_statement_line absl WHERE (LOWER(absl.name) LIKE '%geschenk%')
--SELECT * FROM account_bank_statement_line absl WHERE amount = 200000 ORDER BY create_date
--SELECT * FROM res_partner p WHERE p.id = 277436

--'structcomm_message' en 'coda_account_number' zijn niet altijd ingevuld
--SELECT * FROM account_bank_statement_line WHERE structcomm_message = '+++239/0400/00397+++' 
--SELECT * FROM account_bank_statement_line WHERE coda_account_number = 'BE44979621948645'
--SELECT * FROM res_partner_bank WHERE LOWER(acc_number) = 'be44979621948645'
-----------------------------------------------------------
