$Host.UI.RawUI.WindowTitle = "ImbCleaner"
Write-Host @"
 ____  _  _                                
(  _ \( \/ )                               
 ) _ < \  /                                
(____/ (__)                                
 ____  ____  _  _  _  _    __    ____  ___ 
(  _ \( ___)( \/ )( \/ )  /__\  (  _ \/ __)
 )   / )__)  )  (  )  (  /(__)\  )___/\__ \
(_)\_)(____)(_/\_)(_/\_)(__)(__)(__)  (___/
"@ -ForegroundColor Green

$script:cleaningInProgress = $true

# function Show-LoadingAnimation {
#     $frames = @("Oo.", "oOo", ".oO", "o.o")
#     $i = 0
#     while ($script:cleaningInProgress) {
#         $frame = $frames[$i % $frames.Length]
#         $loadingLabel.Dispatcher.Invoke([action]{
#             $loadingLabel.Content = "Cleaning... " + $frame
#         })
#         Start-Sleep -Milliseconds 200
#         $i++
#     }
#     $loadingLabel.Dispatcher.Invoke([action]{
#         $loadingLabel.Content = "Cleanup complete!"
#     })
# }

$null = Start-Job -ScriptBlock { Show-LoadingAnimation }

# Restart as admin if needed
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

try {
    Add-Type -AssemblyName PresentationFramework
} catch {
    Write-Host "Can't load WPF. Maybe no .NET Framework or older system."
    pause
    exit
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="ImbCleaner" Height="250" Width="400" ResizeMode="NoResize" WindowStartupLocation="CenterScreen" Background="Black">
    <Grid Margin="10">
        <TextBlock Name="Status" Text="Ready to clean the junk..." Foreground="Lime" FontSize="16" VerticalAlignment="Top" />
        <ProgressBar Name="Progress" Height="20" Margin="0,40,0,0" />
        <Button Name="CleanBtn" Content="Clean all the junk" Width="200" Height="40" VerticalAlignment="Bottom" HorizontalAlignment="Center" />
    </Grid>
</Window>
"@

try {
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Write-Host "Error loading window. WPF might be broken on this system."
    pause
    exit
}

$cleanBtn = $window.FindName("CleanBtn")
$status = $window.FindName("Status")
$progress = $window.FindName("Progress")

function Update-Progress {
    param([string]$text, [int]$percent)
    $status.Text = $text
    $progress.Value = $percent
    Start-Sleep -Milliseconds 400
}

function Delete-Folder {
    param($path)
    if (Test-Path $path) {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $path
    }
}

$cleanBtn.Add_Click({
    $cleanBtn.IsEnabled = $false
    Update-Progress "1/6: Cleaning gradle trash..." 10

    # === Gradle cleaning: smart detection ===
    $gradleHome = $env:GRADLE_USER_HOME
    if (-not $gradleHome) {
        $gradleHome = Join-Path $env:USERPROFILE ".gradle"
    }

    Delete-Folder "$gradleHome\caches"
    Delete-Folder "$gradleHome\daemon"
    Delete-Folder "$gradleHome\native"
    Delete-Folder "$gradleHome\wrapper\dists"

    Update-Progress "2/6: Removing temporary files..." 25
    Remove-Item -Recurse -Force "$env:TEMP\*" -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "C:\Windows\Temp\*" -ErrorAction SilentlyContinue

    Update-Progress "3/6: Cleaning prefetch junk..." 40
    Remove-Item -Recurse -Force "C:\Windows\Prefetch\*" -ErrorAction SilentlyContinue

    Update-Progress "4/6: Removing update junk..." 55
    Remove-Item -Recurse -Force "C:\Windows\SoftwareDistribution\Download\*" -ErrorAction SilentlyContinue

    Update-Progress "5/6: Emptying Recycle Bin..." 70
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue

    # Extra cleaning
    $pathsToClean = @(
        # "$env:LOCALAPPDATA\Discord\Cache", # damn, discord dont work after this =)
        # "$env:APPDATA\discord\Cache",
        # "$env:APPDATA\discordcanary\Cache",
        # "$env:APPDATA\discordptb\Cache",
        "$env:APPDATA\Telegram Desktop\tdata\user_data",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\ShaderCache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\GrShaderCache",
        "$env:APPDATA\Spotify\Data",
        "$env:LOCALAPPDATA\Temp",
        "$env:WINDIR\Temp",
        "$env:SystemRoot\Logs"
    )

    foreach ($path in $pathsToClean) {
        if (Test-Path $path) {
            try {
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            } catch {
                Write-Host "Failed to remove $path"
            }
        }
    }

    Update-Progress "6/6: Final touch..." 100
    $status.Text = "All done. Your system is clean!"
    $cleanBtn.Content = "Clean again?"
    $cleanBtn.IsEnabled = $true
})

try {
    $window.ShowDialog() | Out-Null
} catch {
    Write-Host "Error displaying window. WPF might be broken on this system."
    pause
    exit
}

$script:cleaningInProgress = $false
