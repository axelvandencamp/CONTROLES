--------------------------------------------------------
-- aangemaakt: 04/06/2025
--------------------------------------------------------
DROP TABLE IF EXISTS av_myvar;
SELECT 
	'2025-01-01'::date AS startdatum
INTO TEMP TABLE av_myvar;
SELECT * FROM av_myvar;
--------------------------------------------------------
SELECT p.id, p.membership_nbr, 'prioriteit', 
	-- toevoegen voor opvolging reeds gebelden
	COALESCE(sq1.r,0) r, sq1.partner_id opv_partner_id, COALESCE(sq1.name,'') opv_type, COALESCE(sq1.info,'') opv_info, sq1.date opv_date, 
	p.name, p.membership_state, sm.sm_last_debit_date, sm.sm_state,
    COALESCE(COALESCE(p.phone_work,p.phone),'') telefoonnr,
    COALESCE(p.mobile,'') gsm,
    COALESCE(p.first_name,'') as voornaam,
    COALESCE(p.last_name,'') as achternaam,
    COALESCE(p.street2,'') huisnaam,
    CASE
        WHEN c.id = 21 AND p.crab_used = 'true' THEN COALESCE(ccs.name,'')
        ELSE COALESCE(p.street,'')
    END straat,
    CASE
        WHEN c.id = 21 AND p.crab_used = 'true' THEN COALESCE(p.street_nbr,'') ELSE ''
    END huisnummer, 
    COALESCE(p.street_bus,'') bus,
    CASE
        WHEN c.id = 21 AND p.crab_used = 'true' THEN COALESCE(cc.zip,'')
        ELSE COALESCE(p.zip,'')
    END postcode,
    CASE 
        WHEN c.id = 21 THEN COALESCE(cc.name,'') ELSE COALESCE(p.city,'') 
    END woonplaats,
    _crm_land(c.id) land,
    p.email,
    CASE
        WHEN p.address_state_id = 2 THEN 1 ELSE 0
    END adres_verkeerd,
    CASE
        WHEN COALESCE(p.opt_out_letter,'f') = 'f' THEN 0 ELSE 1
    END wenst_geen_post_van_NP,
    CASE
        WHEN COALESCE(p.opt_out,'f') = 'f' THEN 0 ELSE 1
    END wenst_geen_email_van_NP
    --, p.iets_te_verbergen nooit_contacteren
FROM av_myvar v, res_partner p
    --land, straat, gemeente info
    JOIN res_country c ON p.country_id = c.id
    LEFT OUTER JOIN res_country_city_street ccs ON p.street_id = ccs.id
    LEFT OUTER JOIN res_country_city cc ON p.zip_id = cc.id
    --bank/mandaat info
    --door bank aan mandaat te linken en enkel de mandaat info te nemen ontdubbeling veroorzaakt door meerdere bankrekening nummers
    JOIN (SELECT pb.id pb_id, pb.partner_id pb_partner_id, sm.id sm_id, sm.state sm_state, sm.last_debit_date sm_last_debit_date FROM res_partner_bank pb JOIN sdd_mandate sm ON sm.partner_bank_id = pb.id WHERE sm.state = 'cancel') sm ON pb_partner_id = p.id
	-- toevoegen voor opvolging reeds gebelden
	LEFT OUTER JOIN (SELECT DISTINCT p.id partner_id, mcf.name, mei.info, u.login, mch.datetime::date date,
						ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY mch.datetime ASC) AS r
				FROM av_myvar v, res_partner p
					JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
					JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
					JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
					JOIN res_users u ON u.id = mei.create_uid
				WHERE mcf.id = 33 AND mch.datetime::date > v.startdatum) sq1
				ON sq1.partner_id = p.id	
WHERE sm.sm_state = 'cancel' and sm.sm_last_debit_date > v.startdatum
    AND NOT(p.membership_state IN ('paid','free','old'))
    AND p.iets_te_verbergen = false -- AND p.opt_out AND p.opt_out_letter
ORDER BY p.id, sm.sm_last_debit_date, sq1.date DESC