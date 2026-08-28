#ifndef AppVersion
  #define AppVersion "0.3.0-beta.1"
#endif

#ifndef NumericVersion
  #define NumericVersion "0.3.0.0"
#endif

#ifndef AppPublishDir
  #define AppPublishDir "..\desktop\StorageClean.App\bin\Release\net8.0-windows\win-x64\publish"
#endif

#ifndef OutputDir
  #define OutputDir "..\artifacts\windows"
#endif

[Setup]
AppId={{2A99AFBC-AC35-43D6-9E06-F79E6CB08F0C}
AppName=StorageClean
AppVersion={#AppVersion}
AppVerName=StorageClean {#AppVersion}
AppPublisher=storageclean.app
AppPublisherURL=https://storageclean.app
AppSupportURL=https://storageclean.app
AppUpdatesURL=https://storageclean.app
DefaultDirName={localappdata}\Programs\StorageClean
DefaultGroupName=StorageClean
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=StorageClean-Setup-{#AppVersion}-win-x64
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
SetupLogging=yes
UninstallDisplayIcon={app}\StorageClean.exe
VersionInfoCompany=storageclean.app
VersionInfoDescription=StorageClean Windows installer
VersionInfoProductName=StorageClean
VersionInfoProductVersion={#NumericVersion}
VersionInfoVersion={#NumericVersion}
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "{#AppPublishDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\StorageClean"; Filename: "{app}\StorageClean.exe"
Name: "{autodesktop}\StorageClean"; Filename: "{app}\StorageClean.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\StorageClean.exe"; Description: "Launch StorageClean"; Flags: nowait postinstall skipifsilent
