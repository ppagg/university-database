-- FUNCTION: public.recursive_4_9()

-- DROP FUNCTION IF EXISTS public.recursive_4_9();

CREATE OR REPLACE FUNCTION public.recursive_4_9(
	)
    RETURNS TABLE(room_id integer, weekday character, start_time integer, end_time integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN

RETURN QUERY
	WITH RECURSIVE Req(anc, des) AS (
		SELECT	LA.start_time AS anc, LA.end_time AS des, LA.room_id, LA.weekday
		FROM	"LearningActivity" AS LA
		UNION
		SELECT	Req.anc, L.end_time, L.room_id, L.weekday
		FROM	Req, "LearningActivity" AS L
		WHERE	L.start_time = Req.des AND Req.room_id = L.room_id AND Req.weekday = L.weekday
	)
	
	SELECT	A1.room_id, A1.weekday, A1.anc, A1.des
	FROM	Req AS A1
	GROUP BY A1.weekday, A1.room_id, A1.anc, A1.des
	HAVING	(A1.des-A1.anc)	>=	ALL(SELECT	Req.des-Req.anc
									FROM Req
									WHERE A1.room_id = Req.room_id and A1.weekday = Req.weekday);
								
END;
$BODY$;

ALTER FUNCTION public.recursive_4_9()
    OWNER TO postgres;
