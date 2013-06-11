using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Target
{
  public class StandaloneTarget
  {
    public static void Main(string[] args)
    {
      if (args.Length != 1)
      {
        Console.WriteLine("Usage: StandaloneTarget password");
        return;
      }

      Check c = new Check();
      if (c.IsPasswordOK(args.First()))
        Console.WriteLine("Pwnies!");
      else
        Console.WriteLine("Nope... no pwnie.");
    }
  }
  
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
}
