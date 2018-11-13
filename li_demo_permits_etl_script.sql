SET search_path = philly_lead, public;

--DROP table opa_account;
CREATE TABLE opa_account
(
  opa_account_key	serial PRIMARY KEY,
  li_demo_gid		integer,
  opa_account_num	varchar(9),
  ownername		varchar(57),
  address		varchar(35),
  unit			varchar(3),
  zip			varchar(10)
);

INSERT INTO opa_account (li_demo_gid, opa_account_num, ownername, address, unit, zip)
(
  SELECT gid, opa_accoun, ownername, address, unit, zip
  FROM li_demolitions
);

CREATE TABLE record_type
(
  record_type_id	serial PRIMARY KEY,
  record_type		varchar(14)
);

INSERT INTO record_type (record_type)
(
  SELECT DISTINCT record_typ
  FROM li_demolitions
);

CREATE TABLE type_of_work
(
  type_of_work_id	serial PRIMARY KEY,
  type_of_work		varchar(6)
);

INSERT INTO type_of_work (type_of_work)
(
  SELECT DISTINCT typeofwork
  FROM li_demolitions
);

CREATE TABLE status
(
  status_id		serial PRIMARY KEY,
  status		varchar(9)
);

INSERT INTO status (status)
(
  SELECT DISTINCT status
  FROM li_demolitions
);

CREATE TABLE applicant_capacity
(
  applicant_capacity_id	serial PRIMARY KEY,
  applicant_capacity	varchar(8)
);

INSERT INTO applicant_capacity (applicant_capacity)
(
  SELECT DISTINCT applicantc
  FROM li_demolitions
);

--DROP TABLE contractor
CREATE TABLE contractor (
  contractorid	serial PRIMARY KEY,
  name		varchar(30),
  type		varchar(25),
  address1	varchar(36),
  address2	varchar(27),
  city		varchar(17),
  state		varchar(2),
  zip		varchar(10)
);

INSERT INTO contractor (name, type, address1, address2, city, state, zip)
(
  SELECT DISTINCT contractor, contract_1, contract_2, contract_3,
  contract_4, contract_5, contract_6
  FROM li_demolitions
);

--DROP TABLE li_demolitions_norm;
--contractorname, type, and address1, opa_account_num, opa_ownername,
--opa_address will all be dropped after contractorid and opa_account_key
--are populated
CREATE TABLE li_demolitions_norm (
  gid			integer PRIMARY KEY,
  geom			geometry(MultiPoint,4326),
  objectid		integer,
  opa_account_key	integer REFERENCES opa_account (opa_account_key),
  censustract		varchar(3),
  organization_name	varchar(30),
  caseorpermitnumber	varchar(6),
  record_type_id	integer REFERENCES record_type (record_type_id),
  type_of_work_id	integer REFERENCES type_of_work (type_of_work_id),
  city_demo		varchar(3),
  completed_date	date,
  start_date		date,
  addresskey		varchar(6),
  permitstatus		varchar(1),
  status_id		integer REFERENCES status (status_id),
  applicant_capacity_id	integer REFERENCES applicant_capacity (applicant_capacity_id),
  primarycontact	varchar(70),
  contractorid		integer REFERENCES contractor (contractorid),
  mostrecentinsp	date,
  geocode_x		numeric,
  geocode_y		numeric,
  opa_account_num	varchar(9),
  opa_ownername		varchar(57),
  opa_address		varchar(35),
  contractorname	varchar(30),
  contractortype	varchar(25),
  contractoraddress1	varchar(36)
);

INSERT INTO li_demolitions_norm
(
  gid, geom, objectid, censustract, organization_name, caseorpermitnumber,
  city_demo, completed_date, start_date, addresskey, permitstatus, primarycontact,
  mostrecentinsp, geocode_x, geocode_y, opa_account_num, opa_ownername, opa_address,
  contractorname, contractortype, contractoraddress1, record_type_id, type_of_work_id,
  status_id, applicant_capacity_id
  )
(
SELECT gid, geom, objectid, censustrac, organizati, caseorperm, city_demo,
completed_, start_date, addresskey, permitstat, primarycon, mostrecent, geocode_x,
geocode_y, opa_accoun, ownername, address, contractor, contract_1, contract_2,
CASE
    WHEN record_typ = 'VIOLATION CASE' THEN 1
    WHEN record_typ = 'PERMIT' THEN 2
  END AS record_type_id,
  CASE
    WHEN typeofwork = 'FULL' THEN 1
    WHEN typeofwork = 'CASE' THEN 2
    WHEN typeofwork = 'COMDEM' THEN 3
    WHEN typeofwork = 'TANKRI' THEN 4
  END AS type_of_work_id,
  CASE
    WHEN status = 'ACTIVE' THEN 1
    WHEN status = 'COMPLETED' THEN 2
  END AS status_id,
  CASE
    WHEN applicantc = 'ATTORNEY' THEN 2
    WHEN applicantc = 'DSGNPROF' THEN 3
    WHEN applicantc = 'TENANT' THEN 4
    WHEN applicantc = 'PROF' THEN 5
    WHEN applicantc = 'APPL' THEN 6
    WHEN applicantc = 'CONTRCTR' THEN 7
    WHEN applicantc = 'OWNER' THEN 8
    WHEN applicantc = 'AGENT' THEN 9
    WHEN applicantc = 'BILLING' THEN 10
  END AS applicant_capacity_id
FROM li_demolitions
);

--populate foreign key from opa_account table
UPDATE li_demolitions_norm AS ldn
SET opa_account_key = oa.opa_account_key
FROM opa_account oa
WHERE ldn.opa_account_num = oa.opa_account_num
AND ldn.opa_ownername = oa.ownername
AND ldn.opa_address = oa.address
;

--populate foreign key from contractor table
UPDATE li_demolitions_norm AS ldn
SET contractorid = c.contractorid
FROM contractor c
WHERE ldn.contractorname = c.name
AND ldn.contractortype = c.type
AND ldn.contractoraddress1 = c.address1
;

-- remove extra contractor and opa columns. They were only necessary for the join
ALTER TABLE li_demolitions_norm
DROP COLUMN IF EXISTS contractorname,
DROP COLUMN IF EXISTS contractortype,
DROP COLUMN IF EXISTS contractoraddress1,
DROP COLUMN IF EXISTS opa_account_num,
DROP COLUMN IF EXISTS opa_ownername,
DROP COLUMN IF EXISTS opa_address
;