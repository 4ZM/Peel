echo '[+] Building rx.exe'
csc /nologo rx.cs 

$keyopt = "/keyfile:test\TestKey.pfx"

# Standalone Target
echo '[+] Building test target: StandaloneTarget'
csc /nologo /target:exe $keyopt /out:test\standalone\StandaloneTarget.exe test\standalone\StandaloneTarget.cs

# 2 x library + exe Target (Password.dll -> Check.dll -> LibTarget.exe)
echo '[+] Building test target: LibTarget'
csc /nologo /target:library $keyopt /out:test\lib\Password.dll test\lib\Password.cs
csc /nologo /target:library $keyopt /lib:test\lib /reference:Password.dll /out:test\lib\Check.dll test\lib\Check.cs
csc /nologo /target:exe $keyopt /lib:test\lib /reference:Password.dll /reference:Check.dll /out:test\lib\LibTarget.exe test\lib\LibTarget.cs

# Basic WPF application
echo '[+] Building test target: basicwpf'
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe test\basicwpf\BasicWpf.sln /p:Configuration=Release /p:Platform='Any CPU' /nologo /verbosity:quiet
sn -q -Ra test\basicwpf\bin\Release\basicwpf.exe test\TestKey.pfx
