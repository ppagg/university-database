-- FUNCTION: public.create_prof_3_1(date, integer)

-- DROP FUNCTION IF EXISTS public.create_prof_3_1(date, integer);

CREATE OR REPLACE FUNCTION public.create_prof_3_1(
	entry_date date,
	num_of_members integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	prof			RECORD;
	amka			INT;
	surname			CHAR(30);
	father_name		CHAR(30);
	labCode			INT;
	rank_type		rank_type;
	email_number	INT;
	email			VARCHAR;
	year			VARCHAR;
BEGIN

	FOR prof IN	(SELECT	N.name, S.surname, N.sex
				FROM random_names(num_of_members) N INNER JOIN random_surnames(num_of_members) S ON S.id = N.id)
	LOOP

		SELECT adapt_surname(prof.surname, prof.sex) INTO surname;

		SELECT max(P.amka) INTO amka
		FROM "Professor" AS P;

		SELECT	name INTO father_name
		FROM	"Name" AS N
		WHERE	N.sex = 'M'
		ORDER BY random()
		LIMIT 1;

		SELECT	lab_code INTO labCode
		FROM	"Lab" AS L
		ORDER BY random()
		LIMIT 1;

		SELECT	P.rank INTO rank_type 
		FROM	"Professor" AS P
		ORDER BY random()
		LIMIT 1;

		SELECT	MAX(CAST(SUBSTRING(P.email,7,5) AS INTEGER)) INTO email_number
		FROM	"Professor" AS P;

		RAISE NOTICE 'Max email: %', email_number;

		-- year is first 4 chars of argument entry date
		year := SUBSTR(CAST (entry_date AS VARCHAR), 1, 4);

		RAISE NOTICE 'Year: %', year;

		year := CONCAT(year, '0');

		RAISE NOTICE 'New year: %', year;

		email := CONCAT('p', year, CAST((email_number +1) AS VARCHAR), '@isc.tuc.gr');
		
		RAISE NOTICE 'Email: %', email;

		INSERT INTO "Professor" VALUES(amka+1, prof.name, father_name, surname, email, labCode, rank_type);

	END LOOP;

END;
$BODY$;

ALTER FUNCTION public.create_prof_3_1(date, integer)
    OWNER TO postgres;
