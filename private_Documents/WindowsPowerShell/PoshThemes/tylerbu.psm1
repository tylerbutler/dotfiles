#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $lastColor = $sl.Colors.PromptBackgroundColor
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    $user = [System.Environment]::UserName
    $computer = [System.Environment]::MachineName
    $path = Get-FullPath -dir $pwd
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion
    $prompt += Write-Prompt -Object "$path " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $($sl.PromptSymbols.SegmentForwardSymbol) -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    # Writes the postfix to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor

    $timeStamp = Get-Date -UFormat %R
    $timestamp = "[$timeStamp]"

    $prompt += Set-CursorForRightBlockWrite -textLength ($timestamp.Length + 1)
    $prompt += Write-Prompt $timeStamp -ForegroundColor $sl.Colors.PromptForegroundColor

    $prompt += Set-Newline

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor $sl.Colors.PromptBackgroundColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = ''

$sl.PromptSymbols.ElevatedSymbol = [char]::ConvertFromUtf32(0xE375)
$sl.PromptSymbols.ElevatedSymbol = [char]::ConvertFromUtf32(0xf0e7)
# $sl.PromptSymbols.ElevatedSymbol = [char]::ConvertFromUtf32(0xE24E)
# $sl.PromptSymbols.ElevatedSymbol = [char]::ConvertFromUtf32(0xE009)

$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0xE76F)
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0xE285)

$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
# $sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0CE)

$sl.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xe725)
# $sl.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xf5fa)
# $sl.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xf7a1)

$sl.GitSymbols.BranchUntrackedSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.GitSymbols.BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0xFC27)

$sl.GitSymbols.BranchBehindStatusSymbol = [char]::ConvertFromUtf32(0xf175)
$sl.GitSymbols.BranchBehindStatusSymbol = [char]::ConvertFromUtf32(0xf063) + " "
# $sl.GitSymbols.BranchBehindStatusSymbol = [char]::ConvertFromUtf32(0xfc2c)
# $sl.GitSymbols.BranchBehindStatusSymbol = [char]::ConvertFromUtf32(0xf175)
# $sl.GitSymbols.BranchBehindStatusSymbol = [char]::ConvertFromUtf32(0xf433)

$sl.GitSymbols.BranchAheadStatusSymbol = [char]::ConvertFromUtf32(0xf062) + " "
$sl.GitSymbols.LocalStagedStatusSymbol = [char]::ConvertFromUtf32(0xfc23)
$sl.GitSymbols.LocalWorkingStatusSymbol = [char]::ConvertFromUtf32(0xf12a)

$sl.GitSymbols.OriginSymbols.enabled = $false
# $sl.GitSymbols.OriginSymbols.GitHub = [char]::ConvertFromUtf32(0xf7a2)

$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White