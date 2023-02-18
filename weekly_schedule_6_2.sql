-- View: public.weekly_schedule_6_2

-- DROP VIEW public.weekly_schedule_6_2;

CREATE OR REPLACE VIEW public.weekly_schedule_6_2
 AS
( SELECT la.room_id,
    la.weekday,
    la.start_time,
    la.end_time,
    prof1.name,
    prof1.surname,
    la.course_code
   FROM "LearningActivity" la
     JOIN "CourseRun" cr ON la.course_code = cr.course_code AND la.serial_number = cr.serial_number
     JOIN "Professor" prof1 ON cr.amka_prof1 = prof1.amka
     JOIN "Semester" sem ON cr.semesterrunsin = sem.semester_id
  WHERE sem.semester_status = 'present'::semester_status_type
  ORDER BY la.room_id)
UNION
 SELECT la.room_id,
    la.weekday,
    la.start_time,
    la.end_time,
    prof.surname AS name,
    prof.name AS surname,
    crun.course_code
   FROM "LearningActivity" la
     JOIN "CourseRun" crun ON la.course_code = crun.course_code AND la.serial_number = crun.serial_number
     JOIN "Semester" sem ON crun.semesterrunsin = sem.semester_id
     JOIN "Professor" prof ON prof.amka = crun.amka_prof2
  WHERE sem.semester_status = 'present'::semester_status_type
UNION
( SELECT la.room_id,
    la.weekday,
    la.start_time,
    la.end_time,
    ls.name,
    ls.surname,
    la.course_code
   FROM "LearningActivity" la
     JOIN "CourseRun" cr ON la.course_code = cr.course_code AND la.serial_number = cr.serial_number
     JOIN "Supports" sup ON cr.course_code = sup.course_code AND cr.serial_number = sup.serial_number
     JOIN "LabStaff" ls ON sup.amka = ls.amka
     JOIN "Semester" sem ON cr.semesterrunsin = sem.semester_id
  WHERE sem.semester_status = 'present'::semester_status_type
  ORDER BY la.room_id);

ALTER TABLE public.weekly_schedule_6_2
    OWNER TO postgres;

