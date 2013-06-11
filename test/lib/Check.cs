using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Target
{
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
