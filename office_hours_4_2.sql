-- FUNCTION: public.office_hours_4_2()

-- DROP FUNCTION IF EXISTS public.office_hours_4_2();

CREATE OR REPLACE FUNCTION public.office_hours_4_2(
	)
    RETURNS TABLE(name character, surname character, course_title character, weekday character, start_time integer, end_time integer) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	(SELECT	P.name,
			P.surname,
			C.course_title,
			lr.weekday,
			lr.start_time,
			lr.end_time
	
	FROM	"CourseRun" CR
			INNER JOIN "Professor" P ON CR.amka_prof2=P.amka
			INNER JOIN "LearningActivity" lr ON (CR.course_code=lr.course_code AND CR.serial_number=lr.serial_number)
			INNER JOIN "Semester" S ON CR.semesterrunsin=S.semester_id
			INNER JOIN "Course" C ON CR.course_code=C.course_code

	WHERE lr.activity_type='office_hours' AND S.semester_status='present')
	
	UNION
	
	(SELECT	Prof.name,
			Prof.surname,
			C.course_title,
			weekday,
			start_time,
			end_time

	FROM	"Professor" AS Prof,
			"CourseRun" AS cRun,
			"LearningActivity" AS L,
			"Semester" AS Sem,
			"Course" AS C

	WHERE	Prof.amka = cRun.amka_prof1 AND L.course_code = cRun.course_code AND Sem.semester_id = cRun.semesterrunsin AND C.course_code = cRun.course_code)
	
	ORDER BY name, surname
	
$BODY$;

ALTER FUNCTION public.office_hours_4_2()
    OWNER TO postgres;
