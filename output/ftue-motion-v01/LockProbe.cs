using System;
using System.Runtime.InteropServices;
public class LockProbe {
 [StructLayout(LayoutKind.Sequential)] public struct Unique { public int pid; public System.Runtime.InteropServices.ComTypes.FILETIME time; }
 [StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)] public struct ProcessInfo { public Unique process; [MarshalAs(UnmanagedType.ByValTStr,SizeConst=256)] public string app; [MarshalAs(UnmanagedType.ByValTStr,SizeConst=64)] public string service; public int type; public uint status; public uint session; [MarshalAs(UnmanagedType.Bool)] public bool restartable; }
 [DllImport("rstrtmgr.dll",CharSet=CharSet.Unicode)] static extern int RmStartSession(out uint handle,int flags,string key);
 [DllImport("rstrtmgr.dll",CharSet=CharSet.Unicode)] static extern int RmRegisterResources(uint handle,uint count,string[] files,uint apps,Unique[] processes,uint services,string[] names);
 [DllImport("rstrtmgr.dll")] static extern int RmGetList(uint handle,out uint needed,ref uint count,[In,Out] ProcessInfo[] list,ref uint reason);
 [DllImport("rstrtmgr.dll")] static extern int RmEndSession(uint handle);
 public static string Query(string file){uint h;int e=RmStartSession(out h,0,Guid.NewGuid().ToString("N"));if(e!=0)return "Start error "+e;try{e=RmRegisterResources(h,1,new[]{file},0,null,0,null);if(e!=0)return "Register error "+e;uint needed=0,count=0,reason=0;e=RmGetList(h,out needed,ref count,null,ref reason);if(needed==0)return "No locking application reported; result "+e;var list=new ProcessInfo[needed];count=needed;e=RmGetList(h,out needed,ref count,list,ref reason);string s="Result "+e+"; ";foreach(var p in list)s+=p.process.pid+" "+p.app+"; ";return s;}finally{RmEndSession(h);}}
}
