USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_pemerintah', 'Pemerintah', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_pemerintah', 'Pemerintah', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_pemerintah', 'Pemerintah', 1)
;


INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('pemerintah',0,'staff','Staff',20,'{}','{}'),
	('pemerintah',1,'kadis','Kadis',40,'{}','{}'),
	('pemerintah',2,'sekda','Sekda',60,'{}','{}'),
	('pemerintah',3,'wali','Walikota',80,'{}','{}')
;

INSERT INTO `jobs` (name, label) VALUES
	('pemerintah','Pemerintah Kota')
;
