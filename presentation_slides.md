# FitTrack – Online Fitness Training Platform
## University Presentation & Viva Slide Deck (Review 1)

---

### Slide 1: Project Title + Team
* **Project Name:** FitTrack – Online Fitness Training Platform
* **Version:** 1.0 (Academic Review 1)
* **Domain:** Java Enterprise Web Development & Cloud Database Integration
* **Team Members:** [Student Name / Roll Number / Section]
* **Guide / Evaluator:** [Professor / Department Name]

---

### Slide 2: Problem Statement
* Generic fitness apps often lack a direct bridge between certified coaching and structured progression.
* Trainees struggle with accountability, program guidance, and measuring consistent physical transformation.
* Existing solutions either rely on bloated frameworks or lack transparent role-based interactions.
* Academic Challenge: Developing an enterprise-grade platform strictly utilizing Core Java, OOP, Servlets, JDBC, Collections, Generics, and Multithreading without framework abstraction.

---

### Slide 3: Proposed Solution
* **FitTrack:** A modular, layered Java Web Application connecting Members, Coaches, and Administrators.
* **Role-Based Workflows:**
  - Administrators maintain platform security, moderate workouts, and monitor users.
  - Trainers author tailored fitness programs and provide direct coaching feedback.
  - Members follow verified plans, log weekly progress, and track BMI trends.
* **Pure Java Architecture:** High performance, clear design patterns (DAO, MVC, Service Layer), and full academic transparency.

---

### Slide 4: User Roles
* **1. Administrator (`ADMIN`):**
  - Full system governance, user CRUD, role updates.
  - Content moderation: Reviewing and approving/rejecting submitted workout programs.
  - Platform global parameters & communication audit.
* **2. Trainer (`TRAINER`):**
  - Workout program designer and exercise routine curator.
  - Client progress reviewer with asynchronous performance report generation.
  - Direct 1-on-1 coaching messaging.
* **3. Member / Trainee (`USER`):**
  - Browse approved workout catalog and enroll in active routines.
  - Log weight, height, body measurements, and calculate real-time BMI.
  - Consult coaches and receive system notifications.

---

### Slide 5: System Architecture
* **Layered 5-Tier Architecture:**
  1. **Presentation Layer:** JSP, JSTL, HTML5, Modern CSS, Client JavaScript.
  2. **Controller Layer (Servlets & Filters):** Jakarta Servlets (`LoginServlet`, `WorkoutServlet`, `AdminServlet`, etc.) + `AuthFilter` (RBAC).
  3. **Service Layer (Business Logic):** `UserService`, `WorkoutService`, `ProgressService`, `MessageService`, `NotificationService`.
  4. **Data Access Layer (DAO):** `GenericDAO<T, ID>`, `UserDAO`, `WorkoutPlanDAO`, `ExerciseDAO`, etc.
  5. **Persistence Layer:** PostgreSQL hosted on Supabase connected via pure JDBC driver.

```
[ Browser / Client ]
        │  (HTTP GET/POST)
        ▼
[ Servlet & Filter Layer (Jakarta Servlets) ]
        │
        ▼
[ Service Layer (Validation & Business Rules) ] ──▶ [ Background Threads ]
        │                                           (NotificationThread & ProgressReportThread)
        ▼
[ DAO Layer (GenericDAO, UserDAO, WorkoutPlanDAO) ]
        │
        ▼ (Pure JDBC: PreparedStatement & ResultSet)
[ Supabase PostgreSQL Cloud Database ]
```

---

### Slide 6: Database / ER Diagram
* **Hosted Database:** Supabase PostgreSQL (`Online Fitness Training Platform`)
* **Relational Entities:**
  - `users` (id, name, email, password, role, created_at)
  - `workout_plans` (id, trainer_id [FK], title, description, difficulty, duration, status)
  - `exercises` (id, name, description, muscle_group, sets, reps, duration)
  - `plan_exercises` (id, plan_id [FK], exercise_id [FK])
  - `progress` (id, user_id [FK], weight, height, body_measurement, fitness_goal, record_date)
  - `messages` (id, sender_id [FK], receiver_id [FK], message, created_at, is_read)
  - `notifications` (id, user_id [FK], message, is_read, created_at)
  - `system_settings` (id, setting_name, setting_value, updated_at)
  - `user_workout_plans` (id, user_id [FK], plan_id [FK], status, enrolled_at)

