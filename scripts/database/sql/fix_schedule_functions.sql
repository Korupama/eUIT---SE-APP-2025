-- Fix schedule functions by dropping and recreating them
-- This script resolves the "cannot change return type" error

-- Drop existing functions
DROP FUNCTION IF EXISTS func_get_student_schedule(integer);
DROP FUNCTION IF EXISTS func_get_student_schedule_by_semester(integer, character);
DROP FUNCTION IF EXISTS func_get_student_exam_schedule(integer);
DROP FUNCTION IF EXISTS func_get_student_exam_schedule_by_semester(integer, character);

-- Now recreate them by running the schedule.sql file
