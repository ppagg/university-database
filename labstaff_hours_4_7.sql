-- FUNCTION: public.labstaff_hours_4_7()

-- DROP FUNCTION IF EXISTS public.labstaff_hours_4_7();

CREATE OR REPLACE FUNCTION public.labstaff_hours_4_7(
	)
    RETURNS TABLE(amka integer, surname character, name character, erg_fortos bigint) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	SELECT	L.amka,
			L.surname,
			L.name,
			SUM(P.end_time)-SUM(P.start_time) AS erg_fortos
	
	FROM	"LabStaff" L LEFT OUTER JOIN "Participates" P ON L.amka=P.amka
	
	WHERE	P.role='responsible'
	
	GROUP	BY L.amka

$BODY$;

ALTER FUNCTION public.labstaff_hours_4_7()
    OWNER TO postgres;
