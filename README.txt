Peel - Strong Name removal tool

Usage: peel.ps1 <filename> [-key key] [-ref key]
Peel - Strong Name Removal Tool

  -help, -h     Print this help and exit.
  -key, -k      Only process assemblies signed with the specified key.
  -ref, -r      Remove all references to the specified key.

To process all files in a directory, do this:
gci <dir>\* -include *.dll,*.exe | % { .\peel.ps1 $_.FullName -ref <key> }
