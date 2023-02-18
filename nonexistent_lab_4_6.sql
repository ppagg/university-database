-- FUNCTION: public.nonexistent_lab_4_6()

-- DROP FUNCTION IF EXISTS public.nonexistent_lab_4_6();

CREATE OR REPLACE FUNCTION public.nonexistent_lab_4_6(
	)
    RETURNS TABLE(course_code character, course_title character) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	SELECT	C.course_code,
			C.course_title

	FROM	"Semester" AS Sem,
			"CourseRun" AS cRun,
			"Course" C,
			"Room" R,
			"Participates" AS Part

	WHERE	Sem.semester_id = cRun.semesterrunsin AND
			C.course_code = cRun.course_code AND
			Part.serial_number=cRun.serial_number AND
			Part.course_code=cRun.course_code AND
			Part.room_id = R.room_id AND
			lab_hours>0 AND
			Sem.semester_status = 'present' AND
			R.room_type NOT IN ('lab_room') AND
			C.obligatory
			
$BODY$;

ALTER FUNCTION public.nonexistent_lab_4_6()
    OWNER TO postgres;
