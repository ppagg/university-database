-- FUNCTION: public.create_am(integer, integer)

-- DROP FUNCTION IF EXISTS public.create_am(integer, integer);

CREATE OR REPLACE FUNCTION public.create_am(
	year integer,
	num integer)
    RETURNS character
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
BEGIN
RETURN concat(year::character(4),lpad(num::text,6,'0'));
END;
$BODY$;

ALTER FUNCTION public.create_am(integer, integer)
    OWNER TO postgres;
