function New-RandomCharacterString {
    param (
        [int]$CharacterStringLength = 8,
        [string]$CharactersToUse = 'abcdefghkmnrstuvwxyzABCDEFGHKLMNPRSTUVWXYZ23456789%&^#'
    )

    $InitialCharacterString = -join ($CharactersToUse.ToCharArray() | Get-Random -Count $CharacterStringLength)

    Write-Output $InitialCharacterString
}

function New-UniquePositionsInString {
    param (
        [int]$StringLength = 8,
        [int]$UniquePositionCount = 4
    )

    $StringPositionsHash = @{}
    do {
        $Position = Get-Random -Minimum 0 -Maximum $StringLength

        try {
            $StringPositionsHash.Add($Position, $Position)
        }
        catch {
        }

        $Position = $null
    } while ($StringPositionsHash.Count -lt $UniquePositionCount)
    [int[]]$UniquePositionsInString = $StringPositionsHash.Keys

    Write-Output $UniquePositionsInString
}

# Test-CharacterUsedInString is currently unused in passwor generation
function Test-CharacterUsedInString {
    param (
        [string]$StringToTest,
        [string]$CharactersToCheckFor
    )

    $TestResult = $null
    if ($StringToTest -cmatch $CharactersToCheckFor) {
        $TestResult = $true
    } else {
        $TestResult = $false
    }

    Write-Output $TestResult
}

# needs to be expanded to allow for type selection
function New-RandomPassword {
    [CmdletBinding()]
    param (
        [int]$PasswordLength = 8
    )

    [char[]]$BasePassword = New-RandomCharacterString -CharacterStringLength $PasswordLength
    Write-Debug "BasePassword as char array is $BasePassword"

    [int[]]$CharacterOverridesForPassword = New-UniquePositionsInString -StringLength $PasswordLength -UniquePositionCount 4
    Write-Debug "CharacterOverridesForPassword is $CharacterOverridesForPassword"

    $UpperCaseCharacter = New-RandomCharacterString -CharacterStringLength 1 -CharactersToUse 'ABCDEFGHKLMNPRSTUVWXYZ'
    Write-Debug "UpperCaseCharacter is $UpperCaseCharacter"
    $BasePassword[$CharacterOverridesForPassword[0]] = $UpperCaseCharacter

    $LowerCaseCharacter = New-RandomCharacterString -CharacterStringLength 1 -CharactersToUse 'abcdefghkmnrstuvwxyz'
    Write-Debug "LowerCaseCharacter is $LowerCaseCharacter"
    $BasePassword[$CharacterOverridesForPassword[1]] = $LowerCaseCharacter

    $NumberCharacter = New-RandomCharacterString -CharacterStringLength 1 -CharactersToUse '23456789'
    Write-Debug "NumberCharacter is $NumberCharacter"
    $BasePassword[$CharacterOverridesForPassword[2]] = $NumberCharacter

    $SpecialCharacter = New-RandomCharacterString -CharacterStringLength 1 -CharactersToUse '%&^#'
    Write-Debug "SpecialCharacter is $SpecialCharacter"
    $BasePassword[$CharacterOverridesForPassword[3]] = $SpecialCharacter


    [string]$NewPassword = -join $BasePassword
    Write-Output $NewPassword
}


$Domain = "ad.netappawvdstest03.onmicrosoft.com"


New-AdGroup -Name PooledDesktop -GroupScope Global
New-AdGroup -Name PersonalDesktop -GroupScope Global
New-AdGroup -Name GPUDesktop -GroupScope Global

$users = @()

$users += New-Object psobject -Property @{FirstName = "Rhys"; LastName = "Hawkins"}
$users += New-Object psobject -Property @{FirstName = "Vilma"; LastName = "Jarvi"}
$users += New-Object psobject -Property @{FirstName = "Ted"; LastName = "Ellison"}
$users += New-Object psobject -Property @{FirstName = "Heath"; LastName = "Atwood"}
$users += New-Object psobject -Property @{FirstName = "Kinslee"; LastName = "Fink"}
$users += New-Object psobject -Property @{FirstName = "Joshua"; LastName = "Wilson"}
$users += New-Object psobject -Property @{FirstName = "Victoria"; LastName = "Roach"}
$users += New-Object psobject -Property @{FirstName = "Ellis"; LastName = "Schaefer"}
$users += New-Object psobject -Property @{FirstName = "Regan"; LastName = "Rosen"}
$users += New-Object psobject -Property @{FirstName = "Daisy"; LastName = "Morgan"}

foreach ($user in $users) {
$username = "$($user.FirstName).$($user.LastName)"
$UserPassword = New-RandomPassword
New-ADUser -SamAccountName $username -GivenName $($user.FirstName) -Surname $($user.LastName) -Enabled $true -AccountPassword (ConvertTo-SecureString $UserPassword -AsPlainText -Force) -DisplayName "$($user.FirstName) $($user.LastName)" -Name "$username" -UserPrincipalName "$username@$Domain"
Write-Output "$username created with password: $UserPassword"
}


Add-AdGroupMember -Identity PooledDesktop -Members Rhys.Hawkins,Heath.Atwood,Kinslee.Fink,Victoria.Roach,Regan.Rosen
Add-AdGroupMember -Identity PersonalDesktop -Members Vilma.Jarvi,Ted.Ellison,Daisy.Morgan
Add-AdGroupMember -Identity GPUDesktop -Members Joshua.Wilson,Ellis.Schaefer
