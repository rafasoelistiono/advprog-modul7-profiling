$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$jmeterHome = Join-Path $repoRoot "apache-jmeter-5.6.3\apache-jmeter-5.6.3"
$jmeterBat = Join-Path $jmeterHome "bin\jmeter.bat"
$jmeterBin = Join-Path $jmeterHome "bin"
$resultRoot = Join-Path $PSScriptRoot "results"

$plans = @(
    @{ Name = "test_plan_1"; File = "test_plan_1.jmx" },
    @{ Name = "test_plan_2"; File = "test_plan_2.jmx" },
    @{ Name = "test_plan_3"; File = "test_plan_3.jmx" }
)

if (-not (Test-Path $jmeterBat)) {
    throw "JMeter executable not found at $jmeterBat"
}

New-Item -ItemType Directory -Force -Path $resultRoot | Out-Null

foreach ($plan in $plans) {
    $planPath = Join-Path $PSScriptRoot $plan.File
    $jtlPath = Join-Path $resultRoot ($plan.Name + ".jtl")
    $dashboardPath = Join-Path $resultRoot ($plan.Name + "-dashboard")

    if (Test-Path $jtlPath) {
        Remove-Item $jtlPath -Force
    }

    if (Test-Path $dashboardPath) {
        Remove-Item $dashboardPath -Recurse -Force
    }

    Push-Location $jmeterBin
    try {
        & $jmeterBat -n -t $planPath -l $jtlPath -e -o $dashboardPath "-Jhost=localhost" "-Jport=8080"
    }
    finally {
        Pop-Location
    }

    if ($LASTEXITCODE -ne 0) {
        throw "JMeter failed for $($plan.File)"
    }
}

Write-Host "JMeter plans executed successfully."
