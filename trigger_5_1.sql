-- FUNCTION: public.trigger_5_1()

-- DROP FUNCTION IF EXISTS public.trigger_5_1();

CREATE OR REPLACE FUNCTION public.trigger_5_1()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    v_participates  RECORD;
    v_student       RECORD;
    sum_of_hours    INTEGER;
BEGIN

    -- if this returns a tuple, it means that we found an overlapping activity.
    IF TG_OP = 'INSERT' THEN
    
        SELECT  * INTO v_participates
        FROM    "Participates" AS P
        WHERE   NEW.amka = P.amka
                AND NEW.weekday = P.weekday
                AND (   (NEW.start_time < P.end_time AND NEW.start_time >= P.start_time)
                    OR (NEW.end_time > P.start_time AND NEW.end_time <= P.end_time)
                    OR (NEW.start_time <= P.start_time AND NEW.end_time >= P.end_time));
    ELSE
    
        SELECT  * INTO v_participates
        FROM    ((SELECT *
                FROM "Participates" AS P)
                EXCEPT
                (SELECT *
                FROM "Participates" AS P
                WHERE   OLD.course_code = P.course_code
                        AND OLD.start_time = P.start_time
                        AND OLD.end_time = P.end_time
                        AND OLD.weekday = P.weekday
                        AND OLD.amka = P.amka)) AS R
        WHERE   NEW.amka = R.amka
                AND NEW.weekday = R.weekday
                AND (   (NEW.start_time < R.end_time AND NEW.start_time >= R.start_time)
                    OR (NEW.end_time > R.start_time AND NEW.end_time <= R.end_time)
                    OR (NEW.start_time <= R.start_time AND NEW.end_time >= R.end_time));

    END IF;

    -- return null if we found a tuple
    IF v_participates IS NOT NULL THEN
        RETURN NULL;
    END IF;

    SELECT  * INTO v_student
    FROM    "Student" S 
    WHERE   S.amka=NEW.amka;

    IF NEW.amka = v_student.amka THEN

        SELECT  SUM(P.end_time - P.start_time) INTO sum_of_hours
        FROM    "Participates" P NATURAL JOIN "LearningActivity" LA
        WHERE   P.amka = NEW.amka
                AND P.course_code = NEW.course_code
                AND P.serial_number = NEW.serial_number
                AND LA.activity_type IN ('lab', 'computer_lab');
        
        IF sum_of_hours IS NULL THEN
            sum_of_hours := 0;
        END IF;
        
        IF (TG_OP = 'UPDATE' AND  (sum_of_hours + (NEW.end_time - NEW.start_time) - (OLD.end_time-OLD.start_time)) > (SELECT C.lab_hours
                                                                                                                    FROM "Course" as C
                                                                                                                    WHERE NEW.course_code = C.course_code)) THEN 
            RETURN NULL;
        
        END IF;
        
        IF ((sum_of_hours + (NEW.end_time - NEW.start_time)) > (SELECT C.lab_hours
                                                                FROM "Course" as C
                                                                WHERE NEW.course_code = C.course_code)) THEN 
        RETURN NULL;

        END IF;

    END IF;
    
    RETURN NEW;

END
$BODY$;

ALTER FUNCTION public.trigger_5_1()
    OWNER TO postgres;
