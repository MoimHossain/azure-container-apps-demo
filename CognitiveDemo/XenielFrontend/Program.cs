using Azure.Storage.Blobs;
using Dapr.Client;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision.Models;
using System.Text.Json;
using XenielFrontend;

using var daprClient = new DaprClientBuilder().Build();
var builder = WebApplication.CreateBuilder(args);

// Configure the web server to listen on port 80 when in a container
if (builder.Environment.IsProduction() || Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true")
{
    builder.WebHost.UseUrls("http://*:80");
}

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





app.MapHub<XenielHub>("/xeniel");
app.MapPost("/notify", async c => {
    var resultObject = await c.Request.ReadFromJsonAsync<ImageAnalysis>();
    var hubContext = c.RequestServices.GetRequiredService<IHubContext<XenielHub>>();
    await hubContext.Clients.All.SendAsync("broadcastMessage", resultObject);
});


app.MapGet("/color", async c => { await c.Response.WriteAsync(JsonSerializer.Serialize(new { color = "#0000FF" })); });

app.MapGet("/health", async c => {
    //throw new InvalidOperationException("An error has occured");
    await c.Response.WriteAsync(JsonSerializer.Serialize(new { success = true }));
});

app.Run();
