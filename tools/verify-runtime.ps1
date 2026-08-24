$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot

Push-Location $repositoryRoot
try {
    & rtk luajit "tools/test-runtime.lua"
    if ($LASTEXITCODE -ne 0) {
        throw "Lua runtime verification failed with exit code $LASTEXITCODE."
    }

    $tocPath = Join-Path $repositoryRoot "Bejeweled/Bejeweled_Mainline.toc"
    $toc = Get-Content -LiteralPath $tocPath
    if ($toc -notcontains "## Interface: 120100") {
        throw "Runtime TOC does not target the pinned Interface 120100 baseline."
    }
    if ($toc -notcontains "## SavedVariables: BejeweledData" -or
        $toc -notcontains "## SavedVariablesPerCharacter: BejeweledProfile") {
        throw "Runtime TOC does not preserve the legacy SavedVariables declarations."
    }
    if ($toc -notcontains "## AddonCompartmentFunc: Bejeweled_OnAddonCompartmentClick" -or
        $toc -notcontains "## AddonCompartmentFuncOnEnter: Bejeweled_OnAddonCompartmentEnter" -or
        $toc -notcontains "## AddonCompartmentFuncOnLeave: Bejeweled_OnAddonCompartmentLeave") {
        throw "Runtime TOC does not register the verified addon-compartment callbacks."
    }
    $expectedFiles = @(
        "Core\Init.lua",
        "Core\Constants.lua",
        "Core\Audio.lua",
        "Core\SavedVariables.lua",
        "Engine\Grid.lua",
        "Engine\Matches.lua",
        "Engine\Cascade.lua",
        "Engine\Scoring.lua",
        "Engine\Input.lua",
        "Engine\Session.lua",
        "UI\Backdrops.lua",
        "UI\GemPool.lua",
        "UI\Animations.lua",
        "UI\HUD.lua",
        "UI\Summary.lua",
        "UI\MainWindow.lua",
        "UI\Compartment.lua"
    )
    $actualFiles = @($toc | Where-Object { $_ -match "\.lua$" })
    if (Compare-Object -ReferenceObject $expectedFiles -DifferenceObject $actualFiles -SyncWindow 0) {
        throw "Runtime TOC load order differs from the verified foundation order."
    }

    foreach ($relativePath in $expectedFiles) {
        $runtimePath = Join-Path (Join-Path $repositoryRoot "Bejeweled") $relativePath
        if (-not (Test-Path -LiteralPath $runtimePath -PathType Leaf)) {
            throw "Runtime TOC entry is missing: $relativePath"
        }
    }

    Write-Output "Verified: Retail TOC order, full local summary, Timed setup/flight boundary, addon-compartment access, and Lua 5.1-compatible playable window/session runtime."
}
finally {
    Pop-Location
}
