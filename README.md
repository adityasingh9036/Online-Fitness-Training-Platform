# FitTrack – Online Fitness Training Platform

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![Jakarta Servlets](https://img.shields.io/badge/Jakarta%20Servlets-5.0-blue.svg)](https://jakarta.ee/)
[![Database](https://img.shields.io/badge/Database-PostgreSQL%20%2F%20Supabase-green.svg)](https://supabase.com/)
[![JDBC](https://img.shields.io/badge/Data%20Access-JDBC%20(Pure)-red.svg)](https://docs.oracle.com/javase/8/docs/technotes/guides/jdbc/)
[![Build](https://img.shields.io/badge/Build-Maven-brightgreen.svg)](https://maven.apache.org/)

---

## 1. Project Overview

**FitTrack** is an enterprise-grade Java Web Application developed as an academic project demonstrating mastery of **Core Java, Object-Oriented Programming (OOP), Java Servlets, JSP, JDBC, Collections & Generics, Multithreading, and Supabase PostgreSQL**.

FitTrack bridges the gap between fitness seekers and certified fitness coaches. Trainees enroll in structured workout routines, log body transformations, and communicate directly with trainers, while administrators govern the platform and moderate content.

---

## 2. University Evaluation Rubric Compliance

| Rubric Area | Max Marks | Implementation Highlights |
| :--- | :---: | :--- |
| **OOP Concepts** | **10** | Polymorphic hierarchy (`User` &rarr; `Admin`, `Trainer`, `FitnessUser`), Interfaces (`Authenticatable`, `DashboardAccess`), Encapsulation via private fields/accessors, Custom Exceptions. |
| **Collections & Generics** | **6** | `GenericDAO<T, ID>`, `List<User>`, `List<WorkoutPlan>`, `List<Exercise>`, `List<Progress>`, `List<Message>`, `Map<Integer, User>`, and typed maps. |
| **Multithreading & Synchronization** | **4** | `NotificationThread` (`Runnable` with `synchronized` queue & `wait/notify`), `ProgressReportThread` (`Thread` with `synchronized` cache). |
| **Database Operation Classes (DAO)** | **7** | DAO Pattern with pure JDBC: `UserDAO`, `WorkoutPlanDAO`, `ExerciseDAO`, `ProgressDAO`, `MessageDAO`, `NotificationDAO`, `SystemSettingsDAO`. No SQL in JSP/Servlets. |
| **JDBC Connectivity** | **6** | Centralized `DBConnection.java`, `PreparedStatement`, `ResultSet`, connection pooling, dynamic config from `db.properties` and environment variables. |
| **Servlets & Web Integration** | **7** | `LoginServlet`, `RegisterServlet`, `LogoutServlet`, `AdminServlet`, `TrainerServlet`, `WorkoutServlet`, `ProgressServlet`, `MessageServlet`, `NotificationServlet`, `AuthFilter` (RBAC). |

---

## 3. Technology Stack & Architectural Constraints

* **Backend:** Java 17, Java Servlets (Jakarta EE), JSP, JSTL.
* **Database:** Hosted PostgreSQL via **Supabase**.
* **Data Access:** Pure **JDBC** (`PreparedStatement`, `ResultSet`). *(No Hibernate / JPA / Spring Boot)*.
* **Multithreading:** Java Threads, Runnable, `synchronized` blocks.
* **Frontend:** Responsive HTML5, CSS3, JavaScript.
* **Server:** Apache Tomcat 10+ / 10.1+.
* **Build Tool:** Apache Maven (`pom.xml`).

---

## 4. User Roles & Capabilities

### 👑 1. Administrator (`ADMIN`)
* **System Dashboard:** Live counters for users, trainers, total workouts, and pending approvals.
* **User Governance:** Create, view, update, and delete accounts; assign roles.
* **Workout Moderation:** Review workout plans submitted by trainers; Approve or Reject plans.
* **System Settings:** Configure global platform parameters (Platform Name, Max duration).
* **Communication Logs:** Monitor user interactions.

### 🏋️ 2. Trainer (`TRAINER`)
* **Workout Management:** Create structured workout plans, specify difficulty & duration.
* **Exercise Library:** Add new exercises with targeted muscle group, sets, reps, and durations.
* **Trainee Monitoring:** View client check-ins, weight logs, and BMI measurements.
* **Multithreaded Analytics:** Run background analysis to calculate automated progress intelligence reports.
* **Coaching Chat:** Direct messaging channel with clients.

### 🏃 3. Member (`USER`)
* **Self Registration & Profile:** Onboard with fitness goals.
* **Workout Programs:** Browse approved catalog, view detailed exercises, and follow active routines.
* **Progress Logging:** Log weigh-ins, height, body tape measurements, and track BMI category transitions.
* **Progress Analytics:** Review historical trends and view automated performance reports.
* **Direct Coaching:** Consult and message personal trainers.
* **Notification Center:** Real-time notifications for plan approvals, new messages, and milestones.

---

## 5. Database Schema & Supabase Setup

### Supabase Project Details
* **Project Name:** `Online Fitness Training Platform`
* **Project ID:** `kclihlnwczjifrmakfsp`
* **Direct JDBC Host:** `db.kclihlnwczjifrmakfsp.supabase.co:5432`

### Step 1: Execute Schema in Supabase
1. Open your [Supabase Dashboard](https://supabase.com/dashboard/project/kclihlnwczjifrmakfsp).
2. Navigate to **SQL Editor** in the left sidebar.
3. Open [`schema.sql`](file:///d:/Online%20Fitness%20Training%20Platform/schema.sql) from the project root, paste it into the SQL editor, and click **Run**.
4. All 9 relational tables and indexes (`users`, `workout_plans`, `exercises`, `plan_exercises`, `progress`, `messages`, `notifications`, `system_settings`, `user_workout_plans`) will be created.

### Step 2: Seed Initial Data
1. Open [`seed.sql`](file:///d:/Online%20Fitness%20Training%20Platform/seed.sql) in the project root.
2. Paste the contents into the Supabase **SQL Editor** and click **Run**.
3. Default admin, coach, trainee, workout plans, and exercise routines will be populated.

### Step 3: Configure Database Credentials
Edit [`src/main/resources/db.properties`](file:///d:/Online%20Fitness%20Training%20Platform/src/main/resources/db.properties):
```properties
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://db.kclihlnwczjifrmakfsp.supabase.co:5432/postgres?sslmode=require
db.username=postgres
db.password=YOUR_SUPABASE_DB_PASSWORD
```
> **Tip:** You can also pass credentials via environment variables without modifying the file:
> `set DB_PASSWORD=your_database_password`

---

## 6. Pre-Configured Demo Accounts (For Viva Evaluation)

| Role | Email | Password | Dashboard URL |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@fittrack.com` | `admin123` | `/admin/dashboard` |
| **Trainer** | `trainer@fittrack.com` | `trainer123` | `/trainer/dashboard` |
| **Member** | `user@fittrack.com` | `user123` | `/user/dashboard` |

> The login page includes **one-click quick credential filler buttons** so evaluators can inspect each role in seconds!

---

## 7. How to Build & Run

### Prerequisites
* JDK 17 or higher (`java -version`)
* Apache Tomcat 10.x / 10.1+ (supports Jakarta EE 9/10)

### Option A: Build WAR with Maven
In the project root directory, run:
```powershell
.\mvnw.cmd clean package
```
This produces the deployable artifact:
```
target/fittrack.war
```
Copy `target/fittrack.war` into your Tomcat `webapps/` directory and start Tomcat. Open:
`http://localhost:8080/fittrack`

### Option B: Run via IntelliJ IDEA
1. Open IntelliJ IDEA &rarr; **File** &rarr; **Open** &rarr; select `d:\Online Fitness Training Platform`.
2. Add Tomcat Local Configuration (**Run** &rarr; **Edit Configurations** &rarr; **+** &rarr; **Tomcat Server** &rarr; **Local**).
3. In the **Deployment** tab, add `fittrack-platform:war exploded` with application context `/fittrack`.
4. Click **Run** or **Debug**.

---

## 8. Project Structure

```
d:/Online Fitness Training Platform/
├── pom.xml                               # Maven Project Descriptor
├── mvnw.cmd                              # Maven Wrapper Script
├── schema.sql                            # PostgreSQL DDL for Supabase
├── seed.sql                              # Seed data with default users & plans
├── README.md                             # Comprehensive Documentation
├── presentation_slides.md                # 12 Academic Slides for Viva Review
└── src/
    ├── main/
    │   ├── java/com/fittrack/
    │   │   ├── dao/                      # DAO Pattern with JDBC & Generics
    │   │   │   ├── GenericDAO.java
    │   │   │   ├── UserDAO.java
    │   │   │   ├── WorkoutPlanDAO.java
    │   │   │   ├── ExerciseDAO.java
    │   │   │   ├── ProgressDAO.java
    │   │   │   ├── MessageDAO.java
    │   │   │   ├── NotificationDAO.java
    │   │   │   └── SystemSettingsDAO.java
    │   │   ├── exception/                # Custom Business Exceptions
    │   │   │   ├── AuthenticationException.java
    │   │   │   ├── DatabaseException.java
    │   │   │   ├── UserNotFoundException.java
    │   │   │   └── ValidationException.java
    │   │   ├── model/                    # OOP Models, Interfaces, Hierarchy
    │   │   │   ├── Authenticatable.java
    │   │   │   ├── DashboardAccess.java
    │   │   │   ├── User.java (Abstract)
    │   │   │   ├── Admin.java
    │   │   │   ├── Trainer.java
    │   │   │   ├── FitnessUser.java
    │   │   │   ├── WorkoutPlan.java
    │   │   │   ├── Exercise.java
    │   │   │   ├── Progress.java
    │   │   │   ├── Message.java
    │   │   │   ├── Notification.java
    │   │   │   ├── SystemSetting.java
    │   │   │   └── UserWorkoutPlan.java
    │   │   ├── service/                  # Business & Validation Logic
    │   │   │   ├── UserService.java
    │   │   │   ├── WorkoutService.java
    │   │   │   ├── ProgressService.java
    │   │   │   ├── MessageService.java
    │   │   │   └── NotificationService.java
    │   │   ├── servlet/                  # HTTP Request Controllers & RBAC Filter
    │   │   │   ├── AuthFilter.java
    │   │   │   ├── LoginServlet.java
    │   │   │   ├── RegisterServlet.java
    │   │   │   ├── LogoutServlet.java
    │   │   │   ├── AdminServlet.java
    │   │   │   ├── TrainerServlet.java
    │   │   │   ├── UserDashboardServlet.java
    │   │   │   ├── WorkoutServlet.java
    │   │   │   ├── ProgressServlet.java
    │   │   │   ├── MessageServlet.java
    │   │   │   └── NotificationServlet.java
    │   │   ├── thread/                   # Multithreading & Synchronization
    │   │   │   ├── NotificationThread.java
    │   │   │   └── ProgressReportThread.java
    │   │   └── util/                     # Utilities & Centralized JDBC
    │   │       ├── DBConnection.java
    │   │       ├── PasswordUtil.java
    │   │       └── ValidationUtil.java
    │   ├── resources/
    │   │   └── db.properties             # Database Config
    │   └── webapp/                       # JSP Pages & Assets
    │       ├── WEB-INF/web.xml
    │       ├── css/style.css
    │       ├── js/main.js
    │       ├── index.jsp
    │       ├── login.jsp
    │       ├── register.jsp
    │       ├── admin/
    │       │   ├── dashboard.jsp
    │       │   ├── users.jsp
    │       │   ├── workouts.jsp
    │       │   └── settings.jsp
    │       ├── trainer/
    │       │   ├── dashboard.jsp
    │       │   ├── workouts.jsp
    │       │   ├── progress.jsp
    │       │   └── messages.jsp
    │       └── user/
    │           ├── dashboard.jsp
    │           ├── workouts.jsp
    │           ├── workout_details.jsp
    │           ├── progress.jsp
    │           ├── messages.jsp
    │           └── notifications.jsp
    └── test/java/com/fittrack/
        └── FitTrackCoreTest.java         # JUnit 5 Test Suite
```

---

## 9. Viva Questions & Answers

**Q1: How is OOP demonstrated in this project?**  
> We implemented an abstract base class `User` that provides encapsulation and abstract polymorphic contracts (`getRoleTitle()`, `getDashboardUrl()`). `Admin`, `Trainer`, and `FitnessUser` extend `User`, overriding these methods. Additionally, contracts are established via `Authenticatable` and `DashboardAccess` interfaces.

**Q2: Why did you use pure JDBC instead of Hibernate or Spring Data?**  
> Pure JDBC provides explicit control over query optimization, connection life-cycle, and transactional integrity via `PreparedStatement` and `ResultSet`. It prevents ORM overhead and demonstrates core understanding of database connectivity and resource management (`try-with-resources`).

**Q3: Where and why is Multithreading used?**  
> Multithreading is implemented in two realistic scenarios:
> 1. `NotificationThread` (implements `Runnable`) processes notifications asynchronously in the background so HTTP requests are never delayed. Access to the job queue is thread-safe using `synchronized` blocks and `wait()/notify()`.
> 2. `ProgressReportThread` (extends `Thread`) calculates heavy metric aggregations (total transformation, BMI changes, milestone analytics) off the main request thread and stores results in a `synchronized` cache.
