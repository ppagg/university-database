-- View: public.passed_lab_high_6_1

-- DROP VIEW public.passed_lab_high_6_1;

CREATE OR REPLACE VIEW public.passed_lab_high_6_1
 AS
 SELECT cr.semesterrunsin,
    reg.course_code,
    count(reg.amka) AS amount
   FROM "Register" reg
     JOIN "CourseRun" cr ON reg.course_code = cr.course_code AND reg.serial_number = cr.serial_number
  WHERE reg.register_status = 'pass'::register_status_type AND reg.lab_grade > 8::numeric
  GROUP BY cr.semesterrunsin, reg.course_code;

ALTER TABLE public.passed_lab_high_6_1
    OWNER TO postgres;

