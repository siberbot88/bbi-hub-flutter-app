# PowerShell script to replace withOpacity with withAlpha
# Usage: .\replace_opacity.ps1

$files = @(
    "lib\feature\owner\widgets\bottom_nav_owner.dart",
    "lib\feature\owner\screens\voucher_addpage.dart",
    "lib\feature\owner\screens\voucher_editpage.dart",
    "lib\feature\owner\screens\help_support_page.dart",
    "lib\feature\owner\screens\feedback.dart",
    "lib\feature\admin\screens\service_complete.dart",
    "lib\feature\admin\screens\service_pending.dart",
    "lib\feature\admin\screens\service_progress.dart",
    "lib\feature\admin\screens\service_detail.dart",
    "lib\feature\admin\screens\tabs\revenue_tab.dart",
    "lib\feature\admin\screens\tabs\technician_tab.dart",
    "lib\feature\admin\screens\tabs\customer_tab.dart",
    "lib\feature\admin\screens\voucher_editpage.dart",
    "lib\feature\admin\screens\voucher_addpage.dart",
    "lib\feature\admin\screens\help_support_page.dart",
    "lib\feature\admin\screens\feedback.dart",
    "lib\feature\admin\widgets\home\home_stat_card.dart",
    "lib\feature\admin\widgets\home\home_quick_feature.dart",
    "lib\feature\admin\widgets\home\home_app_bar.dart"
)

$replacements = @{
    "withOpacity(0.04)" = "withAlpha(10)"
    "withOpacity(0.05)" = "withAlpha(13)"
    "withOpacity(0.06)" = "withAlpha(15)"
    "withOpacity(0.08)" = "withAlpha(20)"
    "withOpacity(0.10)" = "withAlpha(26)"
    "withOpacity(0.15)" = "withAlpha(38)"
    "withOpacity(0.25)" = "withAlpha(64)"
    "withOpacity(0.35)" = "withAlpha(89)"
    "withOpacity(0.4)" = "withAlpha(102)"
    "withOpacity(0.5)" = "withAlpha(128)"
    "withOpacity(0.6)" = "withAlpha(153)"
}

$totalReplacements = 0

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $originalContent = $content
        
        foreach ($key in $replacements.Keys) {
            $content = $content -replace [regex]::Escape($key), $replacements[$key]
        }
        
        if ($content -ne $originalContent) {
            Set-Content $file $content -NoNewline
            $changes = ($originalContent.Length - $content.Length) / $originalContent.Length * 100
            Write-Host "✓ Updated: $file"
            $totalReplacements++
        }
    }
}

Write-Host "`n✅ Total files updated: $totalReplacements"
Write-Host "Run 'flutter analyze' to verify changes"
