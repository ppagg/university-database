-- FUNCTION: public.trigger_5_3()

-- DROP FUNCTION IF EXISTS public.trigger_5_3();

CREATE OR REPLACE FUNCTION public.trigger_5_3()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_course	RECORD;
	v_cr		"CourseRun"%ROWTYPE;
	v_supports	RECORD;
BEGIN

	FOR v_course IN
	SELECT	*
	FROM	"Course" C
	WHERE	C.typical_season=NEW.academic_season
	LOOP

		RAISE NOTICE 'HI, from inside the outer loop!!!';
		-- find the latest course run info for the course in the loop
		SELECT	* INTO v_cr
		FROM	"CourseRun" CR
		WHERE	CR.course_code=v_course.course_code
				AND CR.semesterrunsin < NEW.semester_id
		ORDER BY serial_number DESC
		LIMIT 1;

		IF v_course.lab_hours > 0 THEN
		-- course has lab part
			-- serial number is incr by 2 bc every course run for the same
			-- course happens to do so.
			-- All other values are taken from last course.
			INSERT INTO "CourseRun" VALUES(	v_cr.course_code,
											v_cr.serial_number+2,
											v_cr.exam_min,
											v_cr.lab_min,
											v_cr.exam_percentage,
											v_cr.labuses,
											NEW.semester_id,
											v_cr.amka_prof1,
											v_cr.amka_prof2);

			RAISE NOTICE 'Inerting into "CourseRun" (if) values (%,%,%,%,%,%,%,%,%)',
			v_cr.course_code,
			v_cr.serial_number+2,
			v_cr.exam_min,
			v_cr.lab_min,
			v_cr.exam_percentage,
			v_cr.labuses,
			NEW.semester_id,
			v_cr.amka_prof1,
			v_cr.amka_prof2;
			
			-- add the lab staff from the previous course run of the same
			-- course.
			FOR v_supports IN
			SELECT	*
			FROM	"Supports" S
			WHERE	S.course_code=v_cr.course_code
					AND S.serial_number=v_cr.serial_number
			LOOP

			INSERT INTO "Supports" VALUES (v_supports.amka, v_supports.serial_number + 2, v_supports.course_code);
			RAISE NOTICE 'Inerting into "LabStaff" values (%,%,%)',	v_supports.amka,
																	v_supports.serial_number,
																	v_supports.course_code;

			END LOOP;

		ELSE
		-- course does NOT have lab part

			-- serial number is incr by 2 bc every course run for the same
			-- course happens to do so.
			-- All other values are taken from last course.
			INSERT INTO "CourseRun" VALUES(	v_cr.course_code,
											v_cr.serial_number+2,
											v_cr.exam_min,
											v_cr.lab_min,
											v_cr.exam_percentage,
											v_cr.labuses,
											NEW.semester_id,
											v_cr.amka_prof1,
											v_cr.amka_prof2);

			RAISE NOTICE 'Inerting into "CourseRun" (else) values (%,%,%,%,%,%,%,%,%)',
			v_cr.course_code,
			v_cr.serial_number+2,
			v_cr.exam_min,
			v_cr.lab_min,
			v_cr.exam_percentage,
			v_cr.labuses,
			NEW.semester_id,
			v_cr.amka_prof1,
			v_cr.amka_prof2;

		END IF;
	END LOOP;

	-- always return NEW
	RETURN NEW;

END;
$BODY$;

ALTER FUNCTION public.trigger_5_3()
    OWNER TO postgres;
