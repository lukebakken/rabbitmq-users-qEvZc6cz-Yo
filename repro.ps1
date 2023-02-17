param(
    [switch]$Debug = $false,
    [switch]$Verbose = $false,
    [int]$Count = 10
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest' -ErrorAction 'Stop' -Verbose

if (Test-Path Alias:\curl)
{
    Remove-Item Alias:\curl
}

for ($i = 0; $i -lt $Count; $i++)
{
    $username = "testuser-$i"
    $user_pass = 'guest:guest'
    $url = "localhost:15672/api/users/$username"

    $curl_args = @('-u', $user_pass, `
        '-X', 'PUT', $url, `
        '-H', 'content-type: application/json', `
        '-d', '{"tags":"administrator","password_hash":""}')

    if ($Verbose)
    {
        $curl_args += '-v'
    }

    if ($Debug)
    {
        # https://stackoverflow.com/a/1674950
        & echoargs $curl_args
    }
    else
    {
        & curl $curl_args

        # This verifies that the user was created without a password
        $j = $(& curl -4su $user_pass $url | ConvertFrom-Json)
        if (!($j.password_hash -eq ''))
        {
            throw "[ERROR] user '$username' was created with a password"
        }
        else
        {
            Write-Host "[INFO] user '$username' was created WITHOUT a password"
        }
    }
}
