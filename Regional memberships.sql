--------------------------------
--CASE STUDY #1: Rocky Mountain Region Recreation Membership--
--------------------------------

--Author: Jordan Willi
--Date: 111/15/2022
--Tool used: MySQL Workbench

CREATE SCHEMA nmra;

SELECT * 
FROM nmra.divisionsms;

SELECT * 
FROM nmra.membership_codesms;

SELECT *
FROM nmra.33_quarterlyrosterreport8ms
LIMIT 5;

SELECT COUNT(*)
FROM nmra.33_quarterlyrosterreport8ms;

--View each division to clense data
SELECT id,
	concat(title, ' ', fname, ' ', lname) AS 'Full_Name',
    concat(address1, ',', address2, ',', city, ',', state, ',', zip) AS 'Address',
    joined,
    expires
FROM `nmra`.`33_quarterlyrosterreport8ms`
WHERE division = '5'
ORDER BY lname ASC, fname ASC;

--Perform Joins
SELECT id,
	concat(title, ' ', fname, ' ', lname) AS 'Full_Name',
    concat(address1, ',', address2, ',', city, ',', state, ',', zip) AS 'Address',
    joined,
    expires,
    division,
    meaning
FROM 33_quarterlyrosterreport8ms qr
	LEFT JOIN divisionsms d
		ON qr.div_no = d.div_no
	LEFT JOIN membership_codesms mc
		ON qr.memtype = mc.memtype
ORDER BY division, lname ASC, fname ASC;

SELECT id,
	concat(title, ' ', fname, ' ', lname) AS 'Full_Name',
    concat(address1, ',', address2, ',', city, ',', state, ',', zip) AS 'Address',
    joined,
    expires,
    division,
    meaning AS 'Member_Type'
FROM 33_quarterlyrosterreport8ms qr
	LEFT JOIN divisionsms d
		ON qr.div_no = d.div_no
	LEFT JOIN membership_codesms mc
		ON qr.memtype = mc.memtype
ORDER BY division, lname ASC, fname ASC;

SELECT id,
	concat(title, ' ', fname, ' ', lname, ' ', suffix) AS 'Full_Name',
    concat(address1, address2, ' ', city, ' ', state, ',', ' ', zip) AS 'Address',
    joined,
    expires,
    division,
    meaning AS 'Member_Type'
FROM 33_quarterlyrosterreport8ms qr
	LEFT JOIN divisionsms d
		ON qr.div_no = d.div_no
	LEFT JOIN membership_codesms mc
		ON qr.memtype = mc.memtype
ORDER BY division, meaning ASC, lname ASC, fname ASC;

--Update division with missing information

UPDATE divisionsms
SET Superintendent = 'David Kirkland'
WHERE Div_No = 4;

UPDATE divisionsms
SET Superintendent = 'Andy Chandler'
WHERE Div_No = 9;

INSERT INTO divisionsms
VALUES ('Georgia Mountains', 17, "TBD");

SELECT * FROM nmra.divisionsms;

--Dig into member types and code to discover totals.  Also use rollup
SELECT IF(GROUPING(membership_codesms.memtype) = 1, "grand_total", membership_codesms.memtype) AS Member_Type,
	COUNT(ALL membership_codesms.memtype) AS Member_Total
FROM 33_quarterlyrosterreport8ms, membership_codesms
WHERE 33_quarterlyrosterreport8ms.memtype = membership_codesms.memtype
GROUP BY membership_codesms.memtype WITH ROLLUP;  

SELECT divisionsms.Div_No,
	IF(GROUPING(divisionsms.Division) = 1, "grand_total", divisionsms.Division) AS Division,
	COUNT(ALL 33_quarterlyrosterreport8ms.id) AS Member_Total
FROM 33_quarterlyrosterreport8ms, divisionsms
WHERE 33_quarterlyrosterreport8ms.Div_No = divisionsms.Div_No
GROUP BY divisionsms.Division WITH ROLLUP;     

SELECT Div_No,
	IF(GROUPING(33_quarterlyrosterreport8ms.memtype) = 1, "grand_total", 33_quarterlyrosterreport8ms.memtype) AS Member_Type,
	COUNT(ALL 33_quarterlyrosterreport8ms.memtype) AS Member_Total
FROM 33_quarterlyrosterreport8ms
WHERE Div_no = '5'
GROUP BY 33_quarterlyrosterreport8ms.memtype WITH ROLLUP;   

--Use Views to analyze each division
CREATE OR REPLACE VIEW Division_9_Report AS
	SELECT qr.id, qr.joined, qr.renewed, qr.expires, qr.regionexpires, qr.rerail, qr.lastpay, qr.fname, qr.lname, qr.address1, qr.address2, qr.city, qr.state, qr.zip, qr.plus4, d.division, qr.regionid, mc.meaning
FROM 33_quarterlyrosterreport8ms qr
	LEFT JOIN divisionsms d
		ON qr.div_no = d.div_no
	LEFT JOIN membership_codesms mc
		ON qr.memtype = mc.memtype
WHERE qr.div_no = 9;

SELECT id, joined, renewed, expires, regionexpires, rerail, lastpay,
    concat(fname, ' ', lname) AS 'Full_Name',
    concat(address1, ',', address2) AS 'Address',
	concat(city, ',', state, ',', zip, '-', plus4) AS 'City',
    division, regionid, meaning AS 'Member Type'
FROM division_9_report;

--Find those that need to be reminded of upcoming payment
CREATE OR REPLACE VIEW close_to_expire AS
SELECT qr.id, qr.joined, qr.renewed, qr.expires, qr.regionexpires, qr.rerail, qr.lastpay, qr.fname, qr.lname, qr.address1, qr.address2, qr.city, qr.state, qr.zip, qr.plus4, d.division, qr.regionid, mc.meaning,
STR_TO_DATE(expires, '%m/%d/%Y') AS expires_60
FROM 33_quarterlyrosterreport8ms qr
	LEFT JOIN divisionsms d
		ON qr.div_no = d.div_no
	LEFT JOIN membership_codesms mc
		ON qr.memtype = mc.memtype;

SELECT id, joined, renewed, expires, regionexpires, rerail, lastpay,
    concat(fname, ' ', lname) AS 'Full_Name',
    concat(address1, ',', address2) AS 'Address',
	concat(city, ',', state, ',', zip, '-', plus4) AS 'City',
    division, regionid, meaning AS 'Member Type'
FROM close_to_expire
WHERE expires_60 < DATE_ADD('2022-08-31', INTERVAL 60 day);



