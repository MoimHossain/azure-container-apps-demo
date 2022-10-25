using Dapr.Client;
using JobListener;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision.Models;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();
using var daprClient = new DaprClientBuilder().Build();

app.MapGet("/dapr/subscribe", async () => {    
    await Task.CompletedTask;
    return Results.Json(new DaprSubscription[] { ConfigSettings.Subscription });
});

app.MapPost(ConfigSettings.Route, async c => {
    var item = await c.Request.ReadFromJsonAsync<BlobItem>();
    if (item != null)
    {
        var imageContent = await item.GetBlobContentAsync(daprClient);
        var ComputerVisionEdnpoint = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.ComputerVisionEdnpoint);
        var computerVisionKey = await daprClient.GetSecretFromStateStoreAsync(ConfigSettings.ComputerVisionKey);
        var client = new ComputerVisionClient(new ApiKeyServiceClientCredentials(computerVisionKey)) { Endpoint = ComputerVisionEdnpoint };
        
        var results = await client.AnalyzeImageInStreamAsync(new MemoryStream(imageContent), visualFeatures: new List<VisualFeatureTypes?>()
            {
                VisualFeatureTypes.Categories, VisualFeatureTypes.Description,
                VisualFeatureTypes.Faces, VisualFeatureTypes.ImageType,
                VisualFeatureTypes.Tags, VisualFeatureTypes.Adult,
                VisualFeatureTypes.Color, VisualFeatureTypes.Brands,
                VisualFeatureTypes.Objects
            });                
        await daprClient.InvokeMethodAsync("xeniel-frontend", "notify", results);        
    }
    c.Response.StatusCode = 200;
});

app.Run();



