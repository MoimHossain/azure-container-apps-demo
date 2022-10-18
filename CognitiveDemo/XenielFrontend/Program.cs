

using Azure.Storage.Blobs;
using Dapr.Client;
using Google.Api;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision.Models;
using XenielFrontend;

using var daprClient = new DaprClientBuilder().Build();
var builder = WebApplication.CreateBuilder(args);


builder.Services.AddRazorPages();
builder.Services.AddSignalR().AddAzureSignalR(await daprClient
    .GetSecretFromStateStoreAsync(ConfigSettings.SignalRConnectionStringKey));
builder.Services.AddSingleton<BlobContainerClient>(await daprClient.GetBlobContainerClientAsync());

var app = builder.Build();

app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();
app.MapRazorPages();
app.MapControllers();


app.UseEndpoints(endpoints =>
{
    endpoints.MapHub<XenielHub>("/xeniel");

    endpoints.MapPost("/notify", async c => {
        var resultObject = await c.Request.ReadFromJsonAsync<ImageAnalysis>();        
        var hubContext = endpoints.ServiceProvider.GetRequiredService<IHubContext<XenielHub>>();
        await hubContext.Clients.All.SendAsync("broadcastMessage", resultObject);
    });
});

app.Run();
