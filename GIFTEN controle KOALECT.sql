--=================================================================
--OPMERKING:
-- 
--WERKWIJZE:
-- variabelen bepalen: MANUEEL NAKIJKEN (aanpassen waar nodig)
-- temp tabel voor import koalect gegevens aanmaken
-- data importeren: MANUELE ACTIE
-- temp tabel voor Giften data aanmaken
-- Giften data ophalen
-- T_ERP uit "description" halen
-- -- controle data samenstellen
--=================================================================
--=========================================================--
--*/
--SET VARIABLES
DROP TABLE IF EXISTS myvar;
SELECT 
	'2021-01-01'::date AS startdatum,
	'2021-12-31'::date AS einddatum,
	'fundraising'::text AS koalect_platform, -- expeditie - donations - fundraising
	'dummy'::text AS vervang_str1,
	'dummy'::text AS vervang_str2,
	'dummy'::text AS vervang_str3,
	'dummy'::text AS filter_str1,
	'dummy'::text AS filter_str2,
	'dummy'::text AS filter_str3
INTO TEMP TABLE myvar;
SELECT * FROM myvar;
-- vervang_str1 invullen
UPDATE myvar
	SET vervang_str1 = CASE WHEN koalect_platform = 'expeditie' THEN 'mangopaysanpexp'
				WHEN koalect_platform = 'donations' THEN 'mangopaysanpdonation'
				WHEN koalect_platform = 'fundraising' THEN 'mangopaysanpfundraising'
			END;
-- vervang_str2 invullen
UPDATE myvar
	SET vervang_str2 = CASE WHEN koalect_platform = 'expeditie' THEN 'mangopaynpexp'
				WHEN koalect_platform = 'donations' THEN 'mangopaynpdonation'
				WHEN koalect_platform = 'fundraising' THEN 'mangopaynpfundraising'
			END;
-- vervang_str3 invullen
UPDATE myvar
	SET vervang_str3 = CASE WHEN koalect_platform = 'expeditie' THEN 'mangopays.a.-pinpexp'
				WHEN koalect_platform = 'donations' THEN 'mangopays.a.-pinpdonation'
				WHEN koalect_platform = 'fundraising' THEN 'mangopays.a.-pinpfundraising'
			END;			
-- filter_str1 invullen
UPDATE myvar
	SET filter_str1 = CASE WHEN koalect_platform = 'expeditie' THEN '%mangopaysanpexp%'
				WHEN koalect_platform = 'donations' THEN '%mangopaysanpdonation%'
				WHEN koalect_platform = 'fundraising' THEN '%mangopaysanpfundraising%'
			END;
-- filter_str2 invullen
UPDATE myvar
	SET filter_str2 = CASE WHEN koalect_platform = 'expeditie' THEN '%mangopaynpexp%'
				WHEN koalect_platform = 'donations' THEN '%mangopaynpdonation%'
				WHEN koalect_platform = 'fundraising' THEN '%mangopaynpfundraising%'
			END;
-- filter_str3 invullen
UPDATE myvar
	SET filter_str3 = CASE WHEN koalect_platform = 'expeditie' THEN '%mangopays.a.-pinpexp%'
				WHEN koalect_platform = 'donations' THEN '%mangopays.a.-pinpdonation%'
				WHEN koalect_platform = 'fundraising' THEN '%mangopays.a.-pinpfundraising%'
			END;			
--=========================================================--
--CREATE TEMP TABLE
/*
DROP TABLE IF EXISTS marketing._AV_temp_algemeen;

CREATE TABLE marketing._AV_temp_algemeen 
(Transaction_ID TEXT,
 Firstname TEXT,
 Lastname TEXT,
 Street TEXT,
 Nr TEXT,
 Bus TEXT,
 PC TEXT,
 Gemeente TEXT,
 Email TEXT,
 dummy1 TEXT,
 Kostenplaats TEXT,
 Projectnaam TEXT,
 Bedrag TEXT, -- probleem met "," in "bedrag"-veld; later omzetten naar NUMERIC bij controle query; "REPLACE(bedrag,',','.')::numeric"
 dummy2 TEXT,
 dummy3 TEXT,
-- dummy4 TEXT, -- enkel nodig voor fundraising
 "Date" TEXT,
 Actie_ID NUMERIC, -- in comment voor donations
 Actie_Code TEXT -- in comment voor donations
);

SELECT * FROM marketing._AV_temp_algemeen WHERE; -- transaction_id = '191586'
*/
--===========================================================
-- koalect data manueel importeren
--===========================================================
-- temp tabel voor Giften data aanmaken
---------------------------------------
DROP TABLE IF EXISTS _AV_temp_GIFTEN;

