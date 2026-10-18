param([string]$Directory = $PSScriptRoot)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
if (-not ('PortraitAlphaBounds' -as [type])) {
Add-Type -TypeDefinition @'
public static class PortraitAlphaBounds {
  public static int[] Read(byte[] data, int width, int height, int stride) {
    int x0=width, y0=height, x1=-1, y1=-1, edgeMax=0, solid=0, clear=0;
    for(int y=0;y<height;y++) for(int x=0;x<width;x++) {
      int a=data[y*stride+x*4+3];
      if(a<=2) clear++;
      if(a>=250) solid++;
      if(x==0 || y==0 || x==width-1 || y==height-1) edgeMax=System.Math.Max(edgeMax,a);
      if(a>8) { x0=System.Math.Min(x0,x); y0=System.Math.Min(y0,y); x1=System.Math.Max(x1,x); y1=System.Math.Max(y1,y); }
    }
    return new int[]{x0,y0,x1,y1,edgeMax,solid,clear};
  }
}
'@
}
$records = @()
foreach ($file in Get-ChildItem -LiteralPath $Directory -Filter '*.png' -File) {
  $bitmap = [System.Drawing.Bitmap]::new($file.FullName)
  try {
    $rect = [System.Drawing.Rectangle]::new(0,0,$bitmap.Width,$bitmap.Height)
    $data = $bitmap.LockBits($rect,[System.Drawing.Imaging.ImageLockMode]::ReadOnly,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
      $bytes = [byte[]]::new($data.Stride*$data.Height)
      [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0,$bytes,0,$bytes.Length)
      $bounds = [PortraitAlphaBounds]::Read($bytes,$bitmap.Width,$bitmap.Height,$data.Stride)
    } finally { $bitmap.UnlockBits($data) }
    $records += [ordered]@{
      file=$file.Name; width=$bitmap.Width; height=$bitmap.Height
      bounds_alpha_gt_8=@($bounds[0],$bounds[1],$bounds[2],$bounds[3])
      margins=@($bounds[0],$bounds[1],($bitmap.Width-1-$bounds[2]),($bitmap.Height-1-$bounds[3]))
      edge_alpha_max=$bounds[4]
      opaque_fraction=($bounds[5]/($bitmap.Width*$bitmap.Height))
      clear_fraction=($bounds[6]/($bitmap.Width*$bitmap.Height))
      contained=($bounds[0]-gt 0 -and $bounds[1]-gt 0 -and $bounds[2]-lt $bitmap.Width-1 -and $bounds[3]-lt $bitmap.Height-1)
      sha256=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    }
  } finally { $bitmap.Dispose() }
}
$records | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $Directory 'alpha-verification.json') -Encoding utf8
$records | ForEach-Object { [pscustomobject]$_ } | Select-Object file,width,height,margins,edge_alpha_max,contained | Format-Table -AutoSize
