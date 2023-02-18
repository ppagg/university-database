-- FUNCTION: public.prof_4_10(integer, integer)

-- DROP FUNCTION IF EXISTS public.prof_4_10(integer, integer);

CREATE OR REPLACE FUNCTION public.prof_4_10(
	min_c integer,
	max_c integer)
    RETURNS TABLE(amka integer) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	WITH prof AS	(SELECT	amka_prof1 AS amka, P.room_id
					FROM	"CourseRun" CR INNER JOIN "Participates" P ON CR.amka_prof1 = P.amka AND CR.course_code=P.course_code AND CR.serial_number=P.serial_number
							INNER JOIN "Room" R ON P.room_id=R.room_id
					WHERE	R.capacity>=MIN_C AND R.capacity<=MAX_C
							AND R.room_type = 'lecture_room'

					UNION
					
					SELECT	amka_prof2 AS amka, P.room_id
					FROM	"CourseRun" CR INNER JOIN "Participates" P ON CR.amka_prof2 = P.amka AND CR.course_code=P.course_code AND CR.serial_number=P.serial_number
							INNER JOIN "Room" R ON P.room_id=R.room_id
					WHERE	R.capacity>=MIN_C AND R.capacity<=MAX_C
							AND amka_prof2 IS NOT NULL
							AND R.room_type = 'lecture_room') 
	SELECT	DISTINCT amka
	FROM	prof S1
	WHERE	NOT EXISTS (SELECT	*
						FROM	(SELECT room_id FROM prof) P2
						WHERE	NOT EXISTS	(SELECT	* 
											FROM	prof S2
											WHERE	S1.amka = S2.amka and S2.room_id = P2.room_id));
$BODY$;

ALTER FUNCTION public.prof_4_10(integer, integer)
    OWNER TO postgres;
