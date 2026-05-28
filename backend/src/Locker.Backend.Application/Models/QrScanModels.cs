namespace Locker.Backend.Application.Models;

public class QrScanRequest
{
    public string QrCode { get; set; } = string.Empty;
}

public class QrScanResultDto
{
    public string Id { get; set; } = string.Empty;
    public string QrCode { get; set; } = string.Empty;
    public string? LockerId { get; set; }
    public string? LockerCode { get; set; }
    public DateTime ScannedAt { get; set; }
    public bool IsValid { get; set; }
}
