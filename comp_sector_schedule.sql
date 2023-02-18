-- View: public.comp_sector_schedule

-- DROP VIEW public.comp_sector_schedule;

CREATE OR REPLACE VIEW public.comp_sector_schedule
 AS
 SELECT cr.course_code,
    string_agg(concat(ls.name::character varying, ' ', ls.surname::character varying), ','::text) AS labstaff,
    l.lab_title,
    string_agg(ls.email::text, ','::text) AS emails,
    p.weekday,
    p.start_time,
    p.end_time,
    p.room_id
   FROM "Semester" sem
     JOIN "CourseRun" cr ON cr.semesterrunsin = sem.semester_id
     JOIN "Lab" l ON l.lab_code = cr.labuses
     JOIN "Sector" s ON s.sector_code = l.sector_code
     JOIN "Participates" p ON p.course_code::bpchar = cr.course_code AND p.serial_number = cr.serial_number
     JOIN "LabStaff" ls ON ls.amka = p.amka
  WHERE p.role::text = 'responsible'::text AND sem.semester_status = 'present'::semester_status_type AND s.sector_code = 1
  GROUP BY cr.course_code, l.lab_title, p.weekday, p.start_time, p.end_time, p.room_id;

ALTER TABLE public.comp_sector_schedule
    OWNER TO postgres;


CREATE TRIGGER trigger_updatable_view
    INSTEAD OF UPDATE 
    ON public.comp_sector_schedule
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_updatable_view();

