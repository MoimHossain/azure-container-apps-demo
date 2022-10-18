using Azure.Storage.Blobs;
using Azure.Storage;
using Dapr.Client;
using JobListener;
using Microsoft.AspNetCore.Builder;
using Azure.Identity;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision.Models;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision;
using Microsoft.AspNetCore.DataProtection.KeyManagement;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


using var daprClient = new DaprClientBuilder().Build();



app.MapGet("/dapr/subscribe", async () => {
    Console.WriteLine("################ >>> We are subscribing the call !!! ");
    await Task.CompletedTask;
    return Results.Json(new DaprSubscription[] { ConfigSettings.Subscription });
});

app.MapPost(ConfigSettings.Route, async c => {
    Console.WriteLine("#### >>> We got called !!! ");

    var accountKey = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.StorageKeyNameInSecretStore);
    var accountName = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.StorageAccountNameInSecretStore);
    var containerName = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.StorageContainerNameInSecretStore);

    var ComputerVisionEdnpoint = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.ComputerVisionEdnpoint);
    var computerVisionKey = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.ComputerVisionKey);


    Console.WriteLine($"######## >>>> storage key: {string.Join(", ", accountKey)}");
    Console.WriteLine($"######## >>>> storage name: {string.Join(", ", accountName)}");
    Console.WriteLine($"######## >>>> storage key: {string.Join(", ", accountKey)}");
    Console.WriteLine($"######## >>>> storage nane: {string.Join(", ", accountName)}");
    Console.WriteLine($"######## >>>> storage key: {string.Join(", ", containerName)}");


    Console.WriteLine($"######## >>>> ComputerVisionEdnpoint: {string.Join(", ", ComputerVisionEdnpoint)}");
    Console.WriteLine($"######## >>>> computerVisionKey: {string.Join(", ", computerVisionKey)}");

    var item = await c.Request.ReadFromJsonAsync<BlobItem>();
    if (item != null)
    {
        Console.WriteLine(item.subject);
        Console.WriteLine(item.data.blobType);
        Console.WriteLine(item.data.eTag);
        Console.WriteLine(item.data.url);


        var itemName = Path.GetFileName(item.data.url.ToString());


        var blobServiceClient = new BlobServiceClient(item.data.url, new StorageSharedKeyCredential(accountName, accountKey));
        
        var bClient = blobServiceClient.GetBlobContainerClient("xeniels").GetBlobClient(itemName);
        using var memStream = new MemoryStream();
        await bClient.DownloadToAsync(memStream);

        Console.WriteLine("############>>>>>>>>>>>>>>> length" + memStream.Length);
        ComputerVisionClient client =
              new ComputerVisionClient(new ApiKeyServiceClientCredentials(computerVisionKey))
              { Endpoint = ComputerVisionEdnpoint };

        var features = new List<VisualFeatureTypes?>()
            {
                VisualFeatureTypes.Categories, VisualFeatureTypes.Description,
                VisualFeatureTypes.Faces, VisualFeatureTypes.ImageType,
                VisualFeatureTypes.Tags, VisualFeatureTypes.Adult,
                VisualFeatureTypes.Color, VisualFeatureTypes.Brands,
                VisualFeatureTypes.Objects
            };


        using var imageStream = new MemoryStream(memStream.ToArray());

        ImageAnalysis results = await client.AnalyzeImageInStreamAsync(imageStream, visualFeatures: features);
        if (null != results.Description && null != results.Description.Captions)
        {
            Console.WriteLine("Summary:");
            foreach (var caption in results.Description.Captions)
            {
                Console.WriteLine($"{caption.Text} with confidence {caption.Confidence}");
            }
            Console.WriteLine();
        }

        await daprClient.InvokeMethodAsync("xeniel-frontend", "notify", results);
    }
    c.Response.StatusCode = 200;
});

app.Run();



