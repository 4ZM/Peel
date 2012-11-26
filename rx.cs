/**
* Copyright (C) 2012 Anders Sundman <anders@4zm.org>
*
* This file is part of Peel - Strong Name removal tool.
*
* Peel is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Peel is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Peel. If not, see <http://www.gnu.org/licenses/>.
*/

using System;

namespace Rx
{
  using System.IO;
  using System.Text.RegularExpressions;

  ///
  /// Regex search and replace
  ///
  public class Program
  {
    private static void Main(string[] args)
    {
      string pattern;
      string replace = String.Empty;
      string inFile;
      string outFile;

      if (args.Length == 3)
      {
        pattern = args[0];
        inFile = args[1];
        outFile = args[2];
      }
      else if (args.Length == 4)
      {
        pattern = args[0];
        replace = args[1];
        inFile = args[2];
        outFile = args[3];
      }
      else
      {
        PrintUsage_();
        return;
      }

      if (!File.Exists(inFile))
      {
        Console.WriteLine("Input file " + inFile + " doesn't exist.");
        PrintUsage_();
        return;
      }

      string text;
      using (StreamReader sr = new StreamReader(inFile))
      {
        string original = sr.ReadToEnd();
        text = Regex.Replace(
            original,
            pattern,
            replace,
            RegexOptions.Singleline);
      }

      using (StreamWriter sw = new StreamWriter(outFile, false))
      {
        sw.Write(text);
      }
    }

    private static void PrintUsage_()
    {
      Console.WriteLine("Usage:");
      Console.WriteLine(" rx [regex match] <replacement> [infile] [outfile]");
    }
  }
}
