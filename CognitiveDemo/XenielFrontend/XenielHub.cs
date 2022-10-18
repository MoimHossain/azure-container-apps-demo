using Google.Api;
using Microsoft.AspNetCore.SignalR;

namespace XenielFrontend
{
    public class XenielHub : Hub
    {
        public Task BroadcastMessage(object message) =>
            Clients.All.SendAsync("broadcastMessage", message);
    }
}
