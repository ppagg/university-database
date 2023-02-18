-- FUNCTION: public.teaches_4_1()

-- DROP FUNCTION IF EXISTS public.teaches_4_1();

CREATE OR REPLACE FUNCTION public.teaches_4_1(
	)
    RETURNS TABLE(name character, surname character, amka integer) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	(SELECT name,
			surname,
			amka
	
	FROM (	SELECT	name,
					surname,
					Prof.amka,
					room_id

			FROM	"Professor" AS Prof,
					"Participates" AS Part
			WHERE Prof.amka = Part.amka) AS X, "Room" R, "LearningActivity" lr

	WHERE X.room_id = R.room_id AND capacity>30 AND lr.room_id = X.room_id AND activity_type not IN ('office_hours'))

	UNION

	(SELECT name,
			surname,
			amka

	 FROM (	SELECT	name,
	 				surname,
	 				L.amka,
	 				room_id 
			FROM "LabStaff" AS L, "Participates" AS Part
			WHERE L.amka = Part.amka) AS X, "Room" R, "LearningActivity" lr

	 WHERE X.room_id = R.room_id AND capacity>30 AND lr.room_id = X.room_id AND activity_type not IN ('office_hours'));
	
$BODY$;

ALTER FUNCTION public.teaches_4_1()
    OWNER TO postgres;
