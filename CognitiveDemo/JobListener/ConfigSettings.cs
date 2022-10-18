using Microsoft.AspNetCore.SignalR;
using System.Text.Json.Serialization;

namespace JobListener
{
    public class ConfigSettings
    {
        public const string ComputerVisionEdnpoint = "ComputerVisionEdnpoint";
        public const string ComputerVisionKey = "ComputerVisionKey";


        public static string StorageKeyNameInSecretStore
        {
            get
            {
                return Environment.GetEnvironmentVariable("StorageKey") ?? "StorageKey";
            }
        }
        public static string StorageAccountNameInSecretStore
        {
            get
            {
                return Environment.GetEnvironmentVariable("StorageAccountName") ?? "StorageAccountName";
            }
        }

        public static string StorageContainerNameInSecretStore
        {
            get
            {
                return Environment.GetEnvironmentVariable("ContainerName") ?? "ContainerName";
            }
        }

        
        public static string SecretStoreName
        {
            get
            {
                return Environment.GetEnvironmentVariable("SecretStoreName") ?? "xeniel-dapr-secret-store";
            }
        }
        public static string PubsubName
        {
            get
            {
                return Environment.GetEnvironmentVariable("PubSubName") ?? "xeniel-dapr-servicebus-pubsub";
            }
        }

        public static string TopicName
        {
            get
            {
                return Environment.GetEnvironmentVariable("TopicName") ?? "xeniel-tpic";
            }
        }

        public static string Route
        {
            get
            {
                return "OnFileUploaded";
            }
        }

        public static DaprSubscription Subscription
        {
            get
            {
                return new DaprSubscription(
                    PubsubName: ConfigSettings.PubsubName,
                    Topic: ConfigSettings.TopicName,
                    Route: ConfigSettings.Route);
            }
        }
    }

    public record DaprSubscription(
      [property: JsonPropertyName("pubsubname")] string PubsubName,
      [property: JsonPropertyName("topic")] string Topic,
      [property: JsonPropertyName("route")] string Route);

    public record BlobDetails(string contentType, int contentLength, Uri url, string blobType, string requestId, string clientRequestId, string api, string eTag);
    public record BlobItem(string id, string eventType, string subject, BlobDetails data, DateTime eventTime);
}
