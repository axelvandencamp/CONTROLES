--SET VARIABLES
/*DROP TABLE IF EXISTS myvar;
SELECT 
	'19-221-285'::text AS uittreksel
INTO TEMP TABLE myvar;
SELECT * FROM myvar;*/

--SET VARIABLES
DROP TABLE IF EXISTS _AV_myvar;
CREATE TEMP TABLE _AV_myvar 
	(uittreksel TEXT);

INSERT INTO _AV_myvar VALUES('24-221-014');	--uittreksel
				
SELECT * FROM _AV_myvar;

--CREATE TEMP TABLE
DROP TABLE IF EXISTS tempControleQRYs;

CREATE TEMP TABLE tempControleQRYs (
	Uittreksel text,
	Type_Controle text,
	RekNr text,
	Rek text,
	RekCode text,
	Ref text,
	Amount numeric,
	VoucherId text,
	PartnerId integer,
	Info text);

--=====controle 0======--
INSERT INTO tempControleQRYs
	(SELECT var.uittreksel, '499010 Wachtrekening coda', s.name, a.name, a.code, al.ref, al.amount, al.voucher_id, v.partner_id, 
		'controle op lijnen met rekening [499010 Wachtrekening coda] moet vermoedelijk aangepast worden naar [000000 Te ontvangen facturen lidgelden]'
	FROM   _AV_myvar var, account_bank_statement s
		INNER JOIN account_bank_statement_line al ON s.id = al.statement_id
		INNER JOIN account_account a ON a.id = al.account_id
		LEFT OUTER JOIN account_voucher v ON v.id = al.voucher_id
	WHERE s.name = var.uittreksel
		--AND a.name like '%achtrekenin%'
		AND a.code = '499010');
--=====controle 1=====--
INSERT INTO tempControleQRYs
	(select var.uittreksel, 'controle qry1', '', a1.name, '', a2.ref, a2.amount, '', a2.partner_id, a2.note
	from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2
	join account_account a3 on (a2.account_id = a3.id)
	where a1.name = var.uittreksel
	  and a1.id = a2.statement_id
	  and a2.partner_id IS NULL
	  and a3.partner_mandatory = True);		
--=====controle 2=====--
INSERT INTO tempControleQRYs
	(select var.uittreksel, 'controle qry2', '', a1.name, '', a2.ref, a2.amount, '', a2.partner_id, 'dimensie(s) niet ingevuld'
	from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2
	where a1.name = var.uittreksel
	  and a1.id = a2.statement_id
	  and ((a2.analytic_dimension_1_id IS NULL and analytic_dimension_1_required = True)
	   or (a2.analytic_dimension_2_id IS NULL and analytic_dimension_2_required = True)
	   or (a2.analytic_dimension_3_id IS NULL and analytic_dimension_3_required = True)));
--=====controle qry3=====--
--meer dan 1 factuur
INSERT INTO tempControleQRYs
	(select var.uittreksel, 'controle qry3', '', '', '', '', NULL, '', partner_id, 'aantal: ' || nbr
	from _AV_myvar var, (select max(a2.partner_id) as partner_id, count(v2.move_line_id) as nbr
	from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2, account_voucher v1, account_voucher_line v2
	where a1.name = var.uittreksel
	  and a1.id = a2.statement_id
	  and a2.id = v1.statement_line_id
	  and v1.id = v2.voucher_id
	  and reconcile = True
	group by v2.move_line_id) as q
	where nbr > 1);  	

INSERT INTO tempControleQRYs
	(SELECT var.uittreksel, 'controle qry3b', '', '', '', '', NULL, '', SQ1.partner_id, 'ID +1: ' || SQ1.r
	FROM _AV_myvar var, 
		(SELECT al.partner_id, al.amount, ROW_NUMBER() OVER (PARTITION BY al.partner_id, al.amount ORDER BY al.partner_id DESC) as r
		FROM   _AV_myvar var, account_bank_statement s
			JOIN account_bank_statement_line al ON s.id = al.statement_id
		WHERE s.name = var.uittreksel
			AND al.state = 'draft'
			/*AND al.partner_id = 258088*/) SQ1
	WHERE SQ1.r > 1);
