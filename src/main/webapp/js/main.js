// ==========================================================
// FitTrack - Client JavaScript Interactions
// ==========================================================

document.addEventListener("DOMContentLoaded", function () {
  // Auto-dismiss alert banners after 5 seconds
  const alerts = document.querySelectorAll(".alert");
  alerts.forEach(function (alert) {
    setTimeout(function () {
      alert.style.opacity = "0";
      alert.style.transition = "opacity 0.4s ease";
      setTimeout(function () {
        alert.remove();
      }, 400);
    }, 5000);
  });

  // Scroll chat messages to bottom
  const chatMessages = document.querySelector(".chat-messages");
  if (chatMessages) {
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }
});

// Confirmation helper for destructive actions (e.g. deletion, rejection)
function confirmAction(message) {
  return confirm(message || "Are you sure you want to proceed?");
}

// Quick fill helper for presentation/evaluation demo on login page
function fillCredentials(email, password) {
  const emailInput = document.getElementById("email");
  const passwordInput = document.getElementById("password");
  if (emailInput && passwordInput) {
    emailInput.value = email;
    passwordInput.value = password;
  }
}
