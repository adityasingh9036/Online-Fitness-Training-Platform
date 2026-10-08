-- ==========================================================
-- FitTrack - Online Fitness Training Platform
-- PostgreSQL Seed Data
-- ==========================================================

-- 1. Insert Default Users
-- Passwords:
-- admin@fittrack.com   -> admin123   (SHA-256: 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9)
-- trainer@fittrack.com -> trainer123 (SHA-256: 5b3d264e4cdc2c39ca6708b3e1e21f082722be12e63ee21484bdbe15735ab066)
-- user@fittrack.com    -> user123    (SHA-256: e606e38b0d8c19b24cf0ee3808183162ea7cd63ff7912dbb22b5e803286b4446)
INSERT INTO users (id, name, email, password, role) VALUES
(1, 'System Administrator', 'admin@fittrack.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'ADMIN'),
(2, 'Coach Marcus Vance', 'trainer@fittrack.com', '5b3d264e4cdc2c39ca6708b3e1e21f082722be12e63ee21484bdbe15735ab066', 'TRAINER'),
(3, 'Alex Johnson', 'user@fittrack.com', 'e606e38b0d8c19b24cf0ee3808183162ea7cd63ff7912dbb22b5e803286b4446', 'USER')
ON CONFLICT (id) DO NOTHING;

-- Reset sequence to ensure auto-increment works from next id
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- 2. Insert Standard Exercises
INSERT INTO exercises (id, name, description, muscle_group, sets, reps, duration) VALUES
(1, 'Push Ups', 'Standard bodyweight push up targeting chest, shoulders, and triceps.', 'Chest', 3, 15, 60),
(2, 'Barbell Bench Press', 'Compound barbell press on flat bench for chest strength and hypertrophy.', 'Chest', 4, 10, 90),
(3, 'Pull Ups', 'Wide-grip vertical pull targeting latissimus dorsi and upper back.', 'Back', 3, 8, 60),
(4, 'Barbell Deadlift', 'Essential compound movement building total posterior chain strength.', 'Back', 4, 6, 120),
(5, 'Barbell Back Squats', 'Deep barbell squat targeting quadriceps, glutes, and core stability.', 'Legs', 4, 10, 120),
(6, 'Dumbbell Walking Lunges', 'Unilateral leg exercise developing balance, glute and quad endurance.', 'Legs', 3, 12, 60),
(7, 'Overhead Shoulder Press', 'Standing or seated dumbbell press for anterior and lateral deltoids.', 'Shoulders', 3, 10, 90),
(8, 'Plank', 'Isometric core hold maintaining a straight line from head to heels.', 'Core', 3, 1, 60),
(9, 'Hanging Leg Raises', 'Dynamic abdominal exercise targeting lower abdominals and hip flexors.', 'Core', 3, 12, 60),
(10, 'Bicep Dumbbell Curls', 'Isolation arm exercise building bicep peak and arm definition.', 'Arms', 3, 12, 60)
ON CONFLICT (id) DO NOTHING;

SELECT setval('exercises_id_seq', (SELECT MAX(id) FROM exercises));

-- 3. Insert Initial Workout Plans
INSERT INTO workout_plans (id, trainer_id, title, description, difficulty, duration, status) VALUES
(1, 2, 'Full Body Foundation', 'A comprehensive beginner program focusing on compound movements and progressive overload.', 'BEGINNER', 4, 'APPROVED'),
(2, 2, 'Hypertrophy Power Split', 'Intensive 4-day split program designed to maximize muscle growth and functional power.', 'INTERMEDIATE', 8, 'APPROVED'),
(3, 2, 'Elite Conditioning & Strength', 'High-intensity advanced routine combining powerlifts and conditioning.', 'ADVANCED', 12, 'PENDING')
ON CONFLICT (id) DO NOTHING;

SELECT setval('workout_plans_id_seq', (SELECT MAX(id) FROM workout_plans));

-- 4. Map Exercises to Workout Plans
INSERT INTO plan_exercises (plan_id, exercise_id) VALUES
(1, 1), -- Full Body -> Push Ups
(1, 3), -- Full Body -> Pull Ups
(1, 5), -- Full Body -> Squats
(1, 8), -- Full Body -> Plank
(2, 2), -- Hypertrophy -> Bench Press
(2, 4), -- Hypertrophy -> Deadlift
(2, 6), -- Hypertrophy -> Lunges
(2, 7), -- Hypertrophy -> Shoulder Press
(2, 10),-- Hypertrophy -> Bicep Curls
(3, 2), -- Elite -> Bench Press
(3, 4), -- Elite -> Deadlift
(3, 5), -- Elite -> Squats
(3, 7)  -- Elite -> Shoulder Press
ON CONFLICT DO NOTHING;

-- 5. Insert Sample Progress for Alex Johnson (User ID: 3)
INSERT INTO progress (user_id, weight, height, body_measurement, fitness_goal, record_date) VALUES
(3, 76.5, 175.0, 'Chest: 38in, Waist: 34in', 'Weight Loss and Lean Muscle', CURRENT_DATE - INTERVAL '14 days'),
(3, 75.2, 175.0, 'Chest: 38.5in, Waist: 33.5in', 'Weight Loss and Lean Muscle', CURRENT_DATE - INTERVAL '7 days'),
(3, 74.0, 175.0, 'Chest: 39in, Waist: 32.8in', 'Weight Loss and Lean Muscle', CURRENT_DATE)
ON CONFLICT DO NOTHING;

-- 6. Insert User Workout Enrollment
INSERT INTO user_workout_plans (user_id, plan_id, status) VALUES
(3, 1, 'ACTIVE')
ON CONFLICT DO NOTHING;

-- 7. Insert Sample Trainer-User Messages
INSERT INTO messages (sender_id, receiver_id, message, is_read, created_at) VALUES
(3, 2, 'Hello Coach Marcus, I started the Full Body Foundation workout today! Any tips for knee alignment during squats?', TRUE, CURRENT_TIMESTAMP - INTERVAL '2 days'),
(2, 3, 'Great work Alex! Make sure your knees track in line with your toes and maintain a neutral spine. Keep up the momentum!', TRUE, CURRENT_TIMESTAMP - INTERVAL '1 day'),
(3, 2, 'Thanks Coach, feeling great after Day 2!', FALSE, CURRENT_TIMESTAMP - INTERVAL '2 hours')
ON CONFLICT DO NOTHING;

-- 8. Insert Sample Notifications
INSERT INTO notifications (user_id, message, is_read) VALUES
(3, 'Welcome to FitTrack! Your journey begins today. Explore available workout plans.', TRUE),
(3, 'Coach Marcus replied to your question regarding squats.', FALSE),
(2, 'Alex Johnson sent you a new message.', FALSE),
(1, 'New workout plan "Elite Conditioning & Strength" submitted for approval.', FALSE)
ON CONFLICT DO NOTHING;

-- 9. Insert System Settings
INSERT INTO system_settings (setting_name, setting_value) VALUES
('PLATFORM_NAME', 'FitTrack Online Training'),
('MAX_WORKOUT_DURATION_WEEKS', '16'),
('MAINTENANCE_MODE', 'FALSE'),
('NOTIFICATION_AUTO_PURGE_DAYS', '30'),
('ALLOW_REGISTRATIONS', 'TRUE')
ON CONFLICT (setting_name) DO NOTHING;
