# School Management Portal

A Java-based web application for managing core school administration
activities through a centralized portal. The project uses Java Servlets
and JSP for the web layer and MySQL for data storage.

## Features

-   Admin registration and login
-   Session-based login and logout
-   Admin dashboard with school-related summary cards
-   Student management: add, view, edit, and delete students
-   Teacher management: add, view, edit, and delete teachers
-   Class and section management
-   Subject management
-   MySQL database connectivity through JDBC
-   Responsive pages styled with Bootstrap

> Note: The project is under development. Some dashboard items may be
> displayed before their complete modules are implemented.

## Technology Stack

-   **Backend:** Java, Jakarta Servlets, JSP
-   **Database:** MySQL
-   **Database connectivity:** JDBC / MySQL Connector/J
-   **Web server:** Apache Tomcat 11
-   **Frontend:** HTML, CSS, Bootstrap 5, Bootstrap Icons
-   **IDE:** Eclipse

## Project Structure

``` text
SchoolManagementPortal/
└── src/
    └── main/
        ├── java/com/school/
        │   ├── controller/   # Servlet controllers
        │   ├── dao/          # Database access classes
        │   ├── model/        # Java model classes
        │   └── util/         # Database connection utilities
        └── webapp/
            ├── admin/        # Admin JSP pages
            ├── login.html
            ├── register.html
            └── index.html
```

## Requirements

Install or configure:

1.  JDK compatible with your Tomcat 11 installation (Java 17 or later is
    recommended).
2.  Apache Tomcat 11.
3.  MySQL Server.
4.  Eclipse IDE for Enterprise Java and Web Developers, or another
    Jakarta Servlet-compatible IDE.
5.  MySQL Connector/J. The project includes a connector JAR under
    `src/main/webapp/WEB-INF/lib/`.

## Setup and Run

### 1. Clone the repository

``` bash
git clone https://github.com/Dimpy2612/School-Management-Portal.git
cd School-Management-Portal
```

### 2. Create the database

Create the database in MySQL:

``` sql
CREATE DATABASE school_management_portal;
```

The application also requires the database tables used by the DAO
classes and servlets. Create/import the project schema and any required
initial records before running the application. A complete database
export is not currently included in this repository.

### 3. Configure database credentials

The database connection URL is:

``` text
jdbc:mysql://localhost:3306/school_management_portal
```

Configure these environment variables in the Eclipse/Tomcat run
configuration (or in the environment used to start the server):

-   `DB_USER` --- your MySQL username
-   `DB_PASSWORD` --- your MySQL password

Do not commit real database passwords, API keys, or other secrets to
GitHub.

### 4. Import into Eclipse

1.  Open Eclipse.
2.  Select **File → Import → Existing Projects into Workspace**.
3.  Choose the cloned `School-Management-Portal` folder.
4.  Add/configure Apache Tomcat 11 in the **Servers** view.
5.  Ensure the project uses the Jakarta EE web facet and the MySQL
    Connector/J library is available.
6.  Start the server and run the project on Tomcat.

Open the local URL shown by Eclipse/Tomcat. The context path is usually
based on the project name, for example:

``` text
http://localhost:8080/SchoolManagementPortal/
```

If your Eclipse deployment uses a different context path, use the URL
shown in the server console.

## Security Notes

-   Use environment variables or a local, untracked configuration file
    for database credentials.
-   Never publish real passwords or tokens.
-   For production use, password hashing (for example, BCrypt),
    server-side validation, authorization checks, and secure session
    settings should be reviewed and completed.
-   Use a non-root MySQL account with only the permissions the
    application needs.

## Current Status

The project currently contains the initial admin workflow and CRUD pages
for students, teachers, classes, sections, and subjects. Attendance,
exams, fees, notices, reports, and other modules may require further
implementation and testing.

## Author

**Dimpy Garg**

## Repository

[School Management Portal on
GitHub](https://github.com/Dimpy2612/School-Management-Portal)