CREATE TEMP TABLE _AV_temp_GIFTEN (
	T_ERP TEXT,
	N_ERP TEXT,
	ID_ERP NUMERIC,
	act_ERP BOOLEAN,
	K_ERP TEXT,
	P_ERP TEXT,
	B_ERP NUMERIC,
	Boeking_ERP TEXT);

SELECT * FROM _AV_temp_GIFTEN;	
--/*
--------------------------------------------------
-- Giften data ophalen
----------------------
INSERT INTO _AV_temp_GIFTEN
	(SELECT LOWER(REPLACE(REPLACE(REPLACE(REPLACE(aml.name,';',','),chr(10),''),chr(13), ''),chr(32), '')) AS T_ERP,
		--v.filter_str1, v.filter_str2, v.filter_str3,  --voor testen
		p.name as N_ERP,
		p.id ID_ERP, p.active,
		COALESCE(COALESCE(aaa3.code,aaa2.code),aaa1.code) AS K_ERP,
		COALESCE(COALESCE(aaa3.name,aaa2.name),aaa1.name) AS P_ERP,		
		(aml.credit - aml.debit) B_ERP,
		am.name AS boeking_ERP
		--, LOWER(REPLACE(REPLACE(REPLACE(REPLACE(aml.name,';',','),chr(10),' '),chr(13), ' '),' ','')) filter_str
	--SELECT LOWER(REPLACE(REPLACE(REPLACE(REPLACE(aml.name,';',','),chr(10),' '),chr(13), ' '),' ',''))
	FROM myvar v, account_move am
		INNER JOIN account_move_line aml ON aml.move_id = am.id
		INNER JOIN account_account aa ON aa.id = aml.account_id
		LEFT OUTER JOIN res_partner p ON p.id = aml.partner_id
		LEFT OUTER JOIN account_analytic_account aaa1 ON aml.analytic_dimension_1_id = aaa1.id
		LEFT OUTER JOIN account_analytic_account aaa2 ON aml.analytic_dimension_2_id = aaa2.id
		LEFT OUTER JOIN account_analytic_account aaa3 ON aml.analytic_dimension_3_id = aaa3.id
		JOIN res_company rc ON aml.company_id = rc.id 
		JOIN res_country c ON p.country_id = c.id
		LEFT OUTER JOIN res_country_city_street ccs ON p.street_id = ccs.id
		LEFT OUTER JOIN res_country_city cc ON p.zip_id = cc.id
		LEFT OUTER JOIN res_partner_title pt ON p.title = pt.id
		--afdeling vs afdeling eigen keuze
		LEFT OUTER JOIN res_partner a ON p.department_id = a.id
		LEFT OUTER JOIN res_partner a2 ON p.department_choice_id = a2.id
		--link naar partner		
		LEFT OUTER JOIN res_partner a5 ON p.relation_partner_id = a5.id
	--WHERE p.id = 336973
	WHERE (aa.code = '732100' OR  aa.code = '732000')
		AND aml.date BETWEEN v.startdatum AND v.einddatum
		--AND aml.name LIKE '%196532%'
		--AND (p.active = 't' OR (p.active = 'f' AND COALESCE(p.deceased,'f') = 't'))	--van de inactieven enkele de overleden contacten meenemen
		AND (LOWER(REPLACE(REPLACE(REPLACE(REPLACE(aml.name,';',','),chr(10),''),chr(13), ''),chr(32), '')) LIKE v.filter_str1
			OR LOWER(REPLACE(REPLACE(REPLACE(REPLACE(aml.name,';',','),chr(10),''),chr(13), ''),chr(32), '')) LIKE v.filter_str2
			OR LOWER(REPLACE(REPLACE(REPLACE(REPLACE(aml.name,';',','),chr(10),''),chr(13), ''),chr(32), '')) LIKE v.filter_str3)
		--AND p.id = v.testID
	ORDER BY aml.date);
--SELECT * FROM _AV_temp_GIFTEN --WHERE t_erp LIKE '%196696%' AND NOT(t_erp LIKE 'p%');	
--SELECT COUNT(ID_ERP) FROM _AV_temp_GIFTEN;
-----------------------------------------------------------
-- T_ERP uit "description" halen
--------------------------------
UPDATE _AV_temp_GIFTEN g
SET T_ERP = REPLACE(REPLACE(REPLACE(LOWER(g.T_ERP),' ',''),v.vervang_str1,''),'koalect','')
FROM myvar v;
UPDATE _AV_temp_GIFTEN g
SET T_ERP = REPLACE(REPLACE(REPLACE(LOWER(g.T_ERP),' ',''),v.vervang_str2,''),'koalect','')
FROM myvar v;
UPDATE _AV_temp_GIFTEN g
SET T_ERP = REPLACE(REPLACE(REPLACE(LOWER(g.T_ERP),' ',''),v.vervang_str3,''),'koalect','')
FROM myvar v;
--=========================================================
-- controle data samenstellen
-- - [actie_id] en [actie_code] in comment zetten voor donations
-----------------------------
SELECT "Date"::date, check_t + check_n + check_k + check_p + check_b AS check_sum, check_t, check_n, check_k, check_p, check_b,
	id_erp, boeking_erp, opmerking, rechtzetting,
	transaction_id, t_erp, naam, n_erp, kostenplaats, k_erp, projectnaam, p_erp, bedrag, b_erp,
	/*actie_id, actie_code,*/ id_erp, street, nr, bus, pc, gemeente, email -- [actie_id] en [actie_code] in comment zetten voor donations
