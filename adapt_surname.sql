-- FUNCTION: public.adapt_surname(character, character)

-- DROP FUNCTION IF EXISTS public.adapt_surname(character, character);

CREATE OR REPLACE FUNCTION public.adapt_surname(
	surname character,
	sex character)
    RETURNS character
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
DECLARE
result character(50);
BEGIN
result = surname;
IF right(surname,2)<>'ΗΣ' THEN
RAISE NOTICE 'Cannot handle this surname';
ELSIF sex='F' THEN
result = left(surname,-1);
ELSIF sex<>'M' THEN
RAISE NOTICE 'Wrong sex parameter';
END IF;
RETURN result;
END;
$BODY$;

ALTER FUNCTION public.adapt_surname(character, character)
    OWNER TO postgres;
