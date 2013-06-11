using System.Windows;
using System.Windows.Controls;

namespace basicwpf
{
  public static class Password
  {
    public const string PASSWORD = "1337";
  }

  public class Check
  {
    public bool IsPasswordOK(string passwd)
    {
      if (passwd == Password.PASSWORD)
        return true;
      return false;
    }
  }

  /// <summary>
  /// Interaction logic for MainWindow.xaml
  /// </summary>
  public partial class MainWindow : Window
  {
    public MainWindow()
    {
      InitializeComponent();
    }

    private void TextBox_TextChanged_(object sender, TextChangedEventArgs e)
    {
      status_.Clear();
    }

    private void Button_Click_(object sender, RoutedEventArgs e)
    {
      Check c = new Check();
      string pass = passwd_.Text;
      passwd_.Clear();
      status_.Text = c.IsPasswordOK(pass) ? "Pwnies!" : "Nope... no pwnie.";
    }
  }
}