FROM	(SELECT "Date"::date, check_sum,
		CASE WHEN transaction_id::text = t_erp THEN 0 ELSE 1 END AS check_t,
		CASE WHEN LOWER(firstname)||' '||LOWER(lastname) = LOWER(n_erp) THEN 0 ELSE 1 END AS check_n,
		CASE WHEN kostenplaats = k_erp THEN 0 ELSE 1 END AS check_k,
		CASE WHEN projectnaam = p_erp THEN 0 ELSE 1 END AS check_p,
		CASE WHEN bedrag = b_erp THEN 0 ELSE 1 END as check_b,
		transaction_id, t_erp, firstname||' '||lastname naam, n_erp, kostenplaats, k_erp, projectnaam, p_erp, bedrag, b_erp, 
		boeking_erp, opmerking, rechtzetting,
		/*actie_id, actie_code,*/ id_erp, street, nr, bus, pc, gemeente, email -- [actie_id] en [actie_code] in comment zetten voor donations
	FROM	(
		SELECT null check_sum, null check_t, null check_n, null check_k, null check_p, null check_b, null opmerking, null rechtzetting,
			mk.transaction_id, g.t_erp, mk.firstname, mk.lastname, g.n_erp,  mk.kostenplaats, g.k_erp, mk.projectnaam, g.p_erp, REPLACE(mk.bedrag,',','.')::numeric bedrag, g.b_erp, g.boeking_erp,
			g.id_erp, mk.street, mk.nr, mk.bus, mk.pc, mk.gemeente, mk.email, mk."Date"::date/*, mk.actie_id, mk.actie_code*/ -- [actie_id] en [actie_code] in comment zetten voor donations
		FROM myvar v, _AV_temp_GIFTEN g
			FULL OUTER JOIN marketing._m_so_koalect mk ON mk.transaction_id::text = g.T_ERP
		WHERE /*NOT(g.t_erp LIKE 'p%') AND*/ mk.platform = v.koalect_platform
		) SQ1
	) SQ2


/*
SELECT mk.transaction_id, g.t_erp, mk.firstname, mk.lastname, g.n_erp,  mk.kostenplaats, g.k_erp, mk.projectnaam, g.p_erp, REPLACE(mk.bedrag,',','.')::numeric bedrag, g.b_erp, g.boeking_erp,
			g.id_erp, mk.street, mk.nr, mk.bus, mk.pc, mk.gemeente, mk.email, mk."Date"::date
FROM _AV_temp_GIFTEN g
	FULL OUTER JOIN marketing._m_so_koalect mk ON mk.transaction_id::text = g.T_ERP	
WHERE NOT(g.t_erp LIKE 'p%') AND mk.platform = 'expeditie'
*/
