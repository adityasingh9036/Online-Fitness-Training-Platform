package com.fittrack;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;
import java.io.IOException;

/**
 * Embedded Tomcat 10 development server for FitTrack.
 * Enables running the application with 'npm run dev' or 'mvn compile exec:java'
 * without needing an external Apache Tomcat installation.
 */
public class DevServer {

    public static class RootRedirectServlet extends HttpServlet {
        @Override
        protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
            String uri = req.getRequestURI();
            if (uri == null || uri.equals("/") || uri.isEmpty()) {
                resp.sendRedirect("/fittrack/");
            } else {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }

    public static void main(String[] args) {
        try {
            int port = 8080;
            String portProp = System.getProperty("server.port");
            if (portProp == null) {
                portProp = System.getenv("PORT");
            }
            if (portProp != null && !portProp.trim().isEmpty()) {
                port = Integer.parseInt(portProp.trim());
            }

            File baseDir = new File("target/tomcat-embed");
            if (!baseDir.exists()) {
                baseDir.mkdirs();
            }

            Tomcat tomcat = new Tomcat();
            tomcat.setBaseDir(baseDir.getAbsolutePath());
            tomcat.setPort(port);
            tomcat.getConnector(); // Initialize default HTTP connector

            File webappDir = new File("src/main/webapp");
            if (!webappDir.exists()) {
                throw new IllegalStateException("Webapp directory not found at " + webappDir.getAbsolutePath());
            }

            // Mount the FitTrack web application at /fittrack
            StandardContext ctx = (StandardContext) tomcat.addWebapp("/fittrack", webappDir.getAbsolutePath());

            // CRITICAL: Ensure webapp class loader delegates to the current application classloader
            ctx.setParentClassLoader(DevServer.class.getClassLoader());

            // Mount compiled classes and src/main/resources to /WEB-INF/classes
            File additionWebInfClasses = new File("target/classes");
            if (!additionWebInfClasses.exists()) {
                additionWebInfClasses.mkdirs();
            }
            WebResourceRoot resources = new StandardRoot(ctx);
            resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
                    additionWebInfClasses.getAbsolutePath(), "/"));

            File resourcesDir = new File("src/main/resources");
            if (resourcesDir.exists()) {
                resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
                        resourcesDir.getAbsolutePath(), "/"));
            }
            ctx.setResources(resources);

            // Add root context redirect: http://localhost:8080/ -> http://localhost:8080/fittrack/
            Context rootCtx = tomcat.addContext("", baseDir.getAbsolutePath());
            rootCtx.setParentClassLoader(DevServer.class.getClassLoader());
            Tomcat.addServlet(rootCtx, "RootRedirectServlet", new RootRedirectServlet());
            rootCtx.addServletMappingDecoded("/", "RootRedirectServlet");

            System.out.println("==================================================================");
            System.out.println("   FitTrack Development Server Starting...                        ");
            System.out.println("   Web Application URL: http://localhost:" + port + "/fittrack/   ");
            System.out.println("   Root Redirect URL:   http://localhost:" + port + "/            ");
            System.out.println("   Pre-configured Demo Accounts:                                  ");
            System.out.println("     Admin:   admin@fittrack.com   / admin123                     ");
            System.out.println("     Trainer: trainer@fittrack.com / trainer123                   ");
            System.out.println("     User:    user@fittrack.com    / user123                      ");
            System.out.println("   Press Ctrl + C in this terminal to stop the server             ");
            System.out.println("==================================================================");

            tomcat.start();
            System.out.println(">> FitTrack Dev Server is running on port " + port + "!");
            tomcat.getServer().await();

        } catch (Exception e) {
            System.err.println("Failed to start FitTrack Dev Server: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
