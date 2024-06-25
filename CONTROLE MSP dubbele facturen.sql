SELECT sq2.partner_id, sq2.jaar, sq3.r, sq2.max_r, sq3.name_template, sq3.status, sq3.datum_start,
	CASE WHEN COALESCE(sm.sm_id,0) > 0 THEN 1 ELSE 0 END DOMI
FROM
	(
	SELECT sq1.partner_id, sq1.jaar, MAX(sq1.r) max_r
	FROM
		(
		SELECT ml.id, ml.partner partner_id, EXTRACT(year FROM ml.date_to) jaar,
			ROW_NUMBER() OVER (PARTITION BY ml.partner, EXTRACT(year FROM ml.date_to) ORDER BY ml.id DESC) AS r
		FROM membership_membership_line ml
			JOIN res_users u ON u.id = ml.create_uid
		WHERE u.login = 'apiuser' --AND ml.partner = 20651
			AND ml.create_date::date >= '2024-02-27'
		) sq1
	WHERE sq1.jaar = '2024'
	GROUP BY sq1.partner_id, sq1.jaar
	) sq2
	JOIN
	(
	SELECT ml.id, ml.partner partner_id, ml.state status, ml.create_date::date datum_start, EXTRACT(year FROM ml.date_to) jaar,
		ROW_NUMBER() OVER (PARTITION BY ml.partner, EXTRACT(year FROM ml.date_to) ORDER BY ml.id DESC) AS r,
		pp.name_template
	FROM membership_membership_line ml
		JOIN res_users u ON u.id = ml.create_uid
		JOIN product_product pp ON pp.id = ml.membership_id
	WHERE u.login = 'apiuser' --AND ml.partner = 20651
		AND ml.create_date::date >= '2024-02-27'
	) sq3
	ON sq2.partner_id = sq3.partner_id
	LEFT OUTER JOIN (SELECT pb.id pb_id, pb.partner_id pb_partner_id, sm.id sm_id, sm.state sm_state FROM res_partner_bank pb JOIN sdd_mandate sm ON sm.partner_bank_id = pb.id WHERE sm.state = 'valid') sm ON pb_partner_id = sq3.partner_id
WHERE sq2.max_r > 1 
ORDER BY sq2.partner_id, sq3.r
	
