-- FUNCTION: public.random_surnames(integer)

-- DROP FUNCTION IF EXISTS public.random_surnames(integer);

CREATE OR REPLACE FUNCTION public.random_surnames(
	n integer)
    RETURNS TABLE(surname character, id integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
SELECT snam.surname, row_number() OVER ()::integer
FROM (SELECT "Surname".surname
FROM "Surname"
WHERE right("Surname".surname,2)='ΗΣ'
ORDER BY random() LIMIT n) as snam;
END;
$BODY$;

ALTER FUNCTION public.random_surnames(integer)
    OWNER TO postgres;
