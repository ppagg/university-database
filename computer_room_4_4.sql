-- FUNCTION: public.computer_room_4_4()

-- DROP FUNCTION IF EXISTS public.computer_room_4_4();

CREATE OR REPLACE FUNCTION public.computer_room_4_4(
	)
    RETURNS TABLE(amka integer, entry_date double precision) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	SELECT	S.amka,
			EXTRACT(YEAR FROM entry_date)

	FROM	"Student" AS S,
			"Participates" AS Part,
			"Room" AS R,
			"Semester" AS Sem,
			"CourseRun" AS cRun,
			"Register" AS Reg

	WHERE	S.amka = Part.amka
			AND Part.room_id = R.room_id
			AND room_type = 'computer_room'
			AND Sem.semester_id = cRun.semesterrunsin
			AND Sem.semester_status = 'present'
			AND cRun.course_code = Reg.course_code
			AND cRun.serial_number = Reg.serial_number
			AND Reg.amka = S.amka
			AND Reg.register_status = 'approved'

$BODY$;

ALTER FUNCTION public.computer_room_4_4()
    OWNER TO postgres;