--=====controle qry4=====--
--reeds betaald; er staat toch nog een voucher
INSERT INTO tempControleQRYs
	(select var.uittreksel, 'controle qry4', a1.name, a2.note, '', a2.ref, a2.amount, '', a2.partner_id, 'reeds afgepunt'
	from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2, account_voucher v1, account_voucher_line v2, account_move_line m1
	where a1.name = var.uittreksel
	  and a1.id = a2.statement_id
	  and a2.id = v1.statement_line_id
	  and v1.id = v2.voucher_id
	  and m1.id = v2.move_line_id
	  and not(m1.reconcile_id IS NULL));
--=====controle qry5=====--
INSERT INTO tempControleQRYs
	(select var.uittreksel, 'controle qry5', a1.name, '', '', a2.ref, a2.amount, '', a2.partner_id, 'factuur heeft status: "betaald", "geannuleerd", "draft"'
	from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2, account_voucher v1, account_voucher_line v2, account_move_line m1, 
	account_move_line m2, account_invoice_line i1, account_invoice i2
	where a1.name = var.uittreksel
	  and a1.id = a2.statement_id
	  and a2.id = v1.statement_line_id
	  and v1.id = v2.voucher_id
	  and m1.id = v2.move_line_id
	  and m2.move_id = m1.move_id
	  and not(m2.invoice_line_id IS NULL)
	  and i1.id = m2.invoice_line_id
	  and i2.id = i1.invoice_id
	  and i2.state in ('paid','canceled','draft')); 	  
--=====controle qry6=====--
INSERT INTO tempControleQRYs
	(select var.uittreksel, 'controle qry6', a1.name, '', '', a2.ref, a2.amount, v2.move_line_ref_id, a2.partner_id, a2.note
	from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2, account_voucher v1, account_voucher_line v2
	where a1.name = var.uittreksel
	  and a1.id = a2.statement_id
	  and a2.id = v1.statement_line_id
	  and v1.id = v2.voucher_id
	  and v2.move_line_id IS NULL);
--=====controle qry7=====--
--verschillen in bedragen detecteren
INSERT INTO tempControleQRYs
	(select var.uittreksel, 'controle qry7', a1.name, a2.note, '', a2.ref, a2.amount, '', a2.partner_id, 'verschillen in bedragen detecteren'
	from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2, account_voucher v1
	where a1.name = var.uittreksel
	  and a1.id = a2.statement_id
	  and a2.id = v1.statement_line_id
	  and v1.amount <> a2.amount);	 
--=====controle qry8=====--
--opsporen van "write off" fout
--WIP
INSERT INTO tempControleQRYs
	(SELECT var.uittreksel, 'controle qry8', '', '', '', '', NULL, '', bsl.partner_id, 'Write-off: ipv write-off "open houden" gebruikten'
	FROM _AV_myvar var, account_bank_statement bs 
		JOIN account_bank_statement_line bsl ON bs.id = bsl.statement_id
		LEFT OUTER JOIN account_voucher av ON bsl.id = av.statement_line_id
	WHERE bs.name = var.uittreksel
		AND NOT(av.payment_option = 'without_writeoff'));
--=====controle qry9=====--
--som vd lijnen uit bankstatement (moet 0 zijn)
INSERT INTO tempControleQRYs
	(select var.uittreksel, 'controle qry9', '', '', '', '', sum(a2.amount), '', NULL, 'loop query [controle qry rekuittr verschil transactie vs CODA] om plaats van de verschillen op te sporen'
	from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2
	where a1.name = var.uittreksel
	  and a1.id = a2.statement_id
	GROUP BY var.uittreksel);
--=====resultaat controle=====--
SELECT * FROM tempControleQRYs ORDER BY partnerid;
--DELETE FROM tempControleQRYs;
--SELECT DISTINCT partnerid FROM tempControleQRYs

/*
SELECT * FROM account_move WHERE name = 'B-LID15-067193'
--====================================================--
--[controle qry rekuittr verschil transactie vs CODA]
--De volgende script geeft je een overzicht van alle bedragen uit de lijnen, gecombineerd met het bedrag uit het coda bestand. 
--Om hierin de verschillen te ontdekken, moet  je de som per partner nemen, en controleren of dit overeen komt met het bedrag uit het coda bestand.

select a2.partner_id, a2.amount bedrag_transactie, c1.t21_amount coda_bedrag
from _AV_myvar var, account_bank_statement a1, account_bank_statement_line a2, account_coda_lines2 c1
where a1.name = var.uittreksel
  and a2.statement_id = a1.id
  and a2.lines2_id = c1.id
  and a2.amount <> c1.t21_amount
order by a2.partner_id;
*/