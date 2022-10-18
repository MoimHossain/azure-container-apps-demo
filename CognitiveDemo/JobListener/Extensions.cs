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
    }
}
