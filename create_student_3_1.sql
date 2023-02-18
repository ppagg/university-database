-- FUNCTION: public.create_student_3_1(date, integer)

-- DROP FUNCTION IF EXISTS public.create_student_3_1(date, integer);

CREATE OR REPLACE FUNCTION public.create_student_3_1(
	entry_date date,
	num integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	i			INTEGER	:= 0;
	curr_amka	INTEGER;
	year		VARCHAR;
	t_name		"Name"%ROWTYPE;
	t_student	"Student"%ROWTYPE;
	max_am		VARCHAR;
	new_am		INTEGER;
	max_email	INTEGER;
	new_email	TEXT;
BEGIN
--if year of entry exists, then find current AAAAAA (rightmost 6 digits of amka). Starting AAAAAA will be AAAAAA + 1 and for every new student it will be +1
--if year of entry does NOT exist, then starting AAAAAA (rightmost 6 digits of amka) is 000000 and for every new student it will be +1

	WHILE i < num LOOP
		RAISE NOTICE 'The current value of i is %', i;
		-- for the amka, max(amka) + 1
		curr_amka := (SELECT MAX(amka) FROM "Student");
		t_student.amka := curr_amka + 1;
		
		-- for the name
		SELECT * INTO t_name FROM random_names(1);
		t_student.name := t_name.name;

		-- for the father's name
		t_student.father_name := (	SELECT name
									FROM "Name"
									WHERE sex = 'M'
									ORDER BY random() LIMIT 1);
		
		-- for the surname
		t_student.surname := (SELECT *  FROM adapt_surname((SELECT surname FROM random_surnames(1)), t_name.sex));

		-- for the am
		-- t_student.am := create_am(CAST (year AS INTEGER), new_am + i + 1);

		-- year is first 4 chars of argument entry date
		year := SUBSTR(CAST (entry_date AS VARCHAR), 1, 4);

		max_am := (SELECT max(am) FROM "Student" WHERE left(am, 4) = year);

		IF max_am IS NULL THEN
			new_am := 0;
		ELSE
			new_am := CAST (SUBSTR(max_am, 5) AS INTEGER);
		END IF;
		t_student.am := (SELECT * FROM create_am(CAST (year AS INTEGER), new_am+1));
		
		--for the email
		-- RAISE NOTICE '1new_email=%',new_email;
		new_email := (SELECT max(SUBSTR(email, 6, 6 )) FROM "Student");
		-- RAISE NOTICE '2new_email=%',new_email;
		-- RAISE NOTICE '1max_email=%',max_email;
		max_email := (CAST (new_email AS INTEGER));
		-- RAISE NOTICE '2max_email=%',max_email;
		t_student.email := CONCAT(CONCAT(CONCAT('s', year), lpad(CAST ((max_email+1) AS VARCHAR), 6, '0')), '@isc.tuc.gr');

		-- for the entry date, directly from the argument
		t_student.entry_date := entry_date; --from the argument
		
		INSERT INTO "Student" VALUES (t_student.*);
		i := i + 1;
	END LOOP;

END;
$BODY$;

ALTER FUNCTION public.create_student_3_1(date, integer)
    OWNER TO postgres;
