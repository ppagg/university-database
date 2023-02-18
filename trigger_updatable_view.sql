-- FUNCTION: public.trigger_updatable_view()

-- DROP FUNCTION IF EXISTS public.trigger_updatable_view();

CREATE OR REPLACE FUNCTION public.trigger_updatable_view()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	i				INTEGER;
	curr_name		VARCHAR;
	old_name		VARCHAR;
	new_name		VARCHAR;
	v_name			VARCHAR;
	v_surname		VARCHAR;
	v_serial_number	INTEGER;
	v_amka			INTEGER;
	v_participates "Participates"%ROWTYPE;
	var				RECORD;
BEGIN
	
	IF TG_OP = 'INSERT' OR TG_OP = 'DELETE' THEN
		RAISE NOTICE 'Insert and Delete operations are NOT allowed!!!';
		RETURN NULL;
	ELSE
		IF OLD.room_id <> NEW.room_id THEN
			RAISE NOTICE 'Modification of room_id is NOT allowed!!!';
			RETURN NULL;
		END IF;

		IF OLD.course_code <> NEW.course_code THEN
			RAISE NOTICE 'Modification of course_code is NOT allowed!!!';
			RETURN NULL;
		END IF;

		IF OLD.weekday <> NEW.weekday THEN
			RAISE NOTICE 'Modification of weekday is NOT allowed!!!';
			RETURN NULL;
		END IF;

		IF OLD.start_time <> NEW.start_time THEN
			RAISE NOTICE 'Modification of start_time is NOT allowed!!!';
			RETURN NULL;
		END IF;

		IF OLD.end_time <> NEW.end_time THEN
			RAISE NOTICE 'Modification of end_time is NOT allowed!!!';
			RETURN NULL;
		END IF;

		IF OLD.emails <> NEW.emails THEN
			RAISE NOTICE 'Modification of emails is NOT allowed!!!';
			RETURN NULL;
		END IF;

		i := 1;

		IF OLD.LabStaff <> NEW.LabStaff THEN

			FOREACH old_name IN ARRAY string_to_array(CAST(OLD.LabStaff AS TEXT), CAST(',' AS TEXT)) LOOP
				-- do something with old_name
				new_name := (SELECT split_part(New.LabStaff, ',', i));

				IF old_name <> new_name THEN
					v_name := (SELECT split_part(new_name, ' ', 1));
					v_surname := (SELECT split_part(new_name, ' ', 2));

					-- vriskw to serial_number tou course

					SELECT	serial_number INTO v_serial_number
					FROM	"CourseRun" CR INNER JOIN "Semester" Sem ON CR.semesterrunsin=Sem.semester_id
					WHERE	CR.course_code=OLD.course_code
							AND Sem.semester_status='present';

					-- find the participates tuple to find the amka
					SELECT	P.amka INTO v_amka
					FROM	"Participates" P
					WHERE	P.course_code=OLD.course_code
							AND P.serial_number=v_serial_number;

					-- update name and surname
					UPDATE	"LabStaff" SET	name=v_name,
											surname=v_surname
					WHERE	"LabStaff".amka=v_amka;

				END IF;

				i := i + 1;
			
			END LOOP;

		END IF;

		IF OLD.lab_title <> NEW.lab_title THEN

			SELECT	* INTO var
			FROM	"CourseRun" CR
					INNER JOIN "Semester" Sem ON CR.semesterrunsin=Sem.semester_id
					INNER JOIN "Lab" L ON CR.labuses=L.lab_code
			WHERE	CR.course_code=OLD.course_code
					AND Sem.semester_status='present';

			UPDATE	"Lab" SET 	lab_title=NEW.lab_title
			WHERE	"Lab".lab_code=var.lab_code;

		END IF;

	END IF;

	RETURN NEW;

END
$BODY$;

ALTER FUNCTION public.trigger_updatable_view()
    OWNER TO postgres;
