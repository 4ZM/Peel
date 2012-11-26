# Copyright (C) 2012 Anders Sundman <anders@4zm.org>
#
# This file is part of Peel - Strong Name removal tool.
#
# Peel is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Peel is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Peel. If not, see <http://www.gnu.org/licenses/>.

param(
  [string]
  $filename, 
  [string]
  [alias("k")]
  $key,
  [string]
  [alias("r")]
  $ref,
  [switch]
  [alias("h")]
  $help)

# Help or missing filename
if ($help -or $filename -eq "")
{
  Write-Host 'Usage: peel.ps1 <filename> [-key key] [-ref key]'
  Write-Host 'Peel - Strong Name Removal Tool'
  Write-Host
  Write-Host '  -help, -h     Print this help and exit.'
  Write-Host '  -key, -k      Only process assemblies signed with the specified key.'
  Write-Host '  -ref, -r      Remove all references to the specified key.'
  Write-Host
  Write-Host 'To process all files in a directory, do this:'  
  Write-Host 'gci <dir>\* -include *.dll,*.exe | % { .\peel.ps1 $_.FullName -ref <key> }'
  exit
}

# Get filename without path - to use in messages
$fn = Split-Path -Leaf $filename

Write-Host "Peel is processing: $fn"

# Check file existance
if (!(Test-Path $filename -pathType leaf))
{
  Write-Host "[-] File not found: $filename"
  exit
}

# Check target type
if ($filename.EndsWith("exe"))
{
  $targettype = "/exe"
}
elseif ($filename.EndsWith("dll"))
{
  $targettype = "/dll"
}
else
{
  Write-Host "[-] Invalid file extension. Expected exe or dll."
  exit
}

# Make sure it's an IL assembly 
corflags "$filename" 2>&1 | Out-Null
if (!$?) 
{
  Write-Host "[-] Wrong binary format."
  exit
}

# Check ref key parameter (if present)
if ($ref)
{
  if (!($ref -match '^[0-9a-fA-F]{16}$')) 
  {
    Write-Host "[-] Invalid key specified. Should be [0-9a-fA-F]{16}"
    exit
  }
}

# Find the public key
$snres = & sn -q -T "$filename"
if ($snres -match 'Public key token is (?<key>[0-9a-f]+)')
{
  Write-Host '[+] Extracting publickey:' $Matches["key"]
  $issigned = $true
}
else 
{
  $issigned = $false
}

# Test key parameter against assembly key
$snres = & sn -q -T "$filename"
if ($issigned -and $key -and !($Matches["key"].ToUpper().Equals($key.ToUpper())))
{
  Write-Host '[-] Signing key does not match -key argument. Skipping assembly.'
  exit
}

# No point in running without ref stripping unless signed
if (!$issigned -and !$ref)
{
  Write-Host '[-] No -ref option and not a strongly named assembly.'
  exit
}

# Step 1 in roundtrip: Dissasemble
Write-Host "[+] Disasembling $fn -> $fn.il"
ildasm /nobar /typelist /all /out="$filename.il" "$filename" 2>&1 | Out-Null

if (!$?) 
{
  Write-Host "[-] Disasembly failed. Wrong binary format?"
  exit
}

# Step 2 in roundtrip: Strong name stripping
if ($issigned)
{
  Write-Host "[+] Removing strong name signing (.publickey section)"
  .\rx.exe ' *\.publickey = \(([0-9A-F ]+(//[^\n]+\n)?)+\) *//[^\n]+\n' "$filename.il" "$filename.il"
}

# Also, if ref option is specified, remove references
if ($ref) 
{
  $keyarray = $ref.ToUpper().ToCharArray()
  $keyref = ""
  for ($i=0; $i -lt $keyarray.length; $i += 2) 
  {
    $keyref += $keyarray[$i] + $keyarray[$i+1] + ' '
  }
  $keyref = $keyref.TrimEnd(" ")
  
  Write-Host "[+] Removing strong name references (.publickeytoken sections)"
  .\rx.exe " *\.publickeytoken = \($keyref \) *//[^\n]+\n" "$filename.il" "$filename.il"
}

# Step 3 in roundtrip: Assemble 
Write-Host "[+] Assemblying $fn.il -> $fn"
ilasm /nologo "$targettype" /quiet /resource="$filename.res" /output="$filename" "$filename.il"  | Out-Null

if (!$?) 
{
  Write-Host "[-] Assembly failed."
  exit
}