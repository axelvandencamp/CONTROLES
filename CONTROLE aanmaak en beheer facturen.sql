--------------------------------------------------------------------
-- facturen aangemaakt per dag (TEST bij hernieuwingsfacturen klaarzetten)
--------------------------------------------------------------------
--SELECT pp.name_template, * 
SELECT i.partner_id, i.reference ogm, i.amount_total bedrag, i.state, i.create_date, i.membership_renewal--, i.*
--SELECT COUNT(DISTINCT p.id) aantal, MAX(i.create_date) date

FROM	account_invoice i
	--JOIN account_invoice_line il ON i.id = il.invoice_id
	JOIN res_partner p ON i.partner_id = p.id
	JOIN product_product pp ON p.membership_renewal_product_id = pp.id
	JOIN res_users u ON i.create_uid = u.id
WHERE 	i.create_date > '2021-10-25 12:42:00.00000' -- 9913
	--i.create_date > '2017-11-10 08:00:00.00000' --i.create_date > '2017-11-09 10:49:36.222473' - 77301; i.create_date > '2017-11-09 07:42:19.440333' - 70154; '2017-11-08 07:56:55.00000' - 68802; '2017-11-07 09:58:38.00000' - 55562; '2017-11-07 08:27:13.00000' - 42334; '2017-11-06 09:55:47.00000' - 41872; '2017-11-04 10:19:30.00000' - 38423; 
	AND i.membership_renewal --AND i.state = 'open'
	AND i.number LIKE '%LID21%'
	AND u.login = 'axel'
ORDER BY i.create_date	/*ASC*/ DESC

----------------------------------------------------------
-- eventuele dubbels opsporen (op basis van database ID --
----------------------------------------------------------
--/*

SELECT p_id, max(aantal) aantal, status  FROM
(
	SELECT p.id p_id, p.membership_state status,--u.login, i.create_date, i.id, , i.number
		ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY p.id asc) AS Aantal
	FROM account_invoice i
		JOIN res_partner p ON i.partner_id = p.id
		JOIN product_product pp ON p.membership_renewal_product_id = pp.id
		JOIN res_users u ON i.create_uid = u.id
	WHERE 	i.create_date > '2021-10-25 10:47:20.017366' 
		--AND i.number LIKE '%LID17%' AND i.membership_renewal
		--AND i.number LIKE 'GIFT/2017%'
		AND i.state = 'open'
		AND u.login = 'axel'
		
) x
WHERE x.aantal > 1
GROUP BY p_id, status
ORDER BY p_id DESC

--*/
--SELECT * FROM account_invoice  LIMIT 100
--SELECT * FROM account_invoice_line WHERE invoice_id = 357692 
--SELECT * FROM membership_membership_line LIMIT 100
--SELECT * FROM product_product WHERE id = 204 --LOWER(name_template) LIKE '%lid%' ORDER BY id
--SELECT * FROM product_template WHERE name = 'Gewoon lid' LIMIT 100
--SELECT * FROM res_users WHERE id = 260

--------------------------------------------
-- dubbels per database_id, factuurnummer --
--------------------------------------------
SELECT p.id, i.id, i.number, i.state, pp.name_template, ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY i.id desc) AS Aantal
FROM	account_invoice i
	JOIN account_invoice_line il ON i.id = il.invoice_id
	JOIN res_partner p ON i.partner_id = p.id
	JOIN product_product pp ON il.product_id = pp.id
WHERE p.id IN (

		SELECT DISTINCT(p_id)/*, max(aantal) aantal, status*/  FROM
		(
			SELECT i.partner_id p_id, i.id,--u.login, i.create_date, i.id, , i.number
				ROW_NUMBER() OVER(PARTITION BY i.partner_id ORDER BY i.id desc) AS Aantal
			FROM account_invoice i
				--JOIN res_partner p ON i.partner_id = p.id
				JOIN account_invoice_line il ON i.id = il.invoice_id
				JOIN product_product pp ON il.product_id = pp.id
				JOIN res_users u ON i.create_uid = u.id
			WHERE i.create_date::date > '2018-10-24 08:20:00.00000' AND i.number LIKE '%LID18%' AND i.membership_renewal
				AND i.state = 'open'
				AND u.login = 'axel'
				--AND i.partner_id IN (115022)
						
		) x
		WHERE x.aantal > 1
		--GROUP BY p_id, status, number	--ORDER BY p_id DESC
		) --Y
AND i.create_date::date >= '2016-11-28' and i.state = 'open'
ORDER BY p.id, i.id DESC
--==================================================================
--= = = = = = = = = = = = = = OPKUIS = = = = = = = = = = = = = = = =
--==================================================================
-------------------------------------------------------------------
-- ALLE FACTUREN VAN VORIG JAAR (op basis van factuur nummer LIDXX)
-- - mogen opgekuist worden
-------------------------------------------------------------------
SELECT i.id, i.partner_id, i.number, i.state, i.create_date::date, i.partner_id, pp.name_template--, '###', pp.*
FROM account_invoice i
	JOIN account_invoice_line il ON i.id = il.invoice_id
	JOIN product_product pp ON pp.id = il.product_id
