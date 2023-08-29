--SET VARIABLES
DROP TABLE IF EXISTS _av_myvar;
SELECT 
	'2023-01-01'::date AS startdatum, 
	'2023-12-31'::date AS einddatum
INTO TEMP TABLE _av_myvar;
SELECT * FROM _av_myvar;
--===========================================================
SELECT * FROM
	(SELECT g.datum, g.bedrag,
		CASE
			WHEN LOWER(g.description) LIKE '%jacht%' THEN 'kw jacht'
			WHEN LOWER(g.description) LIKE '%brandhout%' THEN 'kw brandhout'
			WHEN LOWER(g.description) LIKE '%verkoop%' THEN 'kw verkoop'
			WHEN LOWER(g.description) LIKE '%verhuur%' THEN 'kw verhuur'
			WHEN LOWER(g.description) LIKE '%opbrengst%' THEN 'kw opbrengst'
			WHEN LOWER(g.description) LIKE '%inzameling%' THEN 'kw inzameling'
	 		WHEN LOWER(g.description) LIKE '%wildbeheer%' THEN 'kw wildbeheer'
	 		WHEN LOWER(g.description) LIKE '%overeenkomst%' THEN 'kw overeenkomst'
	 		WHEN LOWER(g.description) LIKE '%subsidie%' THEN 'kw subsidie'
			WHEN g.bedrag IN (27,30,38) THEN 'Lidgeld?'
			WHEN COALESCE(o.id,0) <> 0 THEN 'NP organisatie'
			WHEN LOWER(p.email_work) LIKE '%@natuurpunt.be' THEN 'personeelslid'
			WHEN COALESCE(g.partner_id,0) = 0 THEN 'geen relatie ingevuld'
			WHEN boeking_type = 'correctie' THEN 'correctie'
			--WHEN rechtspersoon IN (15,16) THEN 'Stichting'
			WHEN SQ2.r > 0 AND g.bedrag >= 100 THEN 'Vrijwilliger'
	 		WHEN wc.bron = 'deelnemers expeditie' AND EXTRACT(YEAR FROM wc.datum_toevoeging) >= EXTRACT(YEAR FROM v.startdatum) THEN 'deelnemer expeditie'
			WHEN (round(g.bedrag) - g.bedrag <> 0 AND g.bedrag > 100) THEN 'bedrag niet rond'
		END type_controle,
		g.partner_id, p.name, 
		CASE
			WHEN COALESCE(o.id,0) <> 0 THEN o.name ELSE 'NP ext'
		END type_partner,
		p.email, p.email_work, g.description, g.grootboekrek, g.project, g.dimensie1, g.code1, g.dimensie2, g.code2, g.dimensie3, g.code3, g.boeking, g.vzw, 
		'geen: te controleren' genomen_actie
	FROM _av_myvar v, marketing._m_sproc_rpt_giften('CST',v.startdatum,v.einddatum,15) g
		LEFT OUTER JOIN res_partner p ON g.partner_id = p.id
		LEFT OUTER JOIN res_organisation_type o ON p.organisation_type_id = o.id
	 	LEFT OUTER JOIN marketing._m_dwh_warmecontacten wc ON wc.erp_id = p.id
		JOIN (SELECT p.id, COUNT(ft.id) AS r FROM res_partner p LEFT OUTER JOIN res_organisation_function of ON p.id = of.person_id LEFT OUTER JOIN res_function_type ft ON of.function_type_id = ft.id GROUP BY p.id) SQ2 ON g.partner_id = SQ2.id
	WHERE grootboekrek = '732000'
		AND (
			(LOWER(description) LIKE '%jacht%'
				OR LOWER(description) LIKE '%brandhout%'
				OR LOWER(description) LIKE '%verkoop%'
				OR LOWER(description) LIKE '%verhuur%'
				OR LOWER(description) LIKE '%opbrengst%'
				OR LOWER(description) LIKE '%inzameling%'
				OR LOWER(g.description) LIKE '%wildbeheer%'
			 	OR LOWER(g.description) LIKE '%overeenkomst%'
				OR LOWER(g.description) LIKE '%subsidie%')
			OR g.bedrag IN (27,30,38)
			OR COALESCE(o.id,0) <> 0
			OR (round(g.bedrag) - g.bedrag <> 0 AND g.bedrag > 100)
			OR COALESCE(g.partner_id,0) = 0
			OR boeking_type = 'correctie'
			--OR rechtspersoon IN (15,16)
			OR LOWER(p.email_work) LIKE '%@natuurpunt.be'
			OR SQ2.r > 0 AND g.bedrag >= 100
		)
	) SQ1
ORDER BY SQ1.type_controle


/*
--controle op niet-ronde getallen
WHERE round(amount) - amount <> 0

SELECT * FROM res_organisation_type 



SELECT g.date, g.amount, g.partner_id, g.naam, g.description, g.grootboekrek, g.project, g.dimensie1, g.code1, g.dimensie2, g.code2, g.dimensie3, g.code3, g.boeking, g.vzw
FROM myvar v, _crm_giften(v.startdatum,v.einddatum) g
WHERE COALESCE(partner_id,0) = 0
*/