---

### Slide 7: Technology Stack
* **Language & SDK:** Java 17 LTS
* **Web Engine:** Jakarta Servlets 5.0, JSP 3.1, JSTL 2.0
* **Data Access:** Pure JDBC (PostgreSQL JDBC Driver 42.7.3)
* **Cloud Database:** Supabase PostgreSQL
* **Security:** SHA-256 Hashing (`PasswordUtil.java`), Session Security, RBAC Filter
* **Build System:** Apache Maven 3.9
* **Deployment Target:** Apache Tomcat 10.1+
* **Testing:** JUnit 5 (Core OOP, validation, threads)

---

### Slide 8: Core Java & OOP Implementation (10 Marks Rubric)
* **Encapsulation:** All model properties are private with getters, setters, and constructors.
* **Abstraction:** Abstract base class `User` declares abstract contracts:
  - `public abstract String getRoleTitle()`
  - `public abstract String getPermissionsOverview()`
* **Inheritance & Polymorphism:**
  - `Admin`, `Trainer`, and `FitnessUser` extend `User`, providing customized role behaviors and polymorphic dashboard routing.
* **Interfaces:**
  - `Authenticatable`: Standardized authentication contract across users.
  - `DashboardAccess`: Standardized role metadata and UI badging.
  - `GenericDAO<T, ID>`: Standardized generic persistence contracts.
* **Custom Exceptions:**
  - `DatabaseException`, `ValidationException`, `AuthenticationException`, `UserNotFoundException`.

---

### Slide 9: JDBC & Database Integration (6 Marks + 7 Marks Rubrics)
* **Centralized Connection Management (`DBConnection.java`):**
  - Dynamic credential loading (Environment Variables &rarr; System Properties &rarr; `db.properties`).
  - No hardcoded secrets in source code.
* **DAO Pattern Implementation:**
  - 100% pure JDBC queries using `PreparedStatement` to eliminate SQL injection risks.
  - `ResultSet` row-mapping into rich domain entities.
  - Safe resource cleanup via `try-with-resources`.
  - Zero SQL inside JSP views or Servlet controllers.

---

### Slide 10: Collections, Generics & Multithreading (10 Marks Rubrics)
* **Collections & Generics:**
  - `List<User>`, `List<WorkoutPlan>`, `List<Exercise>`, `List<Progress>`, `List<Message>`.
  - `Map<Integer, User>` lookup map in `UserDAO`.
  - Type-safe `GenericDAO<T, ID>` implementation across all DAOs.
* **Multithreading & Synchronization:**
  - **`NotificationThread` (Implements `Runnable`):** Asynchronous background queue processor dispatching alerts without blocking HTTP worker threads. Uses `synchronized` blocks and `wait()/notify()`.
  - **`ProgressReportThread` (Extends `Thread`):** Calculates multi-week body transformations and BMI transitions, caching summaries in a `synchronized` cache map.

---

### Slide 11: Current Development & Working Features (Review 1 Deliverable)
* Complete 5-tier architecture compiled and packaged (`target/fittrack.war`).
* Working authentication system with role-based redirection.
* Full Admin Dashboard: User management, pending workout plan approvals, and global settings.
* Full Trainer Dashboard: Program creator, exercise catalog, trainee progress inspection, and report triggers.
* Full Member Dashboard: Workout enrollment, weight & BMI logging, and trainer messaging.
* 100% unit tests passing (`FitTrackCoreTest.java`).
* Supabase PostgreSQL schema and seed data scripts ready.

---

### Slide 12: Future Scope & Roadmap (Review 2 & Final Review)
* **Visual Progress Charts:** Chart.js integration for weight & body fat percentage trends.
* **Video Exercise Tutorials:** Embedding demonstration video URLs for workout movements.
* **Diet & Nutrition Logging:** Caloric intake and macronutrient split calculator.
* **Automated Email Notifications:** Integrating JavaMail API with `NotificationThread`.
* **Mobile Progressive Web App (PWA):** Offline workout tracking capabilities.