WHERE i.state = 'open' AND i.number LIKE '%LID17%' AND i.membership_renewal
-------------------------------------------------------------------
-- FACTUREN AANGEMAAKT DIT JAAR MAAR NIET GEBRUIKT               --
-- - facturen aangemaakt dit jaar, maar er werd een nieuwe       --
--   factuur aangemaakt                                          --
-- - mogen opgekuist worden                                      --
-------------------------------------------------------------------
SELECT i.id, i.partner_id, i.number, i.state, i.create_date::date, i.partner_id, pp.name_template--, '###', pp.*
FROM account_invoice i
	JOIN account_invoice_line il ON i.id = il.invoice_id
	JOIN product_product pp ON pp.id = il.product_id
WHERE i.state = 'open' AND i.number LIKE '%LID18%' 
	AND i.create_date < '2018-10-24 08:20:00.00000' 
	AND i.partner_id IN (SELECT i.partner_id FROM account_invoice i WHERE i.create_date > '2018-10-24 08:20:00.00000' AND i.membership_renewal AND i.number LIKE '%LID18%')
-------------------------------------------------------------------
-- FACTUREN AANGEMAAKT DIT JAAR MAAR NIET GEBRUIKT               --
-- - facturen aangemaakt dit jaar voor hernieuwingsfacturen      --
--   maar er werd GEEN hernieuwings factuur aangemaakt           --
-- - moeten eerst gecontroleerd worden                           --
-------------------------------------------------------------------
SELECT i.id, i.partner_id, i.number, i.state, i.create_date::date, i.partner_id, pp.name_template, p.membership_state --, '###', pp.*
FROM account_invoice i
	JOIN account_invoice_line il ON i.id = il.invoice_id
	JOIN product_product pp ON pp.id = il.product_id
	JOIN res_partner p ON p.id = i.partner_id
WHERE 	--factuur status 'open' en een factuurnummer van het huidige jaar 'LIDXX'
	i.state = 'open' AND i.number LIKE '%LID18%' 
	--gecreëerd voor de start van de procedure voor de hernieuwingsfacturen
	AND i.create_date < '2018-10-24 08:20:00.00000' 
	--niet in de lijst met net geproduceerde hernieuwingsfacturen
	AND i.partner_id NOT IN (SELECT i.partner_id FROM account_invoice i WHERE i.create_date > '2018-10-24 08:20:00.00000' AND i.membership_renewal AND i.number LIKE '%LID18%')
	--actieve leden NIET 'gefactureerd lid' (hier zitten veel nieuw gedomicilieerden van de belactie tussen op het einde van het jaar)
	AND p.active AND NOT(p.membership_state = 'invoiced')
--===================================================================
--= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
--===================================================================



----
SELECT * FROM product_product pp WHERE LOWER(pp.name_template) LIKE '%lid%'
------------------------------------------------------
-- !!! voorwaarde toevoegen voor zelfde product !!! --
------------------------------------------------------
SELECT ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY p.id asc) AS Aantal, p.id, i.number, i.create_date, i.id, i.state, p.membership_state, p.membership_start, p.membership_stop, ml.id membership_line_id, pp.name_template 
--SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY p_id ORDER BYx p_id asc) AS Aantal, y.p_id--, i.number, i.create_date, i.id, i.state, p.membership_state, p.membership_start, p.membership_stop, ml.id membership_line_id 
FROM (
	SELECT DISTINCT p_id FROM (
		SELECT p.id p_id,
			ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY p.id asc) AS Aantal
		FROM account_invoice i
			JOIN res_partner p ON i.partner_id = p.id
		WHERE i.create_date::date >= '2015-12-08' AND i.number LIKE 'B-LID%' AND NOT(i.number LIKE 'B-LIDC%')
			--AND u.login = 'axel'
			--AND p.id = 17538
		) x
	WHERE Aantal > 1
	--WHERE p_id = 17538
	) y
	JOIN (SELECT * FROM account_invoice i WHERE i.create_date::date >= '2015-12-08' AND i.number LIKE 'B-LID%' AND NOT(i.number LIKE 'B-LIDC%')) i ON y.p_id = i.partner_id
	JOIN account_invoice_line il ON il.invoice_id = i.id
	JOIN res_partner p ON y.p_id = p.id
	LEFT OUTER JOIN membership_membership_line ml ON ml.account_invoice_line = il.id
	LEFT OUTER JOIN product_product pp ON pp.id = ml.membership_id	
WHERE i.create_date::date >= '2015-12-08' AND i.number LIKE 'B-LID%' AND NOT(i.number LIKE 'B-LIDC%')	
ORDER BY p.id--, i.create_date

----------------------------------------------------------------
-- facturen zoeken zonder lidmaatschapsproduct
----------------------------------------------------------------
SELECT p.id, pp.name_template
SELECT DISTINCT(p.id)
FROM	account_invoice i
	--JOIN account_invoice_line il ON i.id = il.invoice_id
	JOIN res_partner p ON i.partner_id = p.id
	JOIN product_product pp ON p.membership_renewal_product_id = pp.id
WHERE	i.create_date > '2016-11-18 15:30:00.00000'
	AND NOT(LOWER(pp.name_template) LIKE '%lid%')
ORDER BY p.id	