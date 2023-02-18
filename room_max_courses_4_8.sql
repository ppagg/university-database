-- FUNCTION: public.room_max_courses_4_8()

-- DROP FUNCTION IF EXISTS public.room_max_courses_4_8();

CREATE OR REPLACE FUNCTION public.room_max_courses_4_8(
	)
    RETURNS TABLE(room_id integer) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$

	SELECT		A.room_id
	FROM		"LearningActivity" A
	GROUP BY	A.room_id
	HAVING		COUNT(DISTINCT A.course_code)	>=	ALL(SELECT COUNT(DISTINCT A.course_code)
													FROM "LearningActivity" A
													GROUP BY A.room_id)

$BODY$;

ALTER FUNCTION public.room_max_courses_4_8()
    OWNER TO postgres;
