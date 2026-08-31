class ApiConstants {
  // !!! IMPORTANT: Replace with your computer's local IP address and correct ports !!!

  // Base URL for the Node.js Backend (e.g., http://192.168.110.129:3000)
  static const String nodeBaseUrl = "http://192.168.29.154:3000";
  
  // Endpoint for uploading a card
  static const String uploadCardEndpoint = "$nodeBaseUrl/upload-card";
  
  // Endpoint for viewing all cards
  static const String allCardsEndpoint = "$nodeBaseUrl/allcards";

  static const String recentEndpoint = "$nodeBaseUrl/recent";

  // If you ever need the FastAPI URL in Flutter:
  static const String fastApiBaseUrl = "http://192.168.110.129:8000";
}