-- FUNCTION: public.insert_activity_3_3(character)

-- DROP FUNCTION IF EXISTS public.insert_activity_3_3(character);

CREATE OR REPLACE FUNCTION public.insert_activity_3_3(
	course_code character)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_semester		"Semester"%ROWTYPE;
	v_course_run	"CourseRun"%ROWTYPE;
	v_course		"Course"%ROWTYPE;
	v_room			"Room"%ROWTYPE;
	v_learn_act		"LearningActivity"%ROWTYPE;
	v_learn_act_2	"LearningActivity"%ROWTYPE;
	v_learn_act_3	"LearningActivity"%ROWTYPE;

	v_lect_hr		INTEGER;
	v_tut_hr		INTEGER;
	v_lab_hr		INTEGER;

	v_day			CHAR;
	day				INTEGER;

	v_room_id		INTEGER;
	i				INTEGER;

	found			BOOLEAN;
	act_type		VARCHAR;
BEGIN

	SELECT	* INTO v_semester
	FROM	"Semester" S
	WHERE	S.semester_status='present';

	SELECT	* INTO v_course
	FROM	"Course" C
	WHERE	C.course_code=$1;

	SELECT	* INTO v_course_run
	FROM	"CourseRun" CR
	WHERE	CR.course_code=$1
			AND CR.semesterrunsin=v_semester.semester_id;

	IF v_course_run IS NULL THEN
		RAISE NOTICE 'Course % is not available is semester %', $1, v_semester.semester_id;
		RETURN;
	END IF;

	-- initialize found to FALSE
	found := FALSE;
	-- initialize i to 0
	i := 0;
	-- initialize day to 0
	day := 0;
	-- find the lecture hours
	v_lect_hr := v_course.lecture_hours;
	RAISE NOTICE '% lecture hours', v_lect_hr;
	
	-- this will return a lecture room in every iteration of the loop
	FOR v_room_id IN
		SELECT	room_id
		FROM	"Room"
		WHERE	room_type='lecture_room'
	LOOP

		day := 0;

		WHILE day <= 6 LOOP
			RAISE NOTICE 'Day is %', day;

			i := 0;

			WHILE i <= (12 - v_lect_hr) LOOP
				RAISE NOTICE 'i is %', i;

				RAISE NOTICE '(Before) Selected Learning Activity is (%,%,%,%,%,%,%)',
				v_learn_act.course_code,
				v_learn_act.serial_number,
				v_learn_act.activity_type,
				v_learn_act.start_time,
				v_learn_act.end_time,
				v_learn_act.weekday,
				v_learn_act.room_id;

				SELECT	* INTO v_learn_act
				FROM	"LearningActivity" L
				WHERE	L.weekday = CAST(day AS CHAR)
				AND		L.room_id = v_room_id
				AND		((i+8 < L.end_time AND i+8 >= L.start_time)
						OR	((i+8+v_lect_hr) > L.start_time AND (i+8+v_lect_hr) <= L.end_time)
						OR	(i+8 <= L.start_time AND (i+8+v_lect_hr) >= L.end_time))
				LIMIT 1;

				RAISE NOTICE '(After) Selected Learning Activity is (%,%,%,%,%,%,%)',
				v_learn_act.course_code,
				v_learn_act.serial_number,
				v_learn_act.activity_type,
				v_learn_act.start_time,
				v_learn_act.end_time,
				v_learn_act.weekday,
				v_learn_act.room_id;

				RAISE NOTICE '(Before) Found is %', found;
				-- if a learning activity is not found, then we found our spot and
				-- therefore exit all three loops.
				RAISE NOTICE 'Checking for variable Found...';
				
				IF v_learn_act IS NULL THEN
					found := TRUE;
					-- v_day := CAST(day AS CHAR);
					RAISE NOTICE 'Found is %', found;
					RAISE NOTICE 'Exiting loop 1 (inner)...';
					EXIT;
				END IF;

				RAISE NOTICE '(After) Found is %', found;

				i := i + 1;
			END LOOP;

			RAISE NOTICE '(After After) Found is %', found;
			-- if an available room is found return
			IF found IS TRUE THEN
				RAISE NOTICE 'Exiting loop 2...';
				EXIT;
			END IF;

			day := day + 1;

		END LOOP;

		IF found IS TRUE THEN
			RAISE NOTICE 'Exiting loop 3 (outer)...';
			EXIT;
		END IF;

		RAISE NOTICE 'There is no room left!!!';

	END LOOP;

	RAISE NOTICE 'Outside outer loop';

	RAISE NOTICE '%,%,%,%,%,%,%',$1,
								v_course_run.serial_number,
								'lecture',
								i+8,
								i+v_lect_hr+8,
								CAST(day AS CHAR),
								-- v_day,
								v_room_id;

	INSERT INTO "LearningActivity"
	VALUES	($1,
			v_course_run.serial_number,
			'lecture',
			i+8,
			i+v_lect_hr+8,
			CAST(day AS CHAR),
			v_room_id);

