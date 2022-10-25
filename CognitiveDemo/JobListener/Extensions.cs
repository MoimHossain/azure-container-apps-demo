using Azure.Storage.Blobs;
using Azure.Storage;
using Dapr.Client;

namespace JobListener
{
    public static class Extensions
    {
        public static async Task<string> GetSecretFromStateStoreAsync(this DaprClient daprClient, string secretName)
        {
            var dictionary = await daprClient.GetSecretAsync(ConfigSettings.SecretStoreName, secretName);
            return dictionary.FirstOrDefault().Value;
        }

        public static async Task<byte[]> GetBlobContentAsync(this BlobItem item, DaprClient daprClient)
        {
            var accountKey = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.StorageKeyNameInSecretStore);
            var accountName = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.StorageAccountNameInSecretStore);
            var itemName = Path.GetFileName(item.data.url.ToString());
            var blobServiceClient = new BlobServiceClient(item.data.url, new StorageSharedKeyCredential(accountName, accountKey));
            var bClient = blobServiceClient.GetBlobContainerClient("xeniels").GetBlobClient(itemName);
            using var memStream = new MemoryStream();
            await bClient.DownloadToAsync(memStream);
            return memStream.ToArray();
        }
    }
}
