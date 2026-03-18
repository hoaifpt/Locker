namespace Locker.Backend.Domain.Entities;

public abstract class BaseEntity
{
    /// <summary>
    /// Unique identifier using GUID v7 (timestamp-based, sortable)
    /// Auto-generated when entity is instantiated
    /// </summary>
    public string Id { get; set; } = Guid.CreateVersion7().ToString();
}
