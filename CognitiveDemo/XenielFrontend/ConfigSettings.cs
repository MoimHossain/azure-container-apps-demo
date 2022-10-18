namespace XenielFrontend
{
    public class ConfigSettings
    {
        public const string SignalRConnectionStringKey = "SignalRConnectionString";
        public static string SecretStoreName
        {
            get
            {
                return Environment.GetEnvironmentVariable("SecretStoreName") ?? "xeniel-dapr-secret-store";
            }
        }

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
    }
}
