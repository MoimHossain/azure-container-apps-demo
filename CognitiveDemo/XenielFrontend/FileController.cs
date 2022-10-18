using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace XenielFrontend
{
    [Route("api/[controller]")]
    [ApiController]
    public class FileController : ControllerBase
    {
        [HttpPost]
        public async Task<IActionResult> Post()
        {
            var uri = string.Empty;
            var files = Request.Form.Files;
            if (files != null && files.Any())            {
                var file = files[0];
                if(file != null)
                {
                    var blobClient = bc.GetBlobClient(file.FileName);
                    await blobClient.UploadAsync(
                        file.OpenReadStream(),
                        new BlobHttpHeaders
                        {
                            ContentType = file.ContentType
                        },
                        conditions: null);
                    
                    uri = blobClient.GenerateSasUri(Azure.Storage.Sas.BlobSasPermissions.Read, DateTime.UtcNow.AddMinutes(59)).ToString();
                }
            }
            return new JsonResult(new { uri });
        }

        public FileController(BlobContainerClient bc) { this.bc = bc; }
        private readonly BlobContainerClient bc;
    }
}
