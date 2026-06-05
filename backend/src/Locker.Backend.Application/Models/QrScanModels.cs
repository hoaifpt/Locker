namespace Locker.Backend.Application.Models;

public class QrScanRequest
{
    public string QrCode { get; set; } = string.Empty;
}

public class QrScanResultDto
{
    public Guid Id { get; set; }
    public string QrCode { get; set; } = string.Empty;
    public Guid? LockerId { get; set; }
    public string? LockerCode { get; set; }
    public DateTime ScannedAt { get; set; }
    public bool IsValid { get; set; }
}
