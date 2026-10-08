package com.fittrack.servlet;

import com.fittrack.dao.UserDAO;
import com.fittrack.model.Message;
import com.fittrack.model.User;
import com.fittrack.service.MessageService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet handling User-Trainer communication conversations and messaging.
 */
@WebServlet(name = "MessageServlet", urlPatterns = {
        "/user/messages",
        "/user/messages/send"
})
public class MessageServlet extends HttpServlet {

    private final MessageService messageService = new MessageService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        List<User> trainers = userDAO.findByRole("TRAINER");
        request.setAttribute("trainers", trainers);

        String trainerIdParam = request.getParameter("trainerId");
        int activeTrainerId = (trainerIdParam != null && !trainerIdParam.isEmpty()) 
                ? Integer.parseInt(trainerIdParam) 
                : (!trainers.isEmpty() ? trainers.get(0).getId() : 0);

        if (activeTrainerId > 0) {
            List<Message> conversation = messageService.getConversation(currentUser.getId(), activeTrainerId);
            request.setAttribute("activeTrainerId", activeTrainerId);
            request.setAttribute("conversation", conversation);
        }

        request.getRequestDispatcher("/user/messages.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            int trainerId = Integer.parseInt(request.getParameter("trainerId"));
            String messageText = request.getParameter("message");

            messageService.sendMessage(currentUser.getId(), trainerId, messageText);
            response.sendRedirect(request.getContextPath() + "/user/messages?trainerId=" + trainerId + "&success=Message+sent");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/user/messages?error=" + e.getMessage());
        }
    }
}
