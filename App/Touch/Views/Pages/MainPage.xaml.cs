using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Touch.Models;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.Storage;
using Windows.Storage.Pickers;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Imaging;
using Windows.UI.Xaml.Navigation;
using Windows.Web.Http;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace Touch
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private StorageFile _file;

        public MainPage()
        {
            this.InitializeComponent();
        }

        private async void SelectButton_ClickAsync(object sender, RoutedEventArgs e)
        {
            var picker = new FileOpenPicker
            {
                ViewMode = PickerViewMode.Thumbnail,
                SuggestedStartLocation = PickerLocationId.PicturesLibrary
            };
            picker.FileTypeFilter.Add(".jpg");
            picker.FileTypeFilter.Add(".jpeg");
            picker.FileTypeFilter.Add(".png");
            picker.FileTypeFilter.Add(".bmp");
            _file = await picker.PickSingleFileAsync();
            if (_file != null)
            {
                PathText.Text = _file.Path;
                using (var fileStream = await _file.OpenAsync(FileAccessMode.Read))
                {
                    var bitmapImage = new BitmapImage();
                    await bitmapImage.SetSourceAsync(fileStream);
                    MyImage.Source = bitmapImage;
                }
            }
        }

        private async void UploadButton_ClickAsync(object sender, RoutedEventArgs e)
        {
            if (PathText.Text != "")
            {
                using (var httpClient = new HttpClient())
                {
                    using (var fileStream = await _file.OpenAsync(FileAccessMode.Read))
                    {
                        var streamContent = new HttpStreamContent(fileStream);
                        var result = await httpClient.PostAsync(new Uri("http://localhost:1696"), streamContent);
                        var content = await result.Content.ReadAsStringAsync();
                        var true_content = String.Join("", content.Split(new[] { '\r', '\n' }).Skip(2));
                        var labels = Label.FromJson(true_content)[0];
                        if (labels.Count == 0)
                            LabelResultText.Text = "unrecognized";
                        else
                            LabelResultText.Text = String.Join(", ", labels.Select(delegate (Label label) { return label.Name; }));
                    }
                }
            }
        }
    }
}
