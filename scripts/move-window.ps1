param(
	[int]$X = 0,
	[int]$Y = 0,
	[int]$Delay = 5
)

if (-not [System.Management.Automation.PSTypeName]'User32'.Type) {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class User32 {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

        public static readonly IntPtr HWND_TOP = new IntPtr(0);
        public const uint SWP_NOSIZE = 0x0001;
    }
"@
}

Write-Output "Select window to move, window moves in $($Delay)"
while ($Delay -gt 0) {
	Start-sleep 1
	$Delay--
	Write-Output $Delay
}

$hwnd = [User32]::GetForegroundWindow()

if ($hwnd -ne [IntPtr]::Zero) {
	[User32]::SetWindowPos($hwnd, [User32]::HWND_TOP, $X, $Y, 0, 0, [User32]::SWP_NOSIZE) | Out-Null
	Write-Host "Window moved to ($($X),$($Y))."
} else {
	Write-Error "No window found."
}
