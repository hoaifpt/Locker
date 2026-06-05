using Locker.Backend.Domain.Enums;
using System;

namespace Locker.Backend.Application.Models;

public class SendReceiveOrderDto
{
    public Guid Id { get; set; }
    public Guid SenderId { get; set; }
    public string ReceiverPhone { get; set; } = string.Empty;
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public SendReceiveStatus Status { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
}
