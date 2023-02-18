-- FUNCTION: public.max_grade_4_3(integer, character varying)

-- DROP FUNCTION IF EXISTS public.max_grade_4_3(integer, character varying);

CREATE OR REPLACE FUNCTION public.max_grade_4_3(
	semester integer,
	grade_type character varying)
    RETURNS TABLE(course_code character, grade numeric) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN

	IF	grade_type = 'lab' THEN
	RETURN QUERY
		SELECT	cRun.course_code,
				max(lab_grade) AS max_grade
		
		FROM	"Register" AS Reg,
				"CourseRun" AS cRun
		WHERE	cRun.semesterrunsin = semester AND cRun.course_code = Reg.course_code AND cRun.serial_number = Reg.serial_number AND lab_grade IS not null
		
		GROUP BY cRun.course_code
		ORDER BY m DESC;
	
	ELSIF grade_type = 'exam' THEN
	RETURN QUERY
		SELECT	R.course_code,
				max(R.exam_grade) AS max_grade
		FROM	"CourseRun" CR
				INNER JOIN "Register" R on (CR.course_code=R.course_code AND CR.serial_number = R.serial_number)
		WHERE	semesterrunsin = semester AND R.exam_grade IS NOT NULL
		
		GROUP BY R.course_code
		ORDER BY R.course_code;
	
	ELSIF grade_type = 'final' THEN
	RETURN QUERY
		SELECT	cRun.course_code,
				max(final_grade) AS max_grade
		FROM	"Register" AS Reg, "CourseRun" AS cRun
		WHERE	cRun.semesterrunsin = semester AND cRun.course_code = Reg.course_code AND cRun.serial_number = Reg.serial_number AND final_grade IS not null
		
		GROUP BY cRun.course_code
		ORDER BY m DESC;
	
	END IF;
END;

$BODY$;

ALTER FUNCTION public.max_grade_4_3(integer, character varying)
    OWNER TO postgres;
