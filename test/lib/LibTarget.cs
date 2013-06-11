using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Target
{
  public class LibTarget
  {
    public static void Main(string[] args)
    {
      if (args.Length != 1)
      {
        Console.WriteLine("Usage: LibTarget password");
        return;
      }

      Check c = new Check();
      if (c.IsPasswordOK(args.First()))
        Console.WriteLine("Pwnies!");
      else
        Console.WriteLine("Nope... no pwnie.");
    }
  }
}
