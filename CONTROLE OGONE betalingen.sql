--=================================================================
--WERKWIJZE:
-- eerst upload file klaarmaken (download van website INGENICO); overtollige lijnen verwijderen
-- vervolgens conversie uitvoeren naar UTF-8 .txt
--=================================================================
--CREATE TEMP TABLE
/*
DROP TABLE IF EXISTS _AV_temp_ogone;

CREATE TABLE _AV_temp_ogone 
(Id TEXT,
 REF TEXT,
 ORDER_ TEXT,
 STATUS TEXT,
 LIB TEXT,
 ACCEPT TEXT,
 NCID TEXT,
 NCSTER TEXT,
 PAYDATE TEXT,
 CIE TEXT,
 NAME TEXT,
 COUNTRY TEXT,
 TOTAL TEXT,
 CUR TEXT,
 SHIP TEXT,
 TAX TEXT,
 METHOD TEXT,
 BRAND TEXT,
 CARD TEXT,
 UID TEXT,
 STRUCT TEXT,
 FILEID TEXT,
 dummy TEXT,
 DESC_ TEXT,
 dummy2 TEXT
);

SELECT * FROM _AV_temp_ogone --WHERE bron_id = 4778;
*/
--=======================================================================
-- voorgestelde verbetering:
-- - rond het jaareinde staan lidmaatschappen met gemiste betalingen voor het volgend jaar mogelijk nog op "betaald lid"
-- - hierdoor glipt de gemiste betaling door de mazen van het net
-- - beter logica uitwerken waar de effectieve factuur wordt gechecked ipv de lidmaatschapsstatus
--=======================================================================
SELECT REPLACE(SUBSTRING(o.REF FROM 4 FOR 7),'/','') idfromstruct, o.REF, o.LIB resultaat, o.paydate, o.method, o.brand, p.id, p.membership_state, p.active
FROM _AV_temp_ogone o
	 LEFT OUTER JOIN res_partner p ON p.id::text = REPLACE(SUBSTRING(o.REF FROM 4 FOR 7),'/','')
WHERE p.id IN (SELECT id --, active, membership_nbr, membership_start, membership_end, membership_state
	FROM res_partner 
	WHERE id::text IN (SELECT REPLACE(SUBSTRING(o.REF FROM 4 FOR 7),'/','') idfromstruct
			FROM _AV_temp_ogone o
			LEFT OUTER JOIN res_partner p ON p.id::text = REPLACE(SUBSTRING(o.REF FROM 4 FOR 7),'/',''))
	AND membership_state <> 'paid'
	)
ORDER BY o.paydate
