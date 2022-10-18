using Azure.Storage;
using Azure.Storage.Blobs;
using Dapr.Client;

namespace XenielFrontend
{
    public static class Extensions
    {
        public static async Task<string> GetSecretFromStateStoreAsync(
            this DaprClient daprClient, string secretName)
        {
            var dictionary = await daprClient.GetSecretAsync(ConfigSettings.SecretStoreName, secretName);
            return dictionary.FirstOrDefault().Value;
        }

        public static async Task<BlobContainerClient> GetBlobContainerClientAsync(this DaprClient daprClient)
        {
            var accountName = (await daprClient.GetSecretAsync(ConfigSettings.SecretStoreName, ConfigSettings.StorageAccountNameInSecretStore)).First().Value;
            var accountKey = (await daprClient.GetSecretAsync(ConfigSettings.SecretStoreName, ConfigSettings.StorageKeyNameInSecretStore)).First().Value;
            var containerName = (await daprClient.GetSecretAsync(ConfigSettings.SecretStoreName, ConfigSettings.StorageContainerNameInSecretStore)).First().Value;

            return new BlobServiceClient(
                new Uri($"https://{accountName}.blob.core.windows.net"),
                new StorageSharedKeyCredential(accountName, accountKey))
                .GetBlobContainerClient(containerName);
        }
    }
}
