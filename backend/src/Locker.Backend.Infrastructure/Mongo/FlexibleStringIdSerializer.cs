using MongoDB.Bson;
using MongoDB.Bson.Serialization;

namespace Locker.Backend.Infrastructure.Mongo;

/// <summary>
/// Custom serializer that handles both ObjectId and String formats for backwards compatibility.
/// Deserializes ObjectId (from old data) or String (from new GUID7 data).
/// Always serializes as String when writing.
/// </summary>
public class FlexibleStringIdSerializer : IBsonSerializer<string>
{
    public Type ValueType => typeof(string);

    public string Deserialize(BsonDeserializationContext context, BsonDeserializationArgs args)
    {
        var bsonType = context.Reader.CurrentBsonType;

        return bsonType switch
        {
            BsonType.ObjectId => context.Reader.ReadObjectId().ToString(),
            BsonType.String => context.Reader.ReadString(),
            _ => throw new InvalidOperationException($"Cannot deserialize {bsonType} to Id (expected ObjectId or String)")
        };
    }

    public void Serialize(BsonSerializationContext context, BsonSerializationArgs args, string? value)
    {
        if (string.IsNullOrEmpty(value))
        {
            context.Writer.WriteNull();
        }
        else
        {
            context.Writer.WriteString(value);
        }
    }

    object? IBsonSerializer.Deserialize(BsonDeserializationContext context, BsonDeserializationArgs args)
    {
        return Deserialize(context, args);
    }

    void IBsonSerializer.Serialize(BsonSerializationContext context, BsonSerializationArgs args, object? value)
    {
        Serialize(context, args, (string?)value);
    }
}
