namespace Locker.Backend.Application.Models;

public class AppSettings
{
    /// <summary>Base URL of the backend API, e.g. https://api.example.com or http://localhost:8080</summary>
    public string BaseUrl { get; set; } = "http://localhost:8080";
}
