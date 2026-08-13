namespace Locker.Backend.Application.Models;

public class AppSettings
{
    /// <summary>Base URL of the backend API, e.g. https://api.example.com or http://localhost:8080</summary>
    public string BaseUrl { get; set; } = "http://localhost:8080";
    
    /// <summary>Base URL of the frontend web app, e.g. https://app.example.com or http://localhost:5173</summary>
    public string FrontendUrl { get; set; } = "http://localhost:5173";
}
