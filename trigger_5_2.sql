-- FUNCTION: public.trigger_5_2()

-- DROP FUNCTION IF EXISTS public.trigger_5_2();

CREATE OR REPLACE FUNCTION public.trigger_5_2()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_learn_act		RECORD;
BEGIN

	IF	NEW.weekday IN ('0', '1', '2', '3', '4', '5', '6')
		AND NEW.start_time	>=	8
		AND NEW.end_time	<=	20
		AND NEW.start_time	<	NEW.end_time THEN

		IF TG_OP = 'INSERT' THEN
			-- search if there is another activity that overlaps with the
			-- inserted
			SELECT	* INTO v_learn_act
			FROM	"LearningActivity" L
			WHERE	L.weekday=NEW.weekday
					AND L.room_id=NEW.room_id
					AND ((NEW.start_time	<	L.end_time		AND 	NEW.start_time	>=	L.start_time)

						OR	(NEW.end_time	>	L.start_time	AND 	NEW.end_time	<=	L.end_time)

						OR	(NEW.start_time <=	L.start_time	AND 	NEW.end_time	>=	L.end_time))
			LIMIT 1;

		ELSE
			-- search if there is another activity that overlaps with the
			-- updated
			SELECT	* INTO v_learn_act
			FROM	((SELECT *
					FROM "LearningActivity" as L)
					EXCEPT
					(SELECT *
					FROM "LearningActivity" as L
					WHERE	OLD.room_id = L.room_id
							AND OLD.start_time = L.start_time
							AND OLD.end_time = L.end_time
							AND OLD.weekday = L.weekday)) as R
			WHERE	R.weekday=NEW.weekday
					AND R.room_id=NEW.room_id
					AND ((NEW.start_time	<	R.end_time		AND 	NEW.start_time	>=	R.start_time)

					OR	(NEW.end_time	>	R.start_time	AND 	NEW.end_time	<=	R.end_time)

					OR	(NEW.start_time <=	R.start_time	AND 	NEW.end_time	>=	R.end_time))
			LIMIT 1;

		END IF;

		-- if it's not null, it means that we found another activity, that overlaps
		-- with the inserted/updated
		IF v_learn_act IS NOT NULL THEN
			-- overlap detected
			RETURN NULL;
		ELSE
			RETURN NEW;
		END IF;
	
	ELSE
		RETURN NULL;
	END IF;

END;
$BODY$;

ALTER FUNCTION public.trigger_5_2()
    OWNER TO postgres;
