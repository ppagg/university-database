-- FUNCTION: public.random_names(integer)

-- DROP FUNCTION IF EXISTS public.random_names(integer);

CREATE OR REPLACE FUNCTION public.random_names(
	n integer)
    RETURNS TABLE(name character, sex character, id integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
SELECT nam.name, nam.sex, row_number() OVER ()::integer
FROM (SELECT "Name".name, "Name".sex
FROM "Name"
ORDER BY random() LIMIT n) as nam;
END;
$BODY$;

ALTER FUNCTION public.random_names(integer)
    OWNER TO postgres;
