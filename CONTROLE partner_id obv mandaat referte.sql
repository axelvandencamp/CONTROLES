DROP TABLE IF EXISTS myvar;
SELECT 
	'MGR53360'::text AS mandaat 
INTO TEMP TABLE myvar;
SELECT * FROM myvar;
------------------------------------------------------
SELECT sm.unique_mandate_reference, pb.bank_name, pb.owner_name, pb.partner_id
FROM myvar v, sdd_mandate sm 
	JOIN res_partner_bank pb ON sm.partner_bank_id = pb.id
WHERE sm.unique_mandate_reference = v.mandaat