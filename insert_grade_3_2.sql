-- FUNCTION: public.insert_grade_3_2(integer)

-- DROP FUNCTION IF EXISTS public.insert_grade_3_2(integer);

CREATE OR REPLACE FUNCTION public.insert_grade_3_2(
	semester_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_reg_cr		RECORD;
	v_register_2	"Register"%ROWTYPE;
	v_course_run	"CourseRun"%ROWTYPE;
	v_course		"Course"%ROWTYPE;
	v_student		"Student"%ROWTYPE;
	v_entry_year	INTEGER := 0;
	v_course_year	INTEGER := 0;

	v_exam_perc		NUMERIC := 0;
	v_exam_grade	NUMERIC := 0;
	v_lab_grade		NUMERIC := 0;
	v_final_grade	NUMERIC := 0;

	v_check			INTEGER := 0;
BEGIN
	
FOR v_reg_cr IN
	SELECT	*
	FROM	"Register" Reg INNER JOIN "CourseRun" CR on Reg.course_code=CR.course_code AND Reg.serial_number=CR.serial_number
	WHERE	CR.semesterrunsin=semester_id
			AND Reg.register_status IN ('pass', 'fail')
LOOP
	-- Change a registration if the final_grade is null. This assumes that
	-- there can't be a final_grade without at least an exam_grade.
	IF v_reg_cr.final_grade IS NULL THEN
		-- find corresponding CourseRun
		SELECT	* INTO v_course_run
		FROM	"CourseRun"
		WHERE	course_code=v_reg_cr.course_code
				AND serial_number=v_reg_cr.serial_number;

		-- find corresponding Course
		SELECT	* INTO v_course
		FROM	"Course"
		WHERE	course_code=v_reg_cr.course_code;

		-- find the student
		SELECT	* INTO v_student
		FROM	"Student"
		WHERE	amka=v_reg_cr.amka;

		-- if exam grade does NOT exist then update it
		IF v_reg_cr.exam_grade IS NULL THEN
			v_exam_grade := CAST ((rand % 10 + 1) AS INTEGER); --returns a number between 1 and 10
			UPDATE	"Register"
			SET		exam_grade=v_exam_grade
			WHERE	course_code=v_reg_cr.course_code AND
					serial_number=v_reg_cr.serial_number AND
					amka=v_reg_cr.amka;
		ELSE
			v_exam_grade := v_reg_cr.exam_grade;
		END IF;

		-- if the registration course has lab part then do the following duhh
		IF (v_course.lab_hours > 0) AND (v_course_run.labuses IS NOT NULL) THEN
			
			IF v_reg_cr.lab_grade IS NULL THEN
				-- find the latest registration's lab_grade that is a
				-- 'pass' (>5) for the same course and student
				FOR v_register_2 IN
					SELECT	*
					FROM	"Register"
					WHERE	course_code=v_reg_cr.course_code
							AND serial_number<v_reg_cr.serial_number
							AND amka=v_reg_cr.amka
							AND lab_grade>=5
					ORDER BY serial_number DESC
				LOOP
					-- finds the last lab_grade that greater than 5
					v_check := 1;
					v_lab_grade := v_register_2.lab_grade;

					EXIT;
				END LOOP;
				-- check = 0 means that an old lab_grade was NOT found and
				-- therefore the new lab_grade is a random number.
				IF v_check = 0 THEN
					v_lab_grade := CAST ((rand % 10 + 1) AS INTEGER);
				END IF;

				v_exam_perc := v_course_run.exam_percentage;
				v_final_grade := v_exam_perc * v_exam_grade + (1-v_exam_perc) * v_lab_grade;

				UPDATE	"Register"
				SET		lab_grade=v_lab_grade,
						final_grade=v_final_grade
				WHERE	course_code=v_reg_cr.course_code AND
						serial_number=v_reg_cr.serial_number AND
						amka=v_reg_cr.amka;

				-- RAISE NOTICE 'value of exam grade is %', v_exam_grade;
				-- RAISE NOTICE 'value of lab grade is %', v_lab_grade;
				-- RAISE NOTICE 'value of final grade is %', v_final_grade;

			ELSE
				-- a lab_grade is found in the registration, so we keep it
				-- and update only the final_grade
				v_lab_grade := v_reg_cr.lab_grade;

				v_exam_perc := v_course_run.exam_percentage;
				v_final_grade := v_exam_perc * v_exam_grade + (1-v_exam_perc) * v_lab_grade;

				UPDATE	"Register"
				SET		final_grade=v_final_grade
				WHERE	course_code=v_reg_cr.course_code AND
						serial_number=v_reg_cr.serial_number AND
						amka=v_reg_cr.amka;

			END IF;

		-- the course does NOT have a lab part so the final_grade is the
		-- exam_grade and update the final_grade. The update of the
		-- exam_grade is done above the current if-else clause.
		ELSE
			v_final_grade := v_exam_grade;
			-- RAISE NOTICE 'New value of exam grade is %', v_exam_grade;
			-- RAISE NOTICE 'New value of lab grade is %', v_lab_grade;
			-- RAISE NOTICE 'New value of final grade is %', v_final_grade;

			UPDATE	"Register"
			SET		final_grade=v_final_grade
			WHERE	course_code=v_reg_cr.course_code AND
					serial_number=v_reg_cr.serial_number AND
					amka=v_reg_cr.amka;

		END IF;

		-- change the state of the registration to 'pass' or 'fail'
		IF v_final_grade >= 5 THEN
			UPDATE	"Register"
			SET		register_status='pass'
			WHERE	course_code=v_reg_cr.course_code AND
					serial_number=v_reg_cr.serial_number AND
					amka=v_reg_cr.amka;
		ELSE
			UPDATE	"Register"
			SET		register_status='fail'
			WHERE	course_code=v_reg_cr.course_code AND
					serial_number=v_reg_cr.serial_number AND
					amka=v_reg_cr.amka;
		END IF;

	END IF;

-- RETURN NEXT v_reg_cr;
END LOOP;
RETURN;

END;
$BODY$;

ALTER FUNCTION public.insert_grade_3_2(integer)
    OWNER TO postgres;
