using Microsoft.Identity.Client;
using System.Windows;

namespace CallingAProtectedAzureApi
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        private static string ClientId = "SomeClientId";

        public static PublicClientApplication PublicClientApp = new PublicClientApplication(ClientId);
    }
}
