--SELECT * FROM res_users u WHERE u.login LIKE 'linsay%' -- 513
--SET VARIABLES
DROP TABLE IF EXISTS _AV_myvar;
CREATE TEMP TABLE _AV_myvar 
	(logdatum DATE);
INSERT INTO _AV_myvar VALUES(now()::date);
/*
DROP TABLE IF EXISTS marketing._temp_logcounter;
CREATE TABLE marketing._temp_logcounter 
	(date DATE, 
	 login TEXT,
	 tbl TEXT,
	 counter integer,
	 _type text
	 );
SELECT * FROM marketing._temp_logcounter lc WHERE lc.tbl = 'total'  AND lc.date = now()::date ORDER by lc.login, lc.date;
SELECT * FROM marketing._temp_logcounter lc WHERE lc.date = now()::date;
SELECT * FROM marketing._temp_logcounter lc WHERE lc.tbl = 'total' ORDER BY lc.date DESC, lc.login, lc.tbl;
SELECT MAX(lc.date) FROM marketing._temp_logcounter lc
SELECT DISTINCT lc.date FROM marketing._temp_logcounter lc ORDER BY lc.date DESC;
-- DELETE FROM marketing._temp_logcounter lc WHERE lc.date = now()::date;
*/
-- res_partner; create
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'res_partner', COUNT(a.id), 'create' 
	FROM _AV_myvar v, res_partner a 
		JOIN res_users u ON u.id = a.create_uid
	WHERE a.create_uid IN (186,487,432,513,260,315,292) AND a.create_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- res_partner; modify
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'res_partner', COUNT(a.id), 'modify' 
	FROM _AV_myvar v, res_partner a 
		JOIN res_users u ON u.id = a.write_uid
	WHERE a.write_uid IN (186,487,432,513,260,315,292) AND a.write_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- membership_membership_line; create
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'membership_membership_line', COUNT(a.id), 'create' 
	FROM _AV_myvar v, membership_membership_line a
		JOIN res_users u ON u.id = a.create_uid
	WHERE a.create_uid IN (186,487,432,513,260,315,292) AND a.create_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- membership_membership_line; modify
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'membership_membership_line', COUNT(a.id), 'modify' 
	FROM _AV_myvar v, membership_membership_line a
		JOIN res_users u ON u.id = a.write_uid
	WHERE a.write_uid IN (186,487,432,513,260,315,292) AND a.write_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- account_invoice_line; create
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'account_invoice_line', COUNT(a.id), 'create' 
	FROM _AV_myvar v, account_invoice_line a
		JOIN res_users u ON u.id = a.create_uid
	WHERE a.create_uid IN (186,487,432,513,260,315,292) AND a.create_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- account_invoice_line; modify
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'account_invoice_line', COUNT(a.id), 'modify' 
	FROM _AV_myvar v, account_invoice_line a
		JOIN res_users u ON u.id = a.write_uid
	WHERE a.write_uid IN (186,487,432,513,260,315,292) AND a.write_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- res_crm_marketing_contact_history; create
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'res_crm_marketing_contact_history', COUNT(a.id), 'create' 
	FROM _AV_myvar v, res_crm_marketing_contact_history a
		JOIN res_users u ON u.id = a.create_uid
	WHERE a.create_uid IN (186,487,432,513,260,315,292) AND a.create_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- res_crm_marketing_contact_history; modify
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'res_crm_marketing_contact_history', COUNT(a.id), 'modify' 
	FROM _AV_myvar v, res_crm_marketing_contact_history a
		JOIN res_users u ON u.id = a.write_uid
	WHERE a.write_uid IN (186,487,432,513,260,315,292) AND a.write_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- res_crm_marketing_extra_info; create
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'res_crm_marketing_extra_info', COUNT(a.id), 'create' 
	FROM _AV_myvar v, res_crm_marketing_extra_info a
		JOIN res_users u ON u.id = a.create_uid
	WHERE a.create_uid IN (186,487,432,513,260,315,292) AND a.create_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);
-- res_crm_marketing_extra_info; modify
INSERT INTO marketing._temp_logcounter (
	SELECT v.logdatum, u.login, 'res_crm_marketing_extra_info', COUNT(a.id), 'modify' 
	FROM _AV_myvar v, res_crm_marketing_extra_info a
		JOIN res_users u ON u.id = a.write_uid
	WHERE a.write_uid IN (186,487,432,513,260,315,292) AND a.write_date::date = v.logdatum
	GROUP BY u.login, v.logdatum);	
-- totaal
INSERT INTO marketing._temp_logcounter (
	SELECT date, login, 'total', sum(counter), ''
	FROM _AV_myvar v, marketing._temp_logcounter
	WHERE date = v.logdatum
	GROUP BY date, login);
	
