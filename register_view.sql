-- View: public.register_view

-- DROP VIEW public.register_view;

CREATE OR REPLACE VIEW public.register_view
 AS
 SELECT r.amka,
    r.course_code,
    r.serial_number,
    r.register_status
   FROM "Register" r;

ALTER TABLE public.register_view
    OWNER TO postgres;

