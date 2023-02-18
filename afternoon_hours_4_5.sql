-- FUNCTION: public.afternoon_hours_4_5()

-- DROP FUNCTION IF EXISTS public.afternoon_hours_4_5();

CREATE OR REPLACE FUNCTION public.afternoon_hours_4_5(
	)
    RETURNS TABLE(course_code character, afternoon_hours boolean) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	SELECT C.course_code,	CASE
								WHEN lr.start_time >= 16 AND lr.end_time<= 20 THEN true
								ELSE false
							END
	FROM	"LearningActivity" lr INNER JOIN "Course" C ON lr.course_code=C.course_code
	WHERE	C.obligatory

$BODY$;

ALTER FUNCTION public.afternoon_hours_4_5()
    OWNER TO postgres;