------------------------------- For the tutorial ------------------------------

	-- initialize found to FALSE
	found := FALSE;
	-- initialize i to 0
	i := 0;
	-- initialize day to 0
	day := 0;
	-- initialize v_learn_act to 0
	v_learn_act := NULL;
	-- find the tutorial hours
	v_tut_hr := v_course.tutorial_hours;
	RAISE NOTICE '% tutorial hours', v_tut_hr;
	
	-- this will return a lecture room in every iteration of the loop
	FOR v_room_id IN
		SELECT	room_id
		FROM	"Room"
		WHERE	room_type='lecture_room'
	LOOP

		day := 0;

		WHILE day <= 6 LOOP
			RAISE NOTICE 'Day is %', day;

			i := 0;

			WHILE i <= (12 - v_tut_hr) LOOP
				RAISE NOTICE 'i is %', i;

				RAISE NOTICE '(Before) Selected Learning Activity is (%,%,%,%,%,%,%)',
				v_learn_act.course_code,
				v_learn_act.serial_number,
				v_learn_act.activity_type,
				v_learn_act.start_time,
				v_learn_act.end_time,
				v_learn_act.weekday,
				v_learn_act.room_id;

				SELECT	* INTO v_learn_act
				FROM	"LearningActivity" L
				WHERE	L.weekday = CAST(day AS CHAR)
				AND		L.room_id = v_room_id
				AND		((i+8 < L.end_time AND i+8 >= L.start_time)
						OR	((i+8+v_tut_hr) > L.start_time AND (i+8+v_tut_hr) <= L.end_time)
						OR	(i+8 <= L.start_time AND (i+8+v_tut_hr) >= L.end_time))
				LIMIT 1;

				RAISE NOTICE '(After) Selected Learning Activity is (%,%,%,%,%,%,%)',
				v_learn_act.course_code,
				v_learn_act.serial_number,
				v_learn_act.activity_type,
				v_learn_act.start_time,
				v_learn_act.end_time,
				v_learn_act.weekday,
				v_learn_act.room_id;

				RAISE NOTICE '(Before) Found is %', found;
				-- if a learning activity is not found, then we found our spot and
				-- therefore exit all three loops.
				RAISE NOTICE 'Checking for variable Found...';
				
				IF v_learn_act IS NULL THEN
					found := TRUE;
					-- v_day := CAST(day AS CHAR);
					RAISE NOTICE 'Found is %', found;
					RAISE NOTICE 'Exiting loop 1 (inner)...';
					EXIT;
				END IF;

				RAISE NOTICE '(After) Found is %', found;

				i := i + 1;
			END LOOP;

			RAISE NOTICE '(After After) Found is %', found;
			-- if an available room is found return
			IF found IS TRUE THEN
				RAISE NOTICE 'Exiting loop 2...';
				EXIT;
			END IF;

			day := day + 1;

		END LOOP;

		IF found IS TRUE THEN
			RAISE NOTICE 'Exiting loop 3 (outer)...';
			EXIT;
		END IF;

		RAISE NOTICE 'There is no room left!!!';

	END LOOP;

	RAISE NOTICE 'Outside outer loop';

	RAISE NOTICE '%,%,%,%,%,%,%',$1,
								v_course_run.serial_number,
								'tutorial',
								i+8,
								i+v_tut_hr+8,
								CAST(day AS CHAR),
								-- v_day,
								v_room_id;

	INSERT INTO "LearningActivity"
	VALUES	($1,
			v_course_run.serial_number,
			'tutorial',
			i+8,
			i+v_tut_hr+8,
			CAST(day AS CHAR),
			v_room_id);

	IF v_course.labuses IS NULL THEN

		-- initialize found to FALSE
		found := FALSE;
		-- initialize i to 0
		i := 0;
		-- initialize day to 0
		day := 0;
		-- initialize v_learn_act to NULL
		v_learn_act := NULL;
		-- find the lecture hours
		v_lab_hr := v_course.lab_hours;
		RAISE NOTICE '% lab hours', v_lab_hr;
		
		-- this will return a lab room in every iteration of the loop
		FOR v_room_id IN
			SELECT	room_id
			FROM	"Room"
			WHERE	room_type IN ('lab_room', 'computer_room')
		LOOP

			day := 0;

			-- find the activity_type
			IF CAST(SUBSTR(v_course_run.course_code, 1, 3) AS VARCHAR)='ΠΛΗ' THEN
				act_type := 'computer_lab';
			ELSE
				act_type := 'lab';
			END IF;

			-- TODO Insert logic to check if the room and the activity_type match

			WHILE day <= 6 LOOP
				RAISE NOTICE 'Day is %', day;

				i := 0;

				WHILE i <= (12 - v_lab_hr) LOOP
					RAISE NOTICE 'i is %', i;

					RAISE NOTICE '(Before) Selected Learning Activity is (%,%,%,%,%,%,%)',
					v_learn_act.course_code,
					v_learn_act.serial_number,
					v_learn_act.activity_type,
					v_learn_act.start_time,
					v_learn_act.end_time,
					v_learn_act.weekday,
					v_learn_act.room_id;

					SELECT	* INTO v_learn_act
					FROM	"LearningActivity" L
					WHERE	L.weekday = CAST(day AS CHAR)
					AND		L.room_id = v_room_id
					AND		((i+8 < L.end_time AND i+8 >= L.start_time)
							OR	((i+8+v_lab_hr) > L.start_time AND (i+8+v_lab_hr) <= L.end_time)
							OR	(i+8 <= L.start_time AND (i+8+v_lab_hr) >= L.end_time))
					LIMIT 1;

					RAISE NOTICE '(After) Selected Learning Activity is (%,%,%,%,%,%,%)',
					v_learn_act.course_code,
					v_learn_act.serial_number,
					v_learn_act.activity_type,
					v_learn_act.start_time,
					v_learn_act.end_time,
					v_learn_act.weekday,
					v_learn_act.room_id;

					RAISE NOTICE '(Before) Found is %', found;
					-- if a learning activity is not found, then we found our spot and
					-- therefore exit all three loops.
					RAISE NOTICE 'Checking for variable Found...';
					
					IF v_learn_act IS NULL THEN
						found := TRUE;
						-- v_day := CAST(day AS CHAR);
						RAISE NOTICE 'Found is %', found;
						RAISE NOTICE 'Exiting loop 1 (inner)...';
						EXIT;
					END IF;

					RAISE NOTICE '(After) Found is %', found;

					i := i + 1;
				END LOOP;

				RAISE NOTICE '(After After) Found is %', found;
				-- if an available room is found return
				IF found IS TRUE THEN
					RAISE NOTICE 'Exiting loop 2...';
					EXIT;
				END IF;

				day := day + 1;

			END LOOP;

			IF found IS TRUE THEN
				RAISE NOTICE 'Exiting loop 3 (outer)...';
				EXIT;
			END IF;

			RAISE NOTICE 'There is no room left!!!';

		END LOOP;

		RAISE NOTICE 'Outside outer loop';

		RAISE NOTICE '%,%,%,%,%,%,%',$1,
									v_course_run.serial_number,
									act_type,
									i+8,
									i+v_lab_hr+8,
									CAST(day AS CHAR),
									-- v_day,
									v_room_id;

		INSERT INTO "LearningActivity"
		VALUES	($1,
				v_course_run.serial_number,
				'lab',
				i+8,
				i+v_lab_hr+8,
				CAST(day AS CHAR),
				v_room_id);

	END IF;

END;
$BODY$;

ALTER FUNCTION public.insert_activity_3_3(character)
    OWNER TO postgres;
