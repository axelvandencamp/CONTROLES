--------------------------------------------------------
-- aangemaakt: 04/06/2025
--------------------------------------------------------
DROP TABLE IF EXISTS av_myvar;
SELECT 
	'2025-01-01'::date AS startdatum
INTO TEMP TABLE av_myvar;
SELECT * FROM av_myvar;
--------------------------------------------------------
SELECT p.id partner_id, p.membership_nbr lidnummer, 'prioriteit' prioriteit,
	/*sq3.mei_id,*/ COALESCE(sq3.mcf_name,'') fase, COALESCE(sq3.mei_info,'') info, sq3.r aantal, sq3.mch_date datum,
	p.name, p.membership_state lidmaatschap_status, sq3.sm2_last_debit_date, sq3.sm2_state mandaat_status,
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
FROM av_myvar v,
	res_partner p
    --land, straat, gemeente info
    JOIN res_country c ON p.country_id = c.id
    LEFT OUTER JOIN res_country_city_street ccs ON p.street_id = ccs.id
    LEFT OUTER JOIN res_country_city cc ON p.zip_id = cc.id
     
	
	

	JOIN 
	
	
		(SELECT p.id partner_id, p.membership_nbr lidnummer, 
			sq2.mei_id, sq2.sq1_partner_id, sq2.mcf_name, sq2.mei_info, COALESCE(sq2.r,0) r, sq2.login, sq2.mch_date,
			sm.pb_partner_id, sm.pb_id, sm.sm2_id, sm.sm2_state, sm.sm2_last_debit_date
		FROM av_myvar v, res_partner p
			--de meest recente mandaat lijn ophalen
			--enkel waar die geannuleerd blijkt
			JOIN (SELECT pb.id pb_id, pb.partner_id pb_partner_id, sm2.id sm2_id, sm2.state sm2_state, sm2.last_debit_date sm2_last_debit_date 
					FROM av_myvar v, res_partner_bank pb 
						JOIN (SELECT MAX(sm1.id) sm1_id, sm1.partner_bank_id FROM av_myvar v, sdd_mandate sm1 WHERE sm1.last_debit_date > v.startdatum GROUP BY sm1.partner_bank_id) sm ON sm.partner_bank_id = pb.id 
						JOIN sdd_mandate sm2 ON sm2.id = sm.sm1_id				
					WHERE sm2.state = 'cancel' AND sm2.last_debit_date > v.startdatum) sm ON pb_partner_id = p.id	
			-- 
			LEFT OUTER JOIN 
				--selectie alle crm_marketing toevoegingen voor "opvolging geannuleerd mandaat" na een betaalde datum
				(SELECT sq1.mei_id, sq1.partner_id sq1_partner_id, mcf.name mcf_name, mei.info mei_info, sq1.r, u.login, mch.datetime::date mch_date
				FROM
					(SELECT sq4.partner_id, max(sq4.id) mei_id, max(sq4.r) r FROM
					(SELECT p.id partner_id, mei.id, --MAX(mei.id) mei_id,
							ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY mei.datetime ASC) AS r
					FROM av_myvar v, res_partner p
						JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
						JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
						JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
					WHERE mcf.id = 33 AND mch.datetime::date > v.startdatum) sq4 --WHERE sq4.partner_id = 291863
					GROUP BY sq4.partner_id) sq1
					
					JOIN res_crm_marketing_extra_info mei ON mei.id = sq1.mei_id
					JOIN res_crm_marketing_contact_history mch ON mch.history_id = mei.info_id AND mch.datetime::date = mei.datetime::date
					JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
					JOIN res_users u ON u.id = mei.create_uid) sq2 ON sq2.sq1_partner_id = p.id
		) sq3 ON sq3.partner_id = p.id


		WHERE NOT(p.membership_state IN ('paid','free','old')) --AND p.id = 291863-- filtert ook reeds verwerkten uit die ondertussen paid/old staan; die willen we wel zien!!
